#!/bin/bash
set -e

echo "🚀 Starting VGC Website Production Server"
echo "========================================"

# Function to wait for database
wait_for_db() {
    echo "🔄 Waiting for database connection..."
    python << END
import sys
import time
import psycopg2
from django.conf import settings

# Import Django settings
import os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mysite.settings.production')

import django
django.setup()

from django.db import connection

max_attempts = 30
attempt = 0

while attempt < max_attempts:
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        print("✅ Database connection successful!")
        break
    except Exception as e:
        attempt += 1
        print(f"⏳ Database connection attempt {attempt}/{max_attempts} failed. Retrying in 2 seconds...")
        if attempt >= max_attempts:
            print(f"❌ Failed to connect to database after {max_attempts} attempts")
            sys.exit(1)
        time.sleep(2)
END
}

# Function to run database migrations
run_migrations() {
    echo "🔄 Running database migrations..."
    if python manage.py migrate --noinput; then
        echo "✅ Database migrations completed successfully"
    else
        echo "❌ Database migrations failed"
        exit 1
    fi
}

# Function to collect static files
collect_static() {
    echo "📁 Collecting static files..."
    if python manage.py collectstatic --noinput --clear; then
        echo "✅ Static files collected successfully"
    else
        echo "❌ Static file collection failed"
        exit 1
    fi
}

# Function to create superuser if it doesn't exist
create_superuser() {
    if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_EMAIL" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
        echo "👤 Creating superuser if it doesn't exist..."
        python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()

username = "$DJANGO_SUPERUSER_USERNAME"
email = "$DJANGO_SUPERUSER_EMAIL"
password = "$DJANGO_SUPERUSER_PASSWORD"

if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username=username, email=email, password=password)
    print(f"✅ Superuser '{username}' created successfully")
else:
    print(f"ℹ️  Superuser '{username}' already exists")
END
    else
        echo "ℹ️  Skipping superuser creation (environment variables not set)"
    fi
}

# Main startup sequence
main() {
    echo "🔧 Environment: $(python -c 'import django; from django.conf import settings; print(settings.SETTINGS_MODULE)')"

    # Wait for database to be ready
    wait_for_db

    # Run migrations
    run_migrations

    # Collect static files
    collect_static

    # Create superuser if requested
    create_superuser

    echo ""
    echo "✅ Startup completed successfully!"
    echo "🚀 Starting Gunicorn server..."
    echo ""

    # Start the application server
    exec gunicorn mysite.wsgi:application \
        --bind 0.0.0.0:8000 \
        --workers 3 \
        --timeout 120 \
        --access-logfile - \
        --error-logfile - \
        --log-level info
}

# Run main function
main "$@"

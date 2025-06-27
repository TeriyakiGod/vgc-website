#!/bin/bash
set -e

echo "Starting VGC Website..."

# Wait for database to be ready
echo "Waiting for database to be ready..."
python -c "
import os
import sys
import time
import psycopg2
from psycopg2 import OperationalError

max_retries = 30
retry_count = 0

while retry_count < max_retries:
    try:
        conn = psycopg2.connect(
            host=os.environ.get('DB_HOST', 'localhost'),
            database=os.environ.get('DB_NAME', 'vgc_website'),
            user=os.environ.get('DB_USER', 'vgc_user'),
            password=os.environ.get('DB_PASSWORD', 'vgc_password'),
            port=os.environ.get('DB_PORT', '5432')
        )
        conn.close()
        print('Database is ready!')
        break
    except OperationalError:
        retry_count += 1
        print(f'Database not ready, retrying... ({retry_count}/{max_retries})')
        time.sleep(2)
else:
    print('Could not connect to database after 30 attempts')
    sys.exit(1)
"

echo "Running database migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput --clear

echo "Starting Gunicorn server..."
exec gunicorn mysite.wsgi:application \
    --bind 0.0.0.0:${PORT:-8000} \
    --workers ${GUNICORN_WORKERS:-3} \
    --timeout 120 \
    --max-requests 1000 \
    --max-requests-jitter 100 \
    --preload \
    --access-logfile - \
    --error-logfile -

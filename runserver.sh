#!/bin/bash
set -e

echo "Starting Gunicorn server..."

python manage.py collectstatic --no-input
python manage.py migrate

# Start Gunicorn with environment variables for configuration
exec gunicorn mysite.wsgi:application \
    --bind 0.0.0.0:${PORT:-8000} \
    --workers ${GUNICORN_WORKERS:-3} \
    --timeout 120 \
    --max-requests 1000 \
    --max-requests-jitter 100 \
    --preload \
    --access-logfile - \
    --error-logfile -

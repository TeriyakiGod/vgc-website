#!/bin/bash
set -e

echo "Starting VGC Website..."

python manage.py migrate --noinput

python manage.py collectstatic --noinput --clear

exec gunicorn mysite.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 3 \
    --timeout 120 \
    --access-logfile - \
    --error-logfile -

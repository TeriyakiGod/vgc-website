#!/bin/bash

# Quick development setup script

echo "🚀 Starting VGC Website Development Environment"
echo "=============================================="

# Start the database
echo "📊 Starting PostgreSQL database..."
./manage_db.sh start

# Check if database is ready
echo "⏳ Waiting for database to be ready..."
sleep 3

# Run migrations
echo "🔄 Running database migrations..."
./.venv/bin/python manage.py migrate

# Collect static files
echo "📁 Collecting static files..."
./.venv/bin/python manage.py collectstatic --noinput

echo ""
echo "✅ Development environment is ready!"
echo ""
echo "You can now:"
echo "  • Press F5 in VS Code to start debugging"
echo "  • Open http://127.0.0.1:8000/ to view the site"
echo "  • Open http://127.0.0.1:8000/admin/ for Wagtail admin"
echo ""
echo "To stop the database later, run: ./manage_db.sh stop"
echo ""

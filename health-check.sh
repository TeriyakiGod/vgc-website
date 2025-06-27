#!/bin/bash

# Health check script for VGC Website

set -e

echo "🏥 VGC Website Health Check"
echo "=========================="

# Check if database is running
echo "🔍 Checking database status..."
if ./manage_db.sh status > /dev/null 2>&1; then
    echo "✅ Database is running"
else
    echo "❌ Database is not running"
    exit 1
fi

# Check if Django can connect to database
echo "🔍 Checking Django database connection..."
if ./.venv/bin/python manage.py check --database default > /dev/null 2>&1; then
    echo "✅ Django can connect to database"
else
    echo "❌ Django cannot connect to database"
    exit 1
fi

# Check for pending migrations
echo "🔍 Checking for pending migrations..."
PENDING_MIGRATIONS=$(./.venv/bin/python manage.py showmigrations --plan | grep -c "\[ \]" || true)
if [ "$PENDING_MIGRATIONS" -eq 0 ]; then
    echo "✅ No pending migrations"
else
    echo "⚠️  Found $PENDING_MIGRATIONS pending migrations"
    echo "Run: python manage.py migrate"
fi

# Check static files
echo "🔍 Checking static files..."
if [ -d "static" ] && [ "$(ls -A static)" ]; then
    echo "✅ Static files are collected"
else
    echo "⚠️  Static files not found or empty"
    echo "Run: python manage.py collectstatic"
fi

echo ""
echo "🎉 Health check complete!"

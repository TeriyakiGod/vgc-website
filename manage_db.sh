#!/bin/bash

# Docker management script for VGC Website

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No command provided"
    echo ""
    echo "Usage: $0 {start|stop|restart|status|logs|shell}"
    echo ""
    echo "Commands:"
    echo "  start   - Start the PostgreSQL database"
    echo "  stop    - Stop the PostgreSQL database"
    echo "  restart - Restart the PostgreSQL database"
    echo "  status  - Show database status"
    echo "  logs    - Show database logs"
    echo "  shell   - Open PostgreSQL shell"
    exit 1
fi

case "$1" in
    start)
        echo "Starting PostgreSQL database..."
        if docker-compose up -d; then
            echo "Database started successfully!"
        else
            echo "Failed to start database!"
            exit 1
        fi
        ;;
    stop)
        echo "Stopping PostgreSQL database..."
        if docker-compose down; then
            echo "Database stopped successfully!"
        else
            echo "Failed to stop database!"
            exit 1
        fi
        ;;
    restart)
        echo "Restarting PostgreSQL database..."
        if docker-compose down && docker-compose up -d; then
            echo "Database restarted successfully!"
        else
            echo "Failed to restart database!"
            exit 1
        fi
        ;;
    status)
        echo "Checking database status..."
        docker-compose ps
        ;;
    logs)
        echo "Showing database logs..."
        docker-compose logs -f db
        ;;
    shell)
        echo "Opening PostgreSQL shell..."
        docker-compose exec db psql -U vgc_user -d vgc_website
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo ""
        echo "Usage: $0 {start|stop|restart|status|logs|shell}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the PostgreSQL database"
        echo "  stop    - Stop the PostgreSQL database"
        echo "  restart - Restart the PostgreSQL database"
        echo "  status  - Show database status"
        echo "  logs    - Show database logs"
        echo "  shell   - Open PostgreSQL shell"
        exit 1
        ;;
esac
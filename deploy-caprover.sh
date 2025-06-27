#!/bin/bash

# CapRover Deployment Script for VGC Website
# This script helps deploy your application to CapRover manually

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CAPROVER_SERVER=""
APP_NAME=""
APP_TOKEN=""

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi

    if ! command -v curl &> /dev/null; then
        print_error "curl is not installed or not in PATH"
        exit 1
    fi

    print_status "Requirements check passed"
}

# Load configuration from environment or prompt user
load_config() {
    print_status "Loading configuration..."

    # Try to load from environment variables
    CAPROVER_SERVER=${CAPROVER_SERVER:-$1}
    APP_NAME=${APP_NAME:-$2}
    APP_TOKEN=${APP_TOKEN:-$3}

    # Prompt for missing values
    if [ -z "$CAPROVER_SERVER" ]; then
        read -p "Enter CapRover server URL (e.g., https://captain.your-domain.com): " CAPROVER_SERVER
    fi

    if [ -z "$APP_NAME" ]; then
        read -p "Enter CapRover app name: " APP_NAME
    fi

    if [ -z "$APP_TOKEN" ]; then
        read -s -p "Enter CapRover app token: " APP_TOKEN
        echo
    fi

    # Validate inputs
    if [ -z "$CAPROVER_SERVER" ] || [ -z "$APP_NAME" ] || [ -z "$APP_TOKEN" ]; then
        print_error "Missing required configuration. Please provide server URL, app name, and token."
        exit 1
    fi

    print_status "Configuration loaded successfully"
}

# Build Docker image
build_image() {
    print_status "Building Docker image..."

    # Use production Dockerfile if it exists, otherwise use the default one
    if [ -f "Dockerfile.production" ]; then
        DOCKERFILE="Dockerfile.production"
        print_status "Using production Dockerfile"
    else
        DOCKERFILE="Dockerfile"
        print_status "Using default Dockerfile"
    fi

    docker build -t "${APP_NAME}:latest" -f "$DOCKERFILE" .

    if [ $? -eq 0 ]; then
        print_status "Docker image built successfully"
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
}

# Test the built image
test_image() {
    print_status "Testing Docker image..."

    # Run container in background
    docker run -d --name "${APP_NAME}-test" -p 8001:8000 \
        -e SECRET_KEY="test-key-for-deployment" \
        -e DEBUG="False" \
        "${APP_NAME}:latest"

    # Wait for container to start
    sleep 10

    # Test health endpoint
    if curl -f http://localhost:8001/health/ > /dev/null 2>&1; then
        print_status "Image test passed"
    else
        print_warning "Health check failed, but continuing deployment"
    fi

    # Cleanup test container
    docker stop "${APP_NAME}-test" > /dev/null 2>&1
    docker rm "${APP_NAME}-test" > /dev/null 2>&1
}

# Deploy to CapRover
deploy_to_caprover() {
    print_status "Deploying to CapRover..."

    # Save image to tar file
    docker save "${APP_NAME}:latest" | gzip > "${APP_NAME}.tar.gz"

    # Deploy using CapRover API
    curl -X POST \
        "${CAPROVER_SERVER}/api/v2/user/apps/appDefinitions/upload" \
        -H "x-captain-auth: ${APP_TOKEN}" \
        -F "appName=${APP_NAME}" \
        -F "tarFile=@${APP_NAME}.tar.gz"

    if [ $? -eq 0 ]; then
        print_status "Deployment successful!"
        print_status "Your app should be available at: ${CAPROVER_SERVER}/api/v2/user/apps/appData/${APP_NAME}"
    else
        print_error "Deployment failed"
        exit 1
    fi

    # Cleanup
    rm -f "${APP_NAME}.tar.gz"
}

# Main deployment function
main() {
    print_status "Starting CapRover deployment process..."

    check_requirements
    load_config "$@"
    build_image
    test_image
    deploy_to_caprover

    print_status "Deployment completed successfully!"
    print_status "Check your CapRover dashboard for deployment status."
}

# Help function
show_help() {
    echo "Usage: $0 [CAPROVER_SERVER] [APP_NAME] [APP_TOKEN]"
    echo ""
    echo "Deploy VGC Website to CapRover"
    echo ""
    echo "Arguments:"
    echo "  CAPROVER_SERVER    CapRover server URL (e.g., https://captain.your-domain.com)"
    echo "  APP_NAME          Name of the app in CapRover"
    echo "  APP_TOKEN         CapRover app deployment token"
    echo ""
    echo "Environment Variables:"
    echo "  CAPROVER_SERVER   Same as first argument"
    echo "  APP_NAME          Same as second argument"
    echo "  APP_TOKEN         Same as third argument"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 https://captain.example.com vgc-website abc123"
    echo "  CAPROVER_SERVER=https://captain.example.com APP_NAME=vgc-website APP_TOKEN=abc123 $0"
}

# Check for help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Run main function
main "$@"

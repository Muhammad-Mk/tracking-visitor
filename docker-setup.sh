#!/bin/bash

# Enable error handling
set -e

# Function to print status messages
print_status() {
    echo "==> $1"
}

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "Error: $1 is required but not installed."
        exit 1
    fi
}

# Check required commands
print_status "Checking required commands..."
check_command docker
check_command docker-compose

# Create necessary directories
print_status "Creating required directories..."
mkdir -p docker/mysql
mkdir -p docker/redis

# Set proper permissions
print_status "Setting directory permissions..."
chmod -R 777 docker
chmod -R 777 storage
chmod -R 777 bootstrap/cache

# Copy environment file if it doesn't exist
if [ ! -f .env ]; then
    print_status "Creating .env file from .env.example..."
    cp .env.example .env
else
    print_status ".env file already exists"
fi

# Stop any running containers
print_status "Stopping any running containers..."
docker-compose down

# Build and start containers
print_status "Building and starting containers..."
docker-compose up -d --build

# Wait for containers to be ready
print_status "Waiting for containers to be ready..."
sleep 10

# Install dependencies
print_status "Installing PHP dependencies..."
docker-compose exec -T app composer install --no-interaction

# Generate application key
print_status "Generating application key..."
docker-compose exec -T app php artisan key:generate

# Run migrations
print_status "Running database migrations..."
docker-compose exec -T app php artisan migrate --force

# Clear cache
print_status "Clearing application cache..."
docker-compose exec -T app php artisan config:clear
docker-compose exec -T app php artisan cache:clear
docker-compose exec -T app php artisan route:clear
docker-compose exec -T app php artisan view:clear

# Check if containers are running
print_status "Checking container status..."
docker-compose ps

print_status "Setup completed! Your application is running at http://localhost:8000"
print_status "You can check the logs using: docker-compose logs -f" 
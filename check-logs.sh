#!/bin/bash

# Function to print status messages
print_status() {
    echo "==> $1"
}

# Check if containers are running
print_status "Checking container status..."
docker-compose ps

# Show logs for all containers
print_status "Showing logs for all containers..."
docker-compose logs -f 
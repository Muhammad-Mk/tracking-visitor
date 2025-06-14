#!/usr/bin/env pwsh

# Laravel Visitor Analytics - Automated Setup Script
# This script sets up the complete Laravel application with Docker

param(
    [switch]$Clean,
    [switch]$SkipBuild,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Laravel Visitor Analytics Setup Script

Usage: .\setup.ps1 [options]

Options:
  -Clean      Clean up existing containers and volumes before setup
  -SkipBuild  Skip Docker image building (use existing images)
  -Help       Show this help message

Examples:
  .\setup.ps1                    # Standard setup
  .\setup.ps1 -Clean             # Clean setup from scratch
  .\setup.ps1 -SkipBuild         # Quick setup without rebuilding
"@
    exit 0
}

# Color functions for better output
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }

# Check if Docker is installed and running
function Test-Docker {
    Write-Info "Checking Docker installation..."
    try {
        $dockerVersion = docker --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Docker is not installed or not in PATH"
            Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
            exit 1
        }
        Write-Success "Docker found: $dockerVersion"
    }
    catch {
        Write-Error "Docker is not installed or not running"
        exit 1
    }
}

# Check if Docker Compose is available
function Test-DockerCompose {
    Write-Info "Checking Docker Compose..."
    try {
        $composeVersion = docker-compose --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Docker Compose is not available"
            exit 1
        }
        Write-Success "Docker Compose found: $composeVersion"
    }
    catch {
        Write-Error "Docker Compose is not available"
        exit 1
    }
}

# Generate random string for keys
function New-RandomString {
    param([int]$Length = 32)
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    $random = 1..$Length | ForEach-Object { Get-Random -Maximum $chars.length }
    return ($random | ForEach-Object { $chars[$_] }) -join ''
}

# Clean up existing setup
function Invoke-Cleanup {
    Write-Warning "Cleaning up existing containers and volumes..."
    docker-compose down -v --remove-orphans 2>$null
    docker network prune -f 2>$null
    Write-Success "Cleanup completed"
}

# Create .env file with secure defaults
function New-EnvFile {
    Write-Info "Creating .env configuration file..."
    
    $appKey = "base64:" + [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((New-RandomString -Length 32)))
    
    $envContent = @"
# Application Configuration
APP_NAME="Laravel Visitor Analytics"
APP_ENV=local
APP_KEY=$appKey
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database Configuration
DB_CONNECTION=mysql
DB_HOST=visitor-analytics-db
DB_PORT=3306
DB_DATABASE=visitor_analytics
DB_USERNAME=visitor_user
DB_PASSWORD=visitor_password_123

# Redis Configuration
REDIS_HOST=visitor-analytics-redis
REDIS_PASSWORD=visitor_redis_password
REDIS_PORT=6385
REDIS_DB=0

# Cache Configuration
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Mail Configuration (Optional)
MAIL_MAILER=smtp
MAIL_HOST=mailhog
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="Laravel Visitor Analytics"

# Logging
LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

# Broadcasting
BROADCAST_DRIVER=log

# Filesystem
FILESYSTEM_DISK=local

# Queue
QUEUE_CONNECTION=sync

# Session
SESSION_LIFETIME=120

# Sanctum
SANCTUM_STATEFUL_DOMAINS=localhost,localhost:8000,127.0.0.1,127.0.0.1:8000,::1

# Docker Environment Variables
MYSQL_ROOT_PASSWORD=root_password_123
MYSQL_DATABASE=visitor_analytics
MYSQL_USER=visitor_user
MYSQL_PASSWORD=visitor_password_123

REDIS_PASSWORD=visitor_redis_password
"@

    $envContent | Out-File -FilePath ".env" -Encoding UTF8
    Write-Success "Environment file created successfully"
}

# Build and start Docker containers
function Start-DockerServices {
    if (-not $SkipBuild) {
        Write-Info "Building Docker containers..."
        docker-compose build --no-cache
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to build Docker containers"
            exit 1
        }
        Write-Success "Docker containers built successfully"
    }
    
    Write-Info "Starting Docker services..."
    # Use --force-recreate to avoid network issues
    docker-compose up -d --force-recreate
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "First attempt failed, trying with network cleanup..."
        docker network prune -f 2>$null
        Start-Sleep 2
        docker-compose up -d --force-recreate
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to start Docker services"
            exit 1
        }
    }
    Write-Success "Docker services started successfully"
    
    # Give services time to initialize
    Write-Info "Waiting for services to initialize..."
    Start-Sleep 5
}

# Setup Laravel application
function Initialize-LaravelApp {
    Write-Info "Setting up Laravel application..."
    
    # Wait for MySQL to be ready with better error handling
    Write-Info "Waiting for MySQL to be ready..."
    $mysqlReady = $false
    for ($i = 1; $i -le 30; $i++) {
        try {
            docker exec visitor-analytics-db mysqladmin ping -h localhost --silent 2>$null
            if ($LASTEXITCODE -eq 0) {
                $mysqlReady = $true
                break
            }
        }
        catch { }
        Write-Host "." -NoNewline
        Start-Sleep 2
    }
    
    if (-not $mysqlReady) {
        Write-Error "`nMySQL failed to start"
        exit 1
    }
    Write-Success "`nMySQL is ready!"
    
    # Wait for Redis to be ready
    Write-Info "Waiting for Redis to be ready..."
    $redisReady = $false
    for ($i = 1; $i -le 15; $i++) {
        try {
            # Try without auth first to see if Redis is responding
            $result = docker exec visitor-analytics-redis redis-cli -p 6385 ping 2>$null
            if ($result -match "NOAUTH|PONG") {
                $redisReady = $true
                break
            }
        }
        catch { }
        Write-Host "." -NoNewline
        Start-Sleep 1
    }
    
    if (-not $redisReady) {
        Write-Error "`nRedis failed to start"
        exit 1
    }
    Write-Success "`nRedis is ready!"
    
    # Fix git ownership issue
    Write-Info "Fixing git ownership..."
    docker exec visitor-analytics-app git config --global --add safe.directory /var/www 2>$null
    
    # Install Composer dependencies
    Write-Info "Installing Composer dependencies..."
    docker exec visitor-analytics-app composer install --no-dev --optimize-autoloader --no-interaction 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Composer install failed, trying with --ignore-platform-reqs..."
        docker exec visitor-analytics-app composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to install Composer dependencies"
            exit 1
        }
    }
    Write-Success "Composer dependencies installed"
    
    # Generate application key if needed
    Write-Info "Generating application key..."
    docker exec visitor-analytics-app php artisan key:generate --force 2>$null
    
    # Run database migrations
    Write-Info "Running database migrations..."
    docker exec visitor-analytics-app php artisan migrate --force 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to run database migrations"
        Write-Info "Checking database connection..."
        docker exec visitor-analytics-app php artisan tinker --execute="echo 'DB Connection: ' . DB::connection()->getDatabaseName();" 2>$null
        exit 1
    }
    Write-Success "Database migrations completed"
    
    # Seed the database
    Write-Info "Seeding database with sample data..."
    docker exec visitor-analytics-app php artisan db:seed --class=VisitorAnalyticsSeeder --force 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to seed database"
        exit 1
    }
    Write-Success "Database seeded with sample data"
    
    # Optimize Laravel
    Write-Info "Optimizing Laravel application..."
    docker exec visitor-analytics-app php artisan config:cache 2>$null
    docker exec visitor-analytics-app php artisan route:cache 2>$null
    docker exec visitor-analytics-app php artisan view:cache 2>$null
    
    Write-Success "Laravel application setup completed"
}

# Verify installation
function Test-Installation {
    Write-Info "Verifying installation..."
    
    # Test API endpoints
    Start-Sleep 3
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8000/api/summary" -Method Get -TimeoutSec 10 -ErrorAction Stop
        if ($response) {
            Write-Success "API is responding correctly"
            Write-Info "Sample data loaded:"
            Write-Host "  - Total Visitors: $($response.total_visitors)"
            Write-Host "  - Active Locations: $($response.total_locations)"
            Write-Host "  - Active Sensors: $($response.active_sensors)"
        }
    }
    catch {
        Write-Warning "API test failed, but services may still be starting up"
        Write-Info "You can test manually at: http://localhost:8000/api/summary"
    }
}

# Main execution
Write-Host @"
=================================================================
    Laravel Visitor Analytics - Automated Setup
=================================================================
"@ -ForegroundColor Magenta

# Check prerequisites
Test-Docker
Test-DockerCompose

# Clean up if requested
if ($Clean) {
    Invoke-Cleanup
}

# Create environment file
New-EnvFile

# Start Docker services
Start-DockerServices

# Initialize Laravel application
Initialize-LaravelApp

# Verify installation
Test-Installation

# Final success message
Write-Host ""
Write-Success "Your Laravel Visitor Analytics application is ready to use!"
Write-Host ""
Write-Info "Available endpoints:"
Write-Host "  - Application: http://localhost:8000"
Write-Host "  - API Summary: http://localhost:8000/api/summary"
Write-Host "  - API Locations: http://localhost:8000/api/locations"
Write-Host "  - API Sensors: http://localhost:8000/api/sensors"
Write-Host "  - API Visitors: http://localhost:8000/api/visitors"
Write-Host ""
Write-Info "Useful commands:"
Write-Host "  - View logs: docker-compose logs -f"
Write-Host "  - Stop services: docker-compose down"
Write-Host "  - Run tests: docker exec visitor-analytics-app php artisan test"
Write-Host ""
Write-Success "Setup completed successfully!" 
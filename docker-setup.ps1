# Function to print status messages
function Write-Status {
    param($Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
}

# Function to check if a command exists
function Test-Command {
    param($Command)
    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

# Check required commands
Write-Status "Checking required commands..."
if (-not (Test-Command docker)) {
    Write-Host "Error: Docker is required but not installed." -ForegroundColor Red
    exit 1
}
if (-not (Test-Command docker-compose)) {
    Write-Host "Error: Docker Compose is required but not installed." -ForegroundColor Red
    exit 1
}

# Create necessary directories
Write-Status "Creating required directories..."
New-Item -ItemType Directory -Force -Path "docker/mysql" | Out-Null
New-Item -ItemType Directory -Force -Path "docker/redis" | Out-Null

# Set proper permissions
Write-Status "Setting directory permissions..."
$acl = Get-Acl "docker"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","FullControl","ContainerInherit,ObjectInherit","None","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl "docker" $acl

# Copy environment file if it doesn't exist
if (-not (Test-Path .env)) {
    Write-Status "Creating .env file from .env.example..."
    Copy-Item .env.example .env
} else {
    Write-Status ".env file already exists"
}

# Stop any running containers
Write-Status "Stopping any running containers..."
docker-compose down

# Build and start containers
Write-Status "Building and starting containers..."
docker-compose up -d --build

# Wait for containers to be ready
Write-Status "Waiting for containers to be ready..."
Start-Sleep -Seconds 10

# Install dependencies
Write-Status "Installing PHP dependencies..."
docker-compose exec -T app composer install --no-interaction

# Generate application key
Write-Status "Generating application key..."
docker-compose exec -T app php artisan key:generate

# Run migrations
Write-Status "Running database migrations..."
docker-compose exec -T app php artisan migrate --force

# Clear cache
Write-Status "Clearing application cache..."
docker-compose exec -T app php artisan config:clear
docker-compose exec -T app php artisan cache:clear
docker-compose exec -T app php artisan route:clear
docker-compose exec -T app php artisan view:clear

# Check if containers are running
Write-Status "Checking container status..."
docker-compose ps

Write-Status "Setup completed! Your application is running at http://localhost:8000"
Write-Status "You can check the logs using: docker-compose logs -f"

docker exec -it visitor-analytics-app php artisan migrate
docker exec -it visitor-analytics-app php artisan db:seed 
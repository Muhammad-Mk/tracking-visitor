#!/usr/bin/env pwsh

# Laravel Visitor Analytics - Complete Setup Script
# This script will set up the entire project including Docker containers, database, and seeding

param(
    [switch]$Clean,
    [switch]$SkipBuild,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Laravel Visitor Analytics Setup Script

USAGE:
    ./setup.ps1 [OPTIONS]

OPTIONS:
    -Clean      Clean up existing containers and volumes before setup
    -SkipBuild  Skip Docker image building (use existing images)
    -Help       Show this help message

EXAMPLES:
    ./setup.ps1                 # Normal setup
    ./setup.ps1 -Clean          # Clean setup (removes existing data)
    ./setup.ps1 -SkipBuild      # Quick setup without rebuilding images

"@ -ForegroundColor Cyan
    exit 0
}

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║              Laravel Visitor Analytics Setup                ║
║                     Complete Installation                   ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Green

# Function to check if command exists
function Test-Command($command) {
    try {
        Get-Command $command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to wait for service
function Wait-ForService($serviceName, $port, $maxAttempts = 30) {
    Write-Host "⏳ Waiting for $serviceName to be ready..." -ForegroundColor Yellow
    
    for ($i = 1; $i -le $maxAttempts; $i++) {
        try {
            $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
            if ($connection.TcpTestSucceeded) {
                Write-Host "✅ $serviceName is ready!" -ForegroundColor Green
                return $true
            }
        }
        catch {
            # Continue waiting
        }
        
        Write-Host "   Attempt $i/$maxAttempts - $serviceName not ready yet..." -ForegroundColor Gray
        Start-Sleep -Seconds 2
    }
    
    Write-Host "❌ $serviceName failed to start within expected time" -ForegroundColor Red
    return $false
}

# Step 1: Prerequisites Check
Write-Host "`n🔍 Checking Prerequisites..." -ForegroundColor Cyan

$prerequisites = @(
    @{Name="Docker"; Command="docker"; Required=$true},
    @{Name="Docker Compose"; Command="docker-compose"; Required=$true}
)

$missingPrereqs = @()
foreach ($prereq in $prerequisites) {
    if (Test-Command $prereq.Command) {
        Write-Host "✅ $($prereq.Name) is installed" -ForegroundColor Green
    } else {
        Write-Host "❌ $($prereq.Name) is not installed" -ForegroundColor Red
        if ($prereq.Required) {
            $missingPrereqs += $prereq.Name
        }
    }
}

if ($missingPrereqs.Count -gt 0) {
    Write-Host "`n❌ Missing required prerequisites: $($missingPrereqs -join ', ')" -ForegroundColor Red
    Write-Host "Please install the missing prerequisites and run the setup again." -ForegroundColor Yellow
    exit 1
}

# Step 2: Environment Setup
Write-Host "`n🔧 Setting up Environment..." -ForegroundColor Cyan

if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env file..." -ForegroundColor Yellow
    
    $envContent = @"
APP_NAME="Visitor Analytics"
APP_ENV=local
APP_KEY=base64:$(([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((1..32 | ForEach-Object { [char]((65..90) + (97..122) | Get-Random) }) -join ''))))
APP_DEBUG=true
APP_TIMEZONE=UTC
APP_URL=http://localhost:8000

APP_LOCALE=en
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=en_US

APP_MAINTENANCE_DRIVER=file
APP_MAINTENANCE_STORE=database

BCRYPT_ROUNDS=12

LOG_CHANNEL=stack
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=visitor_analytics
DB_USERNAME=visitor_user
DB_PASSWORD=visitor_password

SESSION_DRIVER=redis
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=null

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=redis

CACHE_STORE=redis
CACHE_PREFIX=

REDIS_CLIENT=phpredis
REDIS_HOST=redis
REDIS_PASSWORD=visitor_redis_password
REDIS_PORT=6385

MAIL_MAILER=log
MAIL_HOST=127.0.0.1
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="\${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

VITE_APP_NAME="\${APP_NAME}"
"@
    
    $envContent | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "✅ .env file created successfully" -ForegroundColor Green
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}

# Step 3: Docker Setup
Write-Host "`n🐳 Setting up Docker Environment..." -ForegroundColor Cyan

if ($Clean) {
    Write-Host "🧹 Cleaning up existing containers and volumes..." -ForegroundColor Yellow
    docker-compose down -v --remove-orphans 2>$null
    docker system prune -f 2>$null
    Write-Host "✅ Cleanup completed" -ForegroundColor Green
}

# Build and start containers
if ($SkipBuild) {
    Write-Host "⚡ Starting containers (skipping build)..." -ForegroundColor Yellow
    docker-compose up -d
} else {
    Write-Host "🔨 Building and starting containers..." -ForegroundColor Yellow
    docker-compose up -d --build
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to start Docker containers" -ForegroundColor Red
    exit 1
}

# Step 4: Wait for Services
Write-Host "`n⏳ Waiting for services to be ready..." -ForegroundColor Cyan

$services = @(
    @{Name="MySQL Database"; Port=3306},
    @{Name="Redis Cache"; Port=6385},
    @{Name="Laravel Application"; Port=8000}
)

foreach ($service in $services) {
    if (-not (Wait-ForService $service.Name $service.Port)) {
        Write-Host "❌ Setup failed - $($service.Name) is not responding" -ForegroundColor Red
        exit 1
    }
}

# Step 5: Laravel Setup
Write-Host "`n🚀 Setting up Laravel Application..." -ForegroundColor Cyan

Write-Host "📦 Installing Composer dependencies..." -ForegroundColor Yellow
docker exec visitor-analytics-app composer install --no-dev --optimize-autoloader

Write-Host "🔑 Generating application key..." -ForegroundColor Yellow
docker exec visitor-analytics-app php artisan key:generate --force

Write-Host "🗄️ Running database migrations..." -ForegroundColor Yellow
docker exec visitor-analytics-app php artisan migrate --force

Write-Host "🌱 Seeding database with sample data..." -ForegroundColor Yellow
docker exec visitor-analytics-app php artisan db:seed --force

Write-Host "🧹 Optimizing application..." -ForegroundColor Yellow
docker exec visitor-analytics-app php artisan config:cache
docker exec visitor-analytics-app php artisan route:cache
docker exec visitor-analytics-app php artisan view:cache

# Step 6: Verification
Write-Host "`n✅ Verifying Installation..." -ForegroundColor Cyan

try {
    $healthCheck = Invoke-RestMethod -Uri "http://localhost:8000/api/analytics/summary" -Method GET -TimeoutSec 10
    if ($healthCheck.total_visitors -ge 0) {
        Write-Host "✅ API is responding correctly" -ForegroundColor Green
        Write-Host "   📊 Total visitors in system: $($healthCheck.total_visitors)" -ForegroundColor Cyan
        Write-Host "   🏢 Locations: $($healthCheck.locations_count)" -ForegroundColor Cyan
        Write-Host "   📡 Active sensors: $($healthCheck.active_sensors_count)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "⚠️  API health check failed, but containers are running" -ForegroundColor Yellow
}

# Step 7: Success Message
Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║                    🎉 SETUP COMPLETE! 🎉                    ║
╚══════════════════════════════════════════════════════════════╝

🌐 Application URL: http://localhost:8000
📊 API Endpoints:
   • GET  /api/locations          - List all locations (with pagination)
   • GET  /api/sensors            - List all sensors (with pagination)  
   • GET  /api/visitors           - List all visitors (with pagination)
   • GET  /api/analytics/summary  - Analytics summary
   • GET  /api/analytics/location-stats - Location statistics

🐳 Docker Containers:
   • visitor-analytics-app   (Laravel App)    - Port 8000
   • visitor-analytics-db    (MySQL 8.0)      - Port 3306  
   • visitor-analytics-redis (Redis)          - Port 6385

🔧 Management Commands:
   • docker-compose logs -f                   - View logs
   • docker-compose down                      - Stop containers
   • docker-compose up -d                     - Start containers
   • docker exec visitor-analytics-app php artisan tinker - Laravel console

📚 Documentation: See README.md for detailed information

"@ -ForegroundColor Green

Write-Host "🚀 Your Laravel Visitor Analytics application is ready to use!" -ForegroundColor Green 
#!/bin/bash

# Laravel Visitor Analytics - Complete Setup Script (Linux/macOS)
# This script will set up the entire project including Docker containers, database, and seeding

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse command line arguments
CLEAN=false
SKIP_BUILD=false
HELP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN=true
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --help)
            HELP=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

if [ "$HELP" = true ]; then
    echo -e "${CYAN}Laravel Visitor Analytics Setup Script

USAGE:
    ./setup.sh [OPTIONS]

OPTIONS:
    --clean      Clean up existing containers and volumes before setup
    --skip-build Skip Docker image building (use existing images)
    --help       Show this help message

EXAMPLES:
    ./setup.sh                 # Normal setup
    ./setup.sh --clean         # Clean setup (removes existing data)
    ./setup.sh --skip-build    # Quick setup without rebuilding images
${NC}"
    exit 0
fi

echo -e "${GREEN}
╔══════════════════════════════════════════════════════════════╗
║              Laravel Visitor Analytics Setup                ║
║                     Complete Installation                   ║
╚══════════════════════════════════════════════════════════════╝
${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for service
wait_for_service() {
    local service_name=$1
    local port=$2
    local max_attempts=${3:-30}
    
    echo -e "${YELLOW}⏳ Waiting for $service_name to be ready...${NC}"
    
    for ((i=1; i<=max_attempts; i++)); do
        if nc -z localhost $port 2>/dev/null; then
            echo -e "${GREEN}✅ $service_name is ready!${NC}"
            return 0
        fi
        
        echo -e "   Attempt $i/$max_attempts - $service_name not ready yet..."
        sleep 2
    done
    
    echo -e "${RED}❌ $service_name failed to start within expected time${NC}"
    return 1
}

# Step 1: Prerequisites Check
echo -e "\n${CYAN}🔍 Checking Prerequisites...${NC}"

prerequisites=("docker" "docker-compose" "nc")
missing_prereqs=()

for prereq in "${prerequisites[@]}"; do
    if command_exists "$prereq"; then
        echo -e "${GREEN}✅ $prereq is installed${NC}"
    else
        echo -e "${RED}❌ $prereq is not installed${NC}"
        missing_prereqs+=("$prereq")
    fi
done

if [ ${#missing_prereqs[@]} -gt 0 ]; then
    echo -e "\n${RED}❌ Missing required prerequisites: ${missing_prereqs[*]}${NC}"
    echo -e "${YELLOW}Please install the missing prerequisites and run the setup again.${NC}"
    exit 1
fi

# Step 2: Environment Setup
echo -e "\n${CYAN}🔧 Setting up Environment...${NC}"

if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📝 Creating .env file...${NC}"
    
    # Generate a random APP_KEY
    APP_KEY=$(openssl rand -base64 32)
    
    cat > .env << EOF
APP_NAME="Visitor Analytics"
APP_ENV=local
APP_KEY=base64:$APP_KEY
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
EOF
    
    echo -e "${GREEN}✅ .env file created successfully${NC}"
else
    echo -e "${GREEN}✅ .env file already exists${NC}"
fi

# Step 3: Docker Setup
echo -e "\n${CYAN}🐳 Setting up Docker Environment...${NC}"

if [ "$CLEAN" = true ]; then
    echo -e "${YELLOW}🧹 Cleaning up existing containers and volumes...${NC}"
    docker-compose down -v --remove-orphans 2>/dev/null || true
    docker system prune -f 2>/dev/null || true
    echo -e "${GREEN}✅ Cleanup completed${NC}"
fi

# Build and start containers
if [ "$SKIP_BUILD" = true ]; then
    echo -e "${YELLOW}⚡ Starting containers (skipping build)...${NC}"
    docker-compose up -d
else
    echo -e "${YELLOW}🔨 Building and starting containers...${NC}"
    docker-compose up -d --build
fi

# Step 4: Wait for Services
echo -e "\n${CYAN}⏳ Waiting for services to be ready...${NC}"

services=(
    "MySQL Database:3306"
    "Redis Cache:6385"
    "Laravel Application:8000"
)

for service in "${services[@]}"; do
    IFS=':' read -r name port <<< "$service"
    if ! wait_for_service "$name" "$port"; then
        echo -e "${RED}❌ Setup failed - $name is not responding${NC}"
        exit 1
    fi
done

# Step 5: Laravel Setup
echo -e "\n${CYAN}🚀 Setting up Laravel Application...${NC}"

echo -e "${YELLOW}📦 Installing Composer dependencies...${NC}"
docker exec visitor-analytics-app composer install --no-dev --optimize-autoloader

echo -e "${YELLOW}🔑 Generating application key...${NC}"
docker exec visitor-analytics-app php artisan key:generate --force

echo -e "${YELLOW}🗄️ Running database migrations...${NC}"
docker exec visitor-analytics-app php artisan migrate --force

echo -e "${YELLOW}🌱 Seeding database with sample data...${NC}"
docker exec visitor-analytics-app php artisan db:seed --force

echo -e "${YELLOW}🧹 Optimizing application...${NC}"
docker exec visitor-analytics-app php artisan config:cache
docker exec visitor-analytics-app php artisan route:cache
docker exec visitor-analytics-app php artisan view:cache

# Step 6: Verification
echo -e "\n${CYAN}✅ Verifying Installation...${NC}"

if curl -s http://localhost:8000/api/analytics/summary >/dev/null 2>&1; then
    health_check=$(curl -s http://localhost:8000/api/analytics/summary)
    total_visitors=$(echo "$health_check" | grep -o '"total_visitors":[0-9]*' | cut -d':' -f2)
    locations_count=$(echo "$health_check" | grep -o '"locations_count":[0-9]*' | cut -d':' -f2)
    active_sensors=$(echo "$health_check" | grep -o '"active_sensors_count":[0-9]*' | cut -d':' -f2)
    
    echo -e "${GREEN}✅ API is responding correctly${NC}"
    echo -e "${CYAN}   📊 Total visitors in system: $total_visitors${NC}"
    echo -e "${CYAN}   🏢 Locations: $locations_count${NC}"
    echo -e "${CYAN}   📡 Active sensors: $active_sensors${NC}"
else
    echo -e "${YELLOW}⚠️  API health check failed, but containers are running${NC}"
fi

# Step 7: Success Message
echo -e "${GREEN}

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

${NC}"

echo -e "${GREEN}🚀 Your Laravel Visitor Analytics application is ready to use!${NC}" 
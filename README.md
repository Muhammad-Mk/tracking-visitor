# 📊 Laravel Visitor Analytics

A comprehensive visitor analytics system built with Laravel 12, featuring real-time tracking, Redis caching, and Docker containerization. Track visitor data across multiple locations with advanced analytics and reporting capabilities.

![Laravel](https://img.shields.io/badge/Laravel-12-red?style=flat-square&logo=laravel)
![PHP](https://img.shields.io/badge/PHP-8.2-blue?style=flat-square&logo=php)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange?style=flat-square&logo=mysql)
![Redis](https://img.shields.io/badge/Redis-7.0-red?style=flat-square&logo=redis)
![Docker](https://img.shields.io/badge/Docker-Containerized-blue?style=flat-square&logo=docker)

## ✨ Features

### 🚀 Core Functionality
- **Multi-Location Tracking**: Manage visitor data across multiple locations
- **Sensor Management**: Support for various sensor types (Motion, RFID, Camera, etc.)
- **Real-time Analytics**: Live visitor statistics and reporting
- **Advanced Caching**: Redis-powered caching for optimal performance
- **API Pagination**: Efficient data retrieval with configurable pagination

### 🔒 Security & Performance
- **Password-Protected Redis**: Secure Redis instance on custom port (6385)
- **Optimized Queries**: Efficient database operations with proper indexing
- **Pipeline Operations**: Redis pipeline for bulk operations
- **Input Validation**: Comprehensive validation for all API endpoints
- **Environment Variables**: Secure configuration with auto-generated passwords

### 🧪 Testing & Quality
- **Comprehensive Test Suite**: 100% controller test coverage
- **Model Factories**: Realistic test data generation
- **Database Seeding**: 30 days of sample visitor data
- **API Testing**: Complete endpoint validation

### 🐳 Infrastructure
- **Docker Containerization**: Complete Docker setup with multi-service architecture
- **MySQL 8.0**: Robust database with proper relationships
- **Redis Caching**: High-performance caching and session management
- **Automated Setup**: One-command installation with error recovery
- **Network Optimization**: Enhanced Docker networking with retry logic

## 🚀 Quick Start

### Prerequisites

- **Docker** (20.10+)
- **Docker Compose** (2.0+)
- **PowerShell** (for Windows) or **Bash** (for Linux/macOS)

### One-Command Setup

```powershell
# Clone the repository
git clone https://github.com/Muhammad-Mk/tracking-visitor.git
cd tracking-visitor

# Run the automated setup script (Windows)
./setup.ps1

# For clean installation (removes existing data)
./setup.ps1 -Clean

# For quick setup (skip Docker build)
./setup.ps1 -SkipBuild

# For help and options
./setup.ps1 -Help
```

```bash
# For Linux/macOS
./setup.sh

# Clean installation
./setup.sh --clean

# Skip build
./setup.sh --skip-build
```

### 🔧 What the Setup Script Does

The automated setup script will:
1. ✅ **Check Prerequisites**: Verify Docker and Docker Compose installation
2. 🔧 **Generate Configuration**: Create secure .env file with random passwords
3. 🧹 **Clean Environment**: Remove existing containers and networks (if -Clean flag used)
4. 🐳 **Build Containers**: Build optimized Docker images
5. 🌐 **Start Services**: Launch MySQL, Redis, and Laravel containers with network recovery
6. ⏳ **Wait for Services**: Intelligent service readiness detection
7. 📦 **Install Dependencies**: Composer packages with error handling
8. 🗄️ **Setup Database**: Run migrations and seed realistic data
9. ⚡ **Optimize Application**: Cache configuration, routes, and views
10. ✅ **Verify Installation**: Test API endpoints and display summary

### 🛠️ Enhanced Reliability Features

- **Docker Network Recovery**: Automatic network cleanup and retry logic
- **Service Health Checks**: Intelligent MySQL and Redis readiness detection
- **Error Recovery**: Comprehensive error handling with fallback options
- **Git Ownership Fix**: Automatic resolution of Docker file ownership issues
- **Timeout Management**: Optimized waiting periods for faster setup
- **Progress Feedback**: Clear status updates throughout the process

## 📊 Sample Data

After setup, your system will include:
- **5 Locations**: Realistic office locations across different cities (New York, Los Angeles, Chicago, Miami, San Francisco)
- **17 Sensors**: Various sensor types (Motion, RFID, Camera, Door Entry, Thermal, Proximity, etc.)
- **373+ Visitor Records**: 30 days of realistic visitor data with day-of-week patterns
- **9,395+ Total Visitors**: Comprehensive analytics data with special event days
- **90% Active Sensors**: Realistic operational scenarios

## 🌐 API Endpoints

### 📍 Locations
```http
GET    /api/locations              # List all locations (paginated)
POST   /api/locations              # Create new location
GET    /api/locations/{id}         # Get specific location
PUT    /api/locations/{id}         # Update location
DELETE /api/locations/{id}         # Delete location
```

### 📡 Sensors
```http
GET    /api/sensors                # List all sensors (paginated)
POST   /api/sensors                # Create new sensor
GET    /api/sensors/{id}           # Get specific sensor
PUT    /api/sensors/{id}           # Update sensor
DELETE /api/sensors/{id}           # Delete sensor
```

### 👥 Visitors
```http
GET    /api/visitors               # List all visitor records (paginated)
POST   /api/visitors               # Create visitor record
GET    /api/visitors/{id}          # Get specific visitor record
PUT    /api/visitors/{id}          # Update visitor record
DELETE /api/visitors/{id}          # Delete visitor record
```

### 📈 Analytics
```http
GET    /api/summary                # Overall analytics summary (cached)
GET    /api/location-stats         # Location-wise statistics
```

### 🔍 Query Parameters

#### Pagination
```http
GET /api/locations?per_page=10     # 10 items per page
GET /api/sensors?per_page=25       # 25 items per page (max: 100)
GET /api/visitors?per_page=50      # 50 items per page (default: 15)
```

#### Analytics Filters
```http
GET /api/summary?days=7            # Last 7 days
GET /api/summary?location_id=1     # Specific location
GET /api/location-stats?location_id=1  # Specific location stats
```

## 📝 API Examples

### Create Location
```bash
curl -X POST http://localhost:8000/api/locations \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Downtown Office",
    "address": "123 Business Street",
    "city": "New York",
    "country": "USA"
  }'
```

### Create Sensor
```bash
curl -X POST http://localhost:8000/api/sensors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Main Entrance Motion Sensor",
    "type": "Motion Sensor",
    "location_id": 1,
    "status": "active"
  }'
```

### Record Visitor Data
```bash
curl -X POST http://localhost:8000/api/visitors \
  -H "Content-Type: application/json" \
  -d '{
    "location_id": 1,
    "sensor_id": 1,
    "date": "2025-06-14",
    "count": 25
  }'
```

### Get Analytics Summary
```bash
curl http://localhost:8000/api/summary
```

**Response:**
```json
{
  "total_visitors": 1911,
  "average_visitors_per_day": 273,
  "locations_count": 5,
  "active_sensors_count": 12,
  "daily_stats": [
    {
      "date": "2025-06-08T00:00:00.000000Z",
      "total_visitors": "96",
      "locations_count": 5
    }
  ]
}
```

### Get Location Statistics
```bash
curl http://localhost:8000/api/location-stats
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "Main Office Building",
    "total_visitors": 50,
    "sensors_count": 2
  },
  {
    "id": 2,
    "name": "Branch Office Downtown",
    "total_visitors": 94,
    "sensors_count": 4
  }
]
```

## 🏗️ Architecture

### Database Schema

```sql
locations
├── id (Primary Key)
├── name
├── address
├── city
├── country
├── created_at
└── updated_at

sensors
├── id (Primary Key)
├── name
├── type
├── location_id (Foreign Key)
├── status (active/inactive)
├── created_at
└── updated_at

visitors
├── id (Primary Key)
├── location_id (Foreign Key)
├── sensor_id (Foreign Key)
├── date
├── count
├── created_at
└── updated_at
```

### Docker Services

| Service | Container Name | Port | Description |
|---------|---------------|------|-------------|
| **Laravel App** | `visitor-analytics-app` | 8000 | Main application server |
| **MySQL** | `visitor-analytics-db` | 3306 | Database server |
| **Redis** | `visitor-analytics-redis` | 6385 | Cache & session store |

### Redis Configuration
- **Port**: 6385 (custom port for security)
- **Password**: Auto-generated secure password
- **Usage**: Caching, sessions, queue management
- **Pipeline Operations**: Optimized bulk operations

## 🧪 Testing

### Run All Tests
```bash
docker exec visitor-analytics-app php artisan test
```

### Run Specific Test Suite
```bash
# Location tests
docker exec visitor-analytics-app php artisan test --filter=LocationControllerTest

# Sensor tests
docker exec visitor-analytics-app php artisan test --filter=SensorControllerTest

# Visitor tests
docker exec visitor-analytics-app php artisan test --filter=VisitorControllerTest

# Analytics tests
docker exec visitor-analytics-app php artisan test --filter=SummaryControllerTest
```

### Test Coverage
- ✅ **LocationController**: CRUD operations, pagination, validation
- ✅ **SensorController**: Sensor management with relationships
- ✅ **VisitorController**: Visitor data management
- ✅ **SummaryController**: Analytics and caching behavior

## 🔧 Development

### Manual Development Setup (Alternative)
```bash
# Start containers
docker-compose up -d

# Install dependencies
docker exec visitor-analytics-app composer install

# Run migrations
docker exec visitor-analytics-app php artisan migrate

# Seed database
docker exec visitor-analytics-app php artisan db:seed --class=VisitorAnalyticsSeeder
```

### Useful Commands
```bash
# View logs
docker-compose logs -f

# Laravel console
docker exec visitor-analytics-app php artisan tinker

# Clear cache
docker exec visitor-analytics-app php artisan cache:clear

# Run queue worker
docker exec visitor-analytics-app php artisan queue:work

# Generate new seeder data
docker exec visitor-analytics-app php artisan db:seed --class=VisitorAnalyticsSeeder --force
```

### Database Management
```bash
# Fresh migration with seeding
docker exec visitor-analytics-app php artisan migrate:fresh --seed

# Rollback migrations
docker exec visitor-analytics-app php artisan migrate:rollback

# Check migration status
docker exec visitor-analytics-app php artisan migrate:status
```

## 📈 Performance Optimization

### Redis Caching Strategy
- **Analytics Summary**: Cached for 1 hour (3600 seconds)
- **Location Stats**: Individual location caching
- **Visitor Count**: Total visitor count caching
- **Pipeline Operations**: Bulk cache operations for efficiency

### Database Optimization
- **Proper Indexing**: Optimized queries with database indexes
- **Eager Loading**: Efficient relationship loading
- **Pagination**: Memory-efficient data retrieval (default: 15, max: 100)

### Application Optimization
- **Config Caching**: Cached configuration for production
- **Route Caching**: Optimized route resolution
- **View Caching**: Compiled view templates

## 🚀 Deployment

### Production Deployment
1. **Clone and Setup**:
   ```bash
   git clone https://github.com/Muhammad-Mk/tracking-visitor.git
   cd tracking-visitor
   ./setup.ps1  # or ./setup.sh for Linux/macOS
   ```

2. **Security Configuration**:
   - Setup script auto-generates secure passwords
   - Update APP_URL for your domain
   - Configure proper CORS settings
   - Set APP_ENV=production

3. **Performance Optimization**:
   ```bash
   docker exec visitor-analytics-app php artisan config:cache
   docker exec visitor-analytics-app php artisan route:cache
   docker exec visitor-analytics-app php artisan view:cache
   ```

### Environment Variables (Auto-Generated)
```env
# Application
APP_NAME="Laravel Visitor Analytics"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database (Auto-generated secure passwords)
DB_HOST=visitor-analytics-db
DB_DATABASE=visitor_analytics
DB_USERNAME=visitor_user
DB_PASSWORD=<auto-generated-16-char-password>

# Redis (Auto-generated secure passwords)
REDIS_HOST=visitor-analytics-redis
REDIS_PASSWORD=<auto-generated-16-char-password>
REDIS_PORT=6385

# Cache & Sessions
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit changes**: `git commit -m 'Add amazing feature'`
4. **Push to branch**: `git push origin feature/amazing-feature`
5. **Open Pull Request**

### Development Guidelines
- Follow PSR-12 coding standards
- Write comprehensive tests for new features
- Update documentation for API changes
- Use meaningful commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Troubleshooting

### Common Issues & Solutions

**Setup Script Fails**:
```bash
# Clean everything and retry
./setup.ps1 -Clean

# Check Docker status
docker --version
docker-compose --version
```

**Port Already in Use**:
```bash
# Stop existing containers
docker-compose down -v

# Check port usage (Windows)
netstat -an | findstr :8000

# Check port usage (Linux/macOS)
lsof -i :8000
```

**Database Connection Issues**:
```bash
# Check container status
docker-compose ps

# View database logs
docker-compose logs visitor-analytics-db

# Test database connection
docker exec visitor-analytics-app php artisan tinker --execute="DB::connection()->getPdo();"
```

**Redis Connection Issues**:
```bash
# Check Redis container
docker exec visitor-analytics-redis redis-cli -p 6385 ping

# View Redis logs
docker-compose logs visitor-analytics-redis

# Test Redis connection
docker exec visitor-analytics-app php artisan tinker --execute="Redis::ping();"
```

**Docker Network Issues**:
```bash
# Clean Docker networks
docker network prune -f

# Restart with force recreate
docker-compose up -d --force-recreate
```

**Permission Issues (Linux/macOS)**:
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
chmod +x setup.sh
```

### Getting Help

- **GitHub Issues**: [Report bugs or request features](https://github.com/Muhammad-Mk/tracking-visitor/issues)
- **Documentation**: Check this README for comprehensive guides
- **API Testing**: Use the provided curl examples
- **Logs**: Always check `docker-compose logs -f` for detailed error information

### Performance Monitoring

```bash
# Check container resource usage
docker stats

# Monitor API response times
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8000/api/summary

# Check Redis memory usage
docker exec visitor-analytics-redis redis-cli -p 6385 info memory
```

---

**🎉 Ready to track visitors like a pro!** 

For questions or support, please open an issue on GitHub.

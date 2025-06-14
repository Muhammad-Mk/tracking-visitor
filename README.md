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

### 🧪 Testing & Quality
- **Comprehensive Test Suite**: 100% controller test coverage
- **Model Factories**: Realistic test data generation
- **Database Seeding**: 30 days of sample visitor data
- **API Testing**: Complete endpoint validation

### 🐳 Infrastructure
- **Docker Containerization**: Complete Docker setup with multi-service architecture
- **MySQL 8.0**: Robust database with proper relationships
- **Redis Caching**: High-performance caching and session management
- **Environment Configuration**: Flexible configuration management

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

# Run the setup script (Windows)
./setup.ps1

# For clean installation (removes existing data)
./setup.ps1 -Clean

# For quick setup (skip Docker build)
./setup.ps1 -SkipBuild
```

The setup script will automatically:
1. ✅ Check prerequisites
2. 🔧 Create environment configuration
3. 🐳 Build and start Docker containers
4. 🗄️ Run database migrations
5. 🌱 Seed sample data
6. ⚡ Optimize the application
7. ✅ Verify installation

## 📊 Sample Data

After setup, your system will include:
- **5 Locations**: Realistic office locations across different cities
- **17 Sensors**: Various sensor types (Motion, RFID, Camera, Door Entry, etc.)
- **373+ Visitor Records**: 30 days of realistic visitor data
- **9,395+ Total Visitors**: Comprehensive analytics data

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
GET    /api/analytics/summary      # Overall analytics summary
GET    /api/analytics/location-stats # Location-wise statistics
```

### 🔍 Query Parameters

#### Pagination
```http
GET /api/locations?per_page=10     # 10 items per page
GET /api/sensors?per_page=25       # 25 items per page (max: 100)
```

#### Analytics Filters
```http
GET /api/analytics/summary?days=7           # Last 7 days
GET /api/analytics/summary?location_id=1    # Specific location
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

### Get Analytics
```bash
curl http://localhost:8000/api/analytics/summary
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
- **Password**: `visitor_redis_password`
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

### Local Development Setup
```bash
# Start containers
docker-compose up -d

# Install dependencies
docker exec visitor-analytics-app composer install

# Run migrations
docker exec visitor-analytics-app php artisan migrate

# Seed database
docker exec visitor-analytics-app php artisan db:seed
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
docker exec visitor-analytics-app php artisan db:seed --class=VisitorAnalyticsSeeder
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
- **Analytics Summary**: Cached for 1 hour
- **Location Stats**: Cached for 1 hour
- **Individual Location Data**: Cached separately
- **Pipeline Operations**: Bulk cache operations for efficiency

### Database Optimization
- **Proper Indexing**: Optimized queries with database indexes
- **Eager Loading**: Efficient relationship loading
- **Pagination**: Memory-efficient data retrieval

### Application Optimization
- **Config Caching**: Cached configuration for production
- **Route Caching**: Optimized route resolution
- **View Caching**: Compiled view templates

## 🚀 Deployment

### Production Deployment
1. **Environment Setup**:
   ```bash
   cp .env.example .env
   # Configure production values
   ```

2. **Security Configuration**:
   - Change Redis password
   - Update database credentials
   - Set strong APP_KEY
   - Configure proper CORS settings

3. **Performance Optimization**:
   ```bash
   docker exec visitor-analytics-app php artisan config:cache
   docker exec visitor-analytics-app php artisan route:cache
   docker exec visitor-analytics-app php artisan view:cache
   ```

### Environment Variables
```env
# Application
APP_NAME="Visitor Analytics"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

# Database
DB_HOST=your-db-host
DB_DATABASE=visitor_analytics
DB_USERNAME=your-db-user
DB_PASSWORD=your-secure-password

# Redis
REDIS_HOST=your-redis-host
REDIS_PASSWORD=your-secure-redis-password
REDIS_PORT=6385

# Cache & Sessions
CACHE_STORE=redis
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

## 🆘 Support

### Common Issues

**Port Already in Use**:
```bash
# Stop existing containers
docker-compose down

# Check port usage
netstat -an | findstr :8000
```

**Database Connection Issues**:
```bash
# Check container status
docker-compose ps

# View database logs
docker-compose logs visitor-analytics-db
```

**Redis Connection Issues**:
```bash
# Test Redis connection
docker exec visitor-analytics-redis redis-cli -p 6385 -a visitor_redis_password ping
```

### Getting Help
- 📧 **Email**: [your-email@example.com]
- 🐛 **Issues**: [GitHub Issues](https://github.com/Muhammad-Mk/tracking-visitor/issues)
- 📖 **Documentation**: This README and inline code comments

## 🙏 Acknowledgments

- **Laravel Framework**: For the robust PHP framework
- **Docker**: For containerization capabilities
- **Redis**: For high-performance caching
- **MySQL**: For reliable data storage

---

**Built with ❤️ using Laravel 12, Docker, and modern development practices.**

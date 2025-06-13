# Visitor Analytics API

A Laravel 12 RESTful API for tracking visitor analytics with locations and sensors.

## Features

- CRUD operations for locations, sensors, and visitor counts
- Analytics endpoints for visitor statistics
- Redis caching for improved performance
- MySQL database with Eloquent ORM
- RESTful API design with consistent JSON responses

## Requirements

- PHP 8.2+
- MySQL 8.0+
- Redis
- Composer

## Installation

1. Clone the repository:
```bash
git clone https://github.com/Muhammad-Mk/tracking-visitor.git
cd tracking-visitor
```

2. Install dependencies:
```bash
composer install
```

3. Copy the environment file:
```bash
cp .env.example .env
```

4. Configure your database and Redis settings in `.env`:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=visitor_analytics
DB_USERNAME=your_username
DB_PASSWORD=your_password

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```

5. Run migrations:
```bash
php artisan migrate
```

6. Start the development server:
```bash
php artisan serve
```

## API Endpoints

### Locations

- `GET /api/locations` - List all locations
- `POST /api/locations` - Create a new location
- `GET /api/locations/{id}` - Get a specific location
- `PUT /api/locations/{id}` - Update a location
- `DELETE /api/locations/{id}` - Delete a location

### Sensors

- `GET /api/sensors` - List all sensors
- `POST /api/sensors` - Create a new sensor
- `GET /api/sensors/{id}` - Get a specific sensor
- `PUT /api/sensors/{id}` - Update a sensor
- `DELETE /api/sensors/{id}` - Delete a sensor

### Visitors

- `GET /api/visitors` - List all visitor records
- `POST /api/visitors` - Create a new visitor record
- `GET /api/visitors/{id}` - Get a specific visitor record
- `PUT /api/visitors/{id}` - Update a visitor record
- `DELETE /api/visitors/{id}` - Delete a visitor record

### Analytics

- `GET /api/analytics/summary` - Get visitor analytics summary
  - Query parameters:
    - `days` (optional): Number of days to include (default: 7)
    - `location_id` (optional): Filter by location ID
- `GET /api/analytics/location-stats` - Get location-wise visitor statistics

## Response Format

All endpoints return JSON responses with the following structure:

```json
{
    "data": {
        // Resource data
    }
}
```

Error responses follow this format:

```json
{
    "message": "Error message",
    "errors": {
        // Validation errors if any
    }
}
```

## Caching

The application uses Redis for caching analytics data. Cache duration is set to 1 hour (3600 seconds) for analytics endpoints.

## License

This project is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).

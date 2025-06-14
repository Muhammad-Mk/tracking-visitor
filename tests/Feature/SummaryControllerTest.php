<?php

namespace Tests\Feature;

use App\Models\Location;
use App\Models\Sensor;
use App\Models\Visitor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

class SummaryControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    public function test_can_get_analytics_summary()
    {
        // Create test data
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id, 'status' => 'active']);
        Visitor::factory()->create([
            'location_id' => $location->id,
            'sensor_id' => $sensor->id,
            'date' => now()->format('Y-m-d'),
            'count' => 10
        ]);

        $response = $this->getJson('/api/analytics/summary');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'total_visitors',
                    'average_visitors_per_day',
                    'locations_count',
                    'active_sensors_count',
                    'daily_stats' => [
                        '*' => [
                            'date',
                            'total_visitors',
                            'locations_count',
                            'sensors_count'
                        ]
                    ]
                ]);
    }

    public function test_can_get_analytics_summary_with_days_filter()
    {
        // Create test data for different days
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id, 'status' => 'active']);
        
        // Create visitor data for today and yesterday
        Visitor::factory()->create([
            'location_id' => $location->id,
            'sensor_id' => $sensor->id,
            'date' => now()->format('Y-m-d'),
            'count' => 10
        ]);
        
        Visitor::factory()->create([
            'location_id' => $location->id,
            'sensor_id' => $sensor->id,
            'date' => now()->subDays(1)->format('Y-m-d'),
            'count' => 5
        ]);

        $response = $this->getJson('/api/analytics/summary?days=1');

        $response->assertStatus(200)
                ->assertJsonFragment(['total_visitors' => 10]);
    }

    public function test_can_get_analytics_summary_with_location_filter()
    {
        // Create test data
        $location1 = Location::factory()->create();
        $location2 = Location::factory()->create();
        $sensor1 = Sensor::factory()->create(['location_id' => $location1->id, 'status' => 'active']);
        $sensor2 = Sensor::factory()->create(['location_id' => $location2->id, 'status' => 'active']);
        
        Visitor::factory()->create([
            'location_id' => $location1->id,
            'sensor_id' => $sensor1->id,
            'date' => now()->format('Y-m-d'),
            'count' => 10
        ]);
        
        Visitor::factory()->create([
            'location_id' => $location2->id,
            'sensor_id' => $sensor2->id,
            'date' => now()->format('Y-m-d'),
            'count' => 20
        ]);

        $response = $this->getJson("/api/analytics/summary?location_id={$location1->id}");

        $response->assertStatus(200)
                ->assertJsonFragment(['total_visitors' => 10]);
    }

    public function test_can_get_location_stats()
    {
        // Create test data
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id]);
        Visitor::factory()->create([
            'location_id' => $location->id,
            'sensor_id' => $sensor->id,
            'date' => now()->format('Y-m-d'),
            'count' => 15
        ]);

        $response = $this->getJson('/api/analytics/location-stats');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    '*' => [
                        'id',
                        'name',
                        'total_visitors',
                        'sensors_count'
                    ]
                ]);
    }

    public function test_analytics_summary_uses_cache()
    {
        // Clear cache first
        Cache::flush();
        
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id, 'status' => 'active']);
        Visitor::factory()->create([
            'location_id' => $location->id,
            'sensor_id' => $sensor->id,
            'date' => now()->format('Y-m-d'),
            'count' => 10
        ]);

        // First request should cache the result
        $response1 = $this->getJson('/api/analytics/summary');
        $response1->assertStatus(200);

        // Add more data
        Visitor::factory()->create([
            'location_id' => $location->id,
            'sensor_id' => $sensor->id,
            'date' => now()->format('Y-m-d'),
            'count' => 20
        ]);

        // Second request should return cached result (not updated data)
        $response2 = $this->getJson('/api/analytics/summary');
        $response2->assertStatus(200)
                 ->assertJsonFragment(['total_visitors' => 10]); // Should still be 10, not 30
    }

    public function test_location_stats_uses_cache()
    {
        // Clear cache first
        Cache::flush();
        
        $location = Location::factory()->create(['name' => 'Test Location']);
        $sensor = Sensor::factory()->create(['location_id' => $location->id]);

        // First request should cache the result
        $response1 = $this->getJson('/api/analytics/location-stats');
        $response1->assertStatus(200);

        // Create another location
        $location2 = Location::factory()->create(['name' => 'New Location']);

        // Second request should return cached result (not include new location)
        $response2 = $this->getJson('/api/analytics/location-stats');
        $response2->assertStatus(200);
        
        $data = $response2->json();
        $this->assertCount(1, $data); // Should still be 1 location due to cache
    }

    public function test_analytics_summary_with_no_data()
    {
        $response = $this->getJson('/api/analytics/summary');

        $response->assertStatus(200)
                ->assertJsonFragment([
                    'total_visitors' => 0,
                    'average_visitors_per_day' => 0,
                    'locations_count' => 0,
                    'active_sensors_count' => 0
                ]);
    }

    public function test_location_stats_with_no_data()
    {
        $response = $this->getJson('/api/analytics/location-stats');

        $response->assertStatus(200)
                ->assertJson([]);
    }
} 
<?php

namespace Tests\Feature;

use App\Models\Location;
use App\Models\Sensor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class SensorControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    public function test_can_get_sensors_list()
    {
        $location = Location::factory()->create();
        Sensor::factory()->count(3)->create(['location_id' => $location->id]);

        $response = $this->getJson('/api/sensors');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'data' => [
                        '*' => [
                            'id',
                            'name',
                            'status',
                            'location_id',
                            'location',
                            'created_at',
                            'updated_at'
                        ]
                    ]
                ]);
    }

    public function test_can_get_sensors_with_pagination()
    {
        $location = Location::factory()->create();
        Sensor::factory()->count(20)->create(['location_id' => $location->id]);

        $response = $this->getJson('/api/sensors?per_page=5');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'data',
                    'links',
                    'meta'
                ]);
    }

    public function test_can_create_sensor()
    {
        $location = Location::factory()->create();
        $sensorData = [
            'name' => 'Test Sensor',
            'location_id' => $location->id,
            'status' => 'active'
        ];

        $response = $this->postJson('/api/sensors', $sensorData);

        $response->assertStatus(201)
                ->assertJsonFragment([
                    'name' => 'Test Sensor',
                    'status' => 'active'
                ]);

        $this->assertDatabaseHas('sensors', $sensorData);
    }

    public function test_can_show_sensor()
    {
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id]);

        $response = $this->getJson("/api/sensors/{$sensor->id}");

        $response->assertStatus(200)
                ->assertJsonFragment([
                    'id' => $sensor->id,
                    'name' => $sensor->name
                ]);
    }

    public function test_can_update_sensor()
    {
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id]);
        $updateData = [
            'name' => 'Updated Sensor',
            'location_id' => $location->id,
            'status' => 'inactive'
        ];

        $response = $this->putJson("/api/sensors/{$sensor->id}", $updateData);

        $response->assertStatus(200)
                ->assertJsonFragment(['name' => 'Updated Sensor']);

        $this->assertDatabaseHas('sensors', $updateData);
    }

    public function test_can_delete_sensor()
    {
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id]);

        $response = $this->deleteJson("/api/sensors/{$sensor->id}");

        $response->assertStatus(204);
        $this->assertDatabaseMissing('sensors', ['id' => $sensor->id]);
    }

    public function test_sensor_validation_fails_with_invalid_data()
    {
        $response = $this->postJson('/api/sensors', []);

        $response->assertStatus(422)
                ->assertJsonValidationErrors(['name', 'location_id', 'status']);
    }

    public function test_sensor_validation_fails_with_invalid_location()
    {
        $sensorData = [
            'name' => 'Test Sensor',
            'location_id' => 999,
            'status' => 'active'
        ];

        $response = $this->postJson('/api/sensors', $sensorData);

        $response->assertStatus(422)
                ->assertJsonValidationErrors(['location_id']);
    }

    public function test_sensor_not_found_returns_404()
    {
        $response = $this->getJson('/api/sensors/999');

        $response->assertStatus(404);
    }
} 
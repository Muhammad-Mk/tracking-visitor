<?php

namespace Tests\Feature;

use App\Models\Location;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class LocationControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    public function test_can_get_locations_list()
    {
        // Create test locations
        Location::factory()->count(3)->create();

        $response = $this->getJson('/api/locations');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'data' => [
                        '*' => [
                            'id',
                            'name',
                            'address',
                            'city',
                            'country',
                            'created_at',
                            'updated_at'
                        ]
                    ]
                ]);
    }

    public function test_can_get_locations_with_pagination()
    {
        // Create test locations
        Location::factory()->count(20)->create();

        $response = $this->getJson('/api/locations?per_page=5');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'data',
                    'links',
                    'meta'
                ]);
    }

    public function test_can_create_location()
    {
        $locationData = [
            'name' => 'Test Location',
            'address' => '123 Test St',
            'city' => 'Test City',
            'country' => 'Test Country'
        ];

        $response = $this->postJson('/api/locations', $locationData);

        $response->assertStatus(201)
                ->assertJsonFragment($locationData);

        $this->assertDatabaseHas('locations', $locationData);
    }

    public function test_can_show_location()
    {
        $location = Location::factory()->create();

        $response = $this->getJson("/api/locations/{$location->id}");

        $response->assertStatus(200)
                ->assertJsonFragment([
                    'id' => $location->id,
                    'name' => $location->name
                ]);
    }

    public function test_can_update_location()
    {
        $location = Location::factory()->create();
        $updateData = [
            'name' => 'Updated Location',
            'address' => $location->address,
            'city' => $location->city,
            'country' => $location->country
        ];

        $response = $this->putJson("/api/locations/{$location->id}", $updateData);

        $response->assertStatus(200)
                ->assertJsonFragment(['name' => 'Updated Location']);

        $this->assertDatabaseHas('locations', $updateData);
    }

    public function test_can_delete_location()
    {
        $location = Location::factory()->create();

        $response = $this->deleteJson("/api/locations/{$location->id}");

        $response->assertStatus(204);
        $this->assertDatabaseMissing('locations', ['id' => $location->id]);
    }

    public function test_location_validation_fails_with_invalid_data()
    {
        $response = $this->postJson('/api/locations', []);

        $response->assertStatus(422)
                ->assertJsonValidationErrors(['name', 'address', 'city', 'country']);
    }

    public function test_location_not_found_returns_404()
    {
        $response = $this->getJson('/api/locations/999');

        $response->assertStatus(404);
    }
} 
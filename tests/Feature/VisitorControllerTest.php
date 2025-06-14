<?php

namespace Tests\Feature;

use App\Models\Location;
use App\Models\Sensor;
use App\Models\Visitor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class VisitorControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    public function test_can_get_visitors_list()
    {
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id]);
        Visitor::factory()->count(3)->create([
            'location_id' => $location->id,
            'sensor_id' => $sensor->id
        ]);

        $response = $this->getJson('/api/visitors');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'data' => [
                        '*' => [
                            'id',
                            'location_id',
                            'sensor_id',
                            'date',
                            'count',
                            'location',
                            'sensor',
                            'created_at',
                            'updated_at'
                        ]
                    ]
                ]);
    }

    public function test_can_get_visitors_with_pagination()
    {
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id]);
        Visitor::factory()->count(20)->create([
            'location_id' => $location->id,
            'sensor_id' => $sensor->id
        ]);

        $response = $this->getJson('/api/visitors?per_page=5');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'data',
                    'links',
                    'meta'
                ]);
    }

    public function test_can_create_visitor()
    {
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id]);
        $visitorData = [
            'location_id' => $location->id,
            'sensor_id' => $sensor->id,
            'date' => '2025-06-14',
            'count' => 10
        ];

        $response = $this->postJson('/api/visitors', $visitorData);

        $response->assertStatus(201)
                ->assertJsonFragment([
                    'count' => 10,
                    'date' => '2025-06-14'
                ]);

        $this->assertDatabaseHas('visitors', $visitorData);
    }

    public function test_can_show_visitor()
    {
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id]);
        $visitor = Visitor::factory()->create([
            'location_id' => $location->id,
            'sensor_id' => $sensor->id
        ]);

        $response = $this->getJson("/api/visitors/{$visitor->id}");

        $response->assertStatus(200)
                ->assertJsonFragment([
                    'id' => $visitor->id,
                    'count' => $visitor->count
                ]);
    }

    public function test_can_update_visitor()
    {
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id]);
        $visitor = Visitor::factory()->create([
            'location_id' => $location->id,
            'sensor_id' => $sensor->id
        ]);
        
        $updateData = [
            'location_id' => $location->id,
            'sensor_id' => $sensor->id,
            'date' => $visitor->date,
            'count' => 25
        ];

        $response = $this->putJson("/api/visitors/{$visitor->id}", $updateData);

        $response->assertStatus(200)
                ->assertJsonFragment(['count' => 25]);

        $this->assertDatabaseHas('visitors', $updateData);
    }

    public function test_can_delete_visitor()
    {
        $location = Location::factory()->create();
        $sensor = Sensor::factory()->create(['location_id' => $location->id]);
        $visitor = Visitor::factory()->create([
            'location_id' => $location->id,
            'sensor_id' => $sensor->id
        ]);

        $response = $this->deleteJson("/api/visitors/{$visitor->id}");

        $response->assertStatus(204);
        $this->assertDatabaseMissing('visitors', ['id' => $visitor->id]);
    }

    public function test_visitor_validation_fails_with_invalid_data()
    {
        $response = $this->postJson('/api/visitors', []);

        $response->assertStatus(422)
                ->assertJsonValidationErrors(['location_id', 'sensor_id', 'date', 'count']);
    }

    public function test_visitor_validation_fails_with_invalid_relationships()
    {
        $visitorData = [
            'location_id' => 999,
            'sensor_id' => 999,
            'date' => '2025-06-14',
            'count' => 10
        ];

        $response = $this->postJson('/api/visitors', $visitorData);

        $response->assertStatus(422)
                ->assertJsonValidationErrors(['location_id', 'sensor_id']);
    }

    public function test_visitor_not_found_returns_404()
    {
        $response = $this->getJson('/api/visitors/999');

        $response->assertStatus(404);
    }
} 
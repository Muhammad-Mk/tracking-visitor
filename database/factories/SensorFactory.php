<?php

namespace Database\Factories;

use App\Models\Location;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Sensor>
 */
class SensorFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $sensorTypes = [
            'Motion Sensor',
            'Door Entry Sensor',
            'Infrared Counter',
            'Pressure Mat Sensor',
            'Beam Break Sensor',
            'Camera Counter',
            'RFID Reader',
            'Bluetooth Beacon'
        ];

        return [
            'name' => fake()->randomElement($sensorTypes) . ' ' . fake()->numberBetween(1, 10),
            'location_id' => Location::factory(),
            'status' => fake()->randomElement(['active', 'inactive']),
        ];
    }
} 
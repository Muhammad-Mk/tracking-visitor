<?php

namespace Database\Seeders;

use App\Models\Location;
use App\Models\Sensor;
use App\Models\Visitor;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class VisitorAnalyticsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create default locations
        $locations = [
            [
                'name' => 'Main Office Building',
                'address' => '123 Business District',
                'city' => 'New York',
                'country' => 'USA'
            ],
            [
                'name' => 'Branch Office Downtown',
                'address' => '456 Downtown Avenue',
                'city' => 'Los Angeles',
                'country' => 'USA'
            ],
            [
                'name' => 'Corporate Headquarters',
                'address' => '789 Corporate Plaza',
                'city' => 'Chicago',
                'country' => 'USA'
            ],
            [
                'name' => 'Regional Office East',
                'address' => '321 East Side Street',
                'city' => 'Miami',
                'country' => 'USA'
            ],
            [
                'name' => 'Tech Hub Center',
                'address' => '654 Innovation Drive',
                'city' => 'San Francisco',
                'country' => 'USA'
            ]
        ];

        $createdLocations = [];
        foreach ($locations as $locationData) {
            $location = Location::create($locationData);
            $createdLocations[] = $location;
            $this->command->info("Created location: {$location->name}");
        }

        // Create sensors for each location
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

        $createdSensors = [];
        foreach ($createdLocations as $location) {
            // Create 2-4 sensors per location
            $sensorCount = rand(2, 4);
            for ($i = 0; $i < $sensorCount; $i++) {
                $sensorName = $sensorTypes[array_rand($sensorTypes)] . ' ' . ($i + 1);
                $sensor = Sensor::create([
                    'name' => $sensorName,
                    'location_id' => $location->id,
                    'status' => rand(0, 10) > 1 ? 'active' : 'inactive' // 90% active, 10% inactive
                ]);
                $createdSensors[] = $sensor;
                $this->command->info("Created sensor: {$sensor->name} at {$location->name}");
            }
        }

        // Create visitor data for the last 30 days
        $startDate = Carbon::now()->subDays(30);
        $endDate = Carbon::now();

        $this->command->info("Generating visitor data from {$startDate->format('Y-m-d')} to {$endDate->format('Y-m-d')}");

        for ($date = $startDate->copy(); $date->lte($endDate); $date->addDay()) {
            foreach ($createdSensors as $sensor) {
                // Skip some days randomly (sensors might not detect visitors every day)
                if (rand(1, 10) <= 3) continue; // 30% chance to skip

                // Generate realistic visitor counts based on day of week
                $dayOfWeek = $date->dayOfWeek;
                $baseCount = match($dayOfWeek) {
                    0, 6 => rand(2, 8),    // Weekend: lower traffic
                    1 => rand(15, 35),     // Monday: high traffic
                    2, 3, 4 => rand(20, 45), // Tue-Thu: peak traffic
                    5 => rand(10, 25),     // Friday: moderate traffic
                };

                // Add some randomness
                $count = max(1, $baseCount + rand(-5, 10));

                // Create visitor record
                Visitor::create([
                    'location_id' => $sensor->location_id,
                    'sensor_id' => $sensor->id,
                    'date' => $date->format('Y-m-d'),
                    'count' => $count
                ]);
            }
        }

        // Create some additional high-traffic days (events, meetings, etc.)
        $specialDates = [
            Carbon::now()->subDays(7),  // Last week
            Carbon::now()->subDays(14), // Two weeks ago
            Carbon::now()->subDays(21), // Three weeks ago
        ];

        foreach ($specialDates as $specialDate) {
            $randomSensors = collect($createdSensors)->random(rand(3, 6));
            foreach ($randomSensors as $sensor) {
                Visitor::create([
                    'location_id' => $sensor->location_id,
                    'sensor_id' => $sensor->id,
                    'date' => $specialDate->format('Y-m-d'),
                    'count' => rand(50, 100) // High traffic for special events
                ]);
            }
            $this->command->info("Added special event data for {$specialDate->format('Y-m-d')}");
        }

        // Summary statistics
        $totalLocations = Location::count();
        $totalSensors = Sensor::count();
        $activeSensors = Sensor::where('status', 'active')->count();
        $totalVisitorRecords = Visitor::count();
        $totalVisitorCount = Visitor::sum('count');

        $this->command->info("=== Seeding Complete ===");
        $this->command->info("Locations created: {$totalLocations}");
        $this->command->info("Sensors created: {$totalSensors} ({$activeSensors} active)");
        $this->command->info("Visitor records created: {$totalVisitorRecords}");
        $this->command->info("Total visitor count: {$totalVisitorCount}");
    }
} 
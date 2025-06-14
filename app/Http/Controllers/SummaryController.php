<?php

namespace App\Http\Controllers;

use App\Models\Location;
use App\Models\Sensor;
use App\Models\Visitor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;

class SummaryController extends Controller
{
    /**
     * Get summary of visitor analytics
     */
    public function index(Request $request): JsonResponse
    {
        $days = $request->input('days', 7);
        $locationId = $request->input('location_id');

        $cacheKey = "visitor_summary_{$days}_{$locationId}";
        
        return response()->json(Cache::remember($cacheKey, 3600, function () use ($days, $locationId, $cacheKey) {
            $query = Visitor::query()
                ->select(
                    'date',
                    DB::raw('SUM(count) as total_visitors'),
                    DB::raw('COUNT(DISTINCT location_id) as locations_count'),
                    DB::raw('COUNT(DISTINCT sensor_id) as sensors_count')
                )
                ->where('date', '>=', now()->subDays($days))
                ->groupBy('date');

            if ($locationId) {
                $query->where('location_id', $locationId);
            }

            $dailyStats = $query->get();

            $totalStats = [
                'total_visitors' => $dailyStats->sum('total_visitors'),
                'average_visitors_per_day' => $dailyStats->count() > 0 ? round($dailyStats->avg('total_visitors'), 2) : 0,
                'locations_count' => Location::count(),
                'active_sensors_count' => Sensor::where('status', 'active')->count(),
                'daily_stats' => $dailyStats,
            ];

            // Store in Redis asynchronously with additional optimization keys
            Redis::pipeline(function ($pipe) use ($cacheKey, $totalStats) {
                $pipe->setex($cacheKey, 3600, json_encode($totalStats));
                $pipe->setex('visitor_count_total', 3600, $totalStats['total_visitors']);
                $pipe->setex('locations_count_cache', 3600, $totalStats['locations_count']);
                $pipe->setex('sensors_active_count', 3600, $totalStats['active_sensors_count']);
            });

            return $totalStats;
        }));
    }

    /**
     * Get location-wise visitor statistics
     */
    public function locationStats(): JsonResponse
    {
        $cacheKey = 'location_stats';
        
        return response()->json(Cache::remember($cacheKey, 3600, function () use ($cacheKey) {
            $stats = Location::withCount(['visitors', 'sensors'])
                ->get()
                ->map(function ($location) {
                    return [
                        'id' => $location->id,
                        'name' => $location->name,
                        'total_visitors' => $location->visitors_count,
                        'sensors_count' => $location->sensors_count,
                    ];
                });

            // Store in Redis asynchronously with individual location caching
            Redis::pipeline(function ($pipe) use ($cacheKey, $stats) {
                $pipe->setex($cacheKey, 3600, json_encode($stats));
                // Cache individual location stats for faster access
                foreach ($stats as $stat) {
                    $pipe->setex("location_stat_{$stat['id']}", 3600, json_encode($stat));
                }
            });

            return $stats;
        }));
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\Location;
use App\Models\Sensor;
use App\Models\Visitor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

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
        
        return response()->json(Cache::remember($cacheKey, 3600, function () use ($days, $locationId) {
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
                'average_visitors_per_day' => $dailyStats->avg('total_visitors'),
                'locations_count' => Location::count(),
                'active_sensors_count' => Sensor::where('status', 'active')->count(),
                'daily_stats' => $dailyStats,
            ];

            return $totalStats;
        }));
    }

    /**
     * Get location-wise visitor statistics
     */
    public function locationStats(): JsonResponse
    {
        $cacheKey = 'location_stats';
        
        return response()->json(Cache::remember($cacheKey, 3600, function () {
            return Location::withCount(['visitors', 'sensors'])
                ->get()
                ->map(function ($location) {
                    return [
                        'id' => $location->id,
                        'name' => $location->name,
                        'total_visitors' => $location->visitors_count,
                        'sensors_count' => $location->sensors_count,
                    ];
                });
        }));
    }
}

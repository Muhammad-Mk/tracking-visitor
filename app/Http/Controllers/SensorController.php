<?php

namespace App\Http\Controllers;

use App\Http\Resources\SensorResource;
use App\Models\Sensor;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class SensorController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $perPage = $request->input('per_page', 15);
        $perPage = min($perPage, 100); // Limit max per page to 100
        
        $sensors = Sensor::with('location')->paginate($perPage);
        return SensorResource::collection($sensors);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): SensorResource
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'status' => 'required|in:active,inactive',
            'location_id' => 'required|exists:locations,id',
        ]);

        $sensor = Sensor::create($validated);
        return new SensorResource($sensor->load('location'));
    }

    /**
     * Display the specified resource.
     */
    public function show(Sensor $sensor): SensorResource
    {
        return new SensorResource($sensor->load('location'));
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Sensor $sensor): SensorResource
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'status' => 'required|in:active,inactive',
            'location_id' => 'required|exists:locations,id',
        ]);

        $sensor->update($validated);
        return new SensorResource($sensor->load('location'));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Sensor $sensor): Response
    {
        $sensor->delete();
        return response()->noContent();
    }
}

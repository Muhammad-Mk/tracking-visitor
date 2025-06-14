<?php

namespace App\Http\Controllers;

use App\Http\Resources\VisitorResource;
use App\Models\Visitor;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class VisitorController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $perPage = $request->input('per_page', 15);
        $perPage = min($perPage, 100); // Limit max per page to 100
        
        $visitors = Visitor::with(['location', 'sensor'])
            ->orderBy('date', 'desc')
            ->paginate($perPage);
        return VisitorResource::collection($visitors);
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
    public function store(Request $request): VisitorResource
    {
        $validated = $request->validate([
            'location_id' => 'required|exists:locations,id',
            'sensor_id' => 'required|exists:sensors,id',
            'date' => 'required|date',
            'count' => 'required|integer|min:0',
        ]);

        $visitor = Visitor::create($validated);
        return new VisitorResource($visitor->load(['location', 'sensor']));
    }

    /**
     * Display the specified resource.
     */
    public function show(Visitor $visitor): VisitorResource
    {
        return new VisitorResource($visitor->load(['location', 'sensor']));
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
    public function update(Request $request, Visitor $visitor): VisitorResource
    {
        $validated = $request->validate([
            'location_id' => 'required|exists:locations,id',
            'sensor_id' => 'required|exists:sensors,id',
            'date' => 'required|date',
            'count' => 'required|integer|min:0',
        ]);

        $visitor->update($validated);
        return new VisitorResource($visitor->load(['location', 'sensor']));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Visitor $visitor): Response
    {
        $visitor->delete();
        return response()->noContent();
    }
}

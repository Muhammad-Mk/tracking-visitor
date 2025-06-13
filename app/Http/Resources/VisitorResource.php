<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VisitorResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'location_id' => $this->location_id,
            'sensor_id' => $this->sensor_id,
            'date' => $this->date->format('Y-m-d'),
            'count' => $this->count,
            'location' => new LocationResource($this->whenLoaded('location')),
            'sensor' => new SensorResource($this->whenLoaded('sensor')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}

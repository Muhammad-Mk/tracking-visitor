<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SensorResource extends JsonResource
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
            'name' => $this->name,
            'status' => $this->status,
            'location_id' => $this->location_id,
            'location' => new LocationResource($this->whenLoaded('location')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}

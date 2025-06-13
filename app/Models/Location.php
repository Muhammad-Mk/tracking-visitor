<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Location extends Model
{
    protected $fillable = ['name'];

    public function sensors(): HasMany
    {
        return $this->hasMany(Sensor::class);
    }

    public function visitors(): HasMany
    {
        return $this->hasMany(Visitor::class);
    }
}

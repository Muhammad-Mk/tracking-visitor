<?php

use App\Http\Controllers\LocationController;
use App\Http\Controllers\SensorController;
use App\Http\Controllers\SummaryController;
use App\Http\Controllers\VisitorController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Location routes
Route::apiResource('locations', LocationController::class);

// Sensor routes
Route::apiResource('sensors', SensorController::class);

// Visitor routes
Route::apiResource('visitors', VisitorController::class);

// Analytics routes
Route::prefix('analytics')->group(function () {
    Route::get('summary', [SummaryController::class, 'index']);
    Route::get('location-stats', [SummaryController::class, 'locationStats']);
}); 
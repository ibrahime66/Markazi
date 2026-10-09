<?php

use App\Http\Controllers\Api\ActivityLogController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ClassController;
use App\Http\Controllers\Api\GuardianController;
use App\Http\Controllers\Api\MarkazController;
use App\Http\Controllers\Api\MarkazLogoController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\RecitationController;
use App\Http\Controllers\Api\StudentController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Markazi — CDC section 17
|--------------------------------------------------------------------------
| Toutes les routes hors authentification exigent un token Sanctum valide
| et sont soumises au filtre multi-tenant (CDC section 16) : le middleware
| auth:sanctum résout l'utilisateur, dont le markaz_id est ensuite appliqué
| automatiquement par le global scope Eloquent sur chaque modèle métier.
*/

Route::prefix('auth')->group(function () {
    // Limitation de débit (CDC section 17/19 : "rate limiting sur les routes
    // d'authentification") — doc/audit.md point C1 : ces routes n'étaient
    // protégées par aucun throttle, exposées à la force brute / énumération
    // de comptes. 5 tentatives par minute et par IP.
    Route::middleware('throttle:5,1')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
        Route::post('/password/forgot', [AuthController::class, 'forgotPassword']);
        Route::post('/password/reset', [AuthController::class, 'resetPassword']);
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/password/change', [AuthController::class, 'changePassword']);
    });
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/markaz', [MarkazController::class, 'show']);
    Route::put('/markaz', [MarkazController::class, 'update']);
    // Logo du Markaz (CDC §8.2 / §21), servi uniquement au Markaz concerné.
    Route::get('/markaz/logo', [MarkazLogoController::class, 'show']);
    Route::post('/markaz/logo', [MarkazLogoController::class, 'store']);
    Route::delete('/markaz/logo', [MarkazLogoController::class, 'destroy']);

    Route::apiResource('classes', ClassController::class);
    Route::apiResource('students', StudentController::class);
    Route::apiResource('guardians', GuardianController::class);

    Route::get('/attendances', [AttendanceController::class, 'index']);
    Route::post('/attendances', [AttendanceController::class, 'store']);
    Route::put('/attendances/{attendance}', [AttendanceController::class, 'update']);
    Route::delete('/attendances/{attendance}', [AttendanceController::class, 'destroy']);
    Route::get('/students/{student}/attendance-stats', [AttendanceController::class, 'statsForStudent']);

    Route::get('/recitations', [RecitationController::class, 'index']);
    Route::post('/recitations', [RecitationController::class, 'store']);
    Route::put('/recitations/{recitation}', [RecitationController::class, 'update']);
    Route::delete('/recitations/{recitation}', [RecitationController::class, 'destroy']);
    Route::get('/students/{student}/recitation-progress', [RecitationController::class, 'progressForStudent']);

    Route::get('/payments', [PaymentController::class, 'index']);
    Route::post('/payments', [PaymentController::class, 'store']);
    Route::get('/payments/{payment}', [PaymentController::class, 'show']);
    Route::patch('/payments/{payment}', [PaymentController::class, 'updateStatus']);

    Route::get('/activity-logs', [ActivityLogController::class, 'index']);
});

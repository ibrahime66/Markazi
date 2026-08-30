<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use Illuminate\Http\Request;

/**
 * CDC section 8.9 / 17 — GET /api/activity-logs : journal d'activité, lecture seule.
 */
class ActivityLogController extends Controller
{
    public function index(Request $request)
    {
        $query = ActivityLog::query()->with('user')->where('markaz_id', $request->user()->markaz_id);

        if ($entityType = $request->query('entity_type')) {
            $query->where('entity_type', $entityType);
        }

        return response()->json(
            $query->orderByDesc('created_at')->paginate($request->integer('per_page', 30))
        );
    }
}

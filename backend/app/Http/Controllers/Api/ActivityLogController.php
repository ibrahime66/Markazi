<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/**
 * CDC section 8.9 / 17 — GET /api/activity-logs : journal d'activité, lecture seule.
 *
 * Filtres (query params normalisés, CDC §17) :
 *  - `category` : famille d'action (préfixe de `action`, ex. "payment" pour
 *    payment.recorded / payment.status_updated) — plus simple à utiliser
 *    depuis l'app que `entity_type` (nom de classe PHP complet) ;
 *  - `entity_type` : conservé pour compatibilité ;
 *  - `date_from` / `date_to` : bornes sur la date réelle de l'action.
 *
 * Tri : date réelle de l'action (`performed_at`, CDC §27 — une action faite
 * hors ligne apparaît à sa date de réalisation, pas à sa date de
 * synchronisation), puis date d'écriture pour les anciennes lignes.
 */
class ActivityLogController extends Controller
{
    public const CATEGORIES = [
        'student', 'class', 'guardian', 'attendance', 'recitation',
        'payment', 'markaz', 'user', 'sync',
    ];

    public function index(Request $request)
    {
        $request->validate([
            'category' => ['nullable', Rule::in(self::CATEGORIES)],
            'date_from' => ['nullable', 'date'],
            'date_to' => ['nullable', 'date'],
        ]);

        $query = ActivityLog::query()->with('user:id,name')->where('markaz_id', $request->user()->markaz_id);

        if ($entityType = $request->query('entity_type')) {
            $query->where('entity_type', $entityType);
        }

        if ($category = $request->query('category')) {
            $query->where('action', 'like', $category.'.%');
        }

        if ($dateFrom = $request->query('date_from')) {
            $query->whereRaw('DATE(COALESCE(performed_at, created_at)) >= ?', [$dateFrom]);
        }

        if ($dateTo = $request->query('date_to')) {
            $query->whereRaw('DATE(COALESCE(performed_at, created_at)) <= ?', [$dateTo]);
        }

        return response()->json(
            $query->orderByRaw('COALESCE(performed_at, created_at) DESC')
                ->orderByDesc('id')
                ->paginate($request->integer('per_page', 30))
        );
    }
}

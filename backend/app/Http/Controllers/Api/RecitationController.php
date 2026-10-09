<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\RecitationRequest;
use App\Models\ActivityLog;
use App\Models\Recitation;
use Illuminate\Http\Request;

/**
 * CDC section 8.5 / 17 — GET/POST /api/recitations : suivi des séances de récitation.
 */
class RecitationController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', Recitation::class);

        $query = Recitation::query()->with('student');

        if ($studentId = $request->query('student_id')) {
            $query->where('student_id', $studentId);
        }

        if ($dateFrom = $request->query('date_from')) {
            $query->whereDate('date', '>=', $dateFrom);
        }

        if ($dateTo = $request->query('date_to')) {
            $query->whereDate('date', '<=', $dateTo);
        }

        return response()->json(
            $query->orderByDesc('date')->paginate($request->integer('per_page', 30))
        );
    }

    public function store(RecitationRequest $request)
    {
        $this->authorize('create', Recitation::class);

        $data = $request->validated();
        $data['recorded_by'] = $request->user()->id;

        $recitation = Recitation::create($data);

        ActivityLog::record('recitation.recorded', $recitation, 'Récitation enregistrée');

        return response()->json($recitation, 201);
    }

    /**
     * Corrige une séance de récitation déjà enregistrée (doc/audit.md, point B3).
     */
    public function update(RecitationRequest $request, int $id)
    {
        $recitation = Recitation::findOrFail($id);
        $this->authorize('update', $recitation);

        ActivityLog::recordSyncConflictIfStale($recitation, 'update');
        $recitation->update($request->validated());

        ActivityLog::record('recitation.updated', $recitation, 'Récitation corrigée');

        return response()->json($recitation);
    }

    /**
     * Supprime une séance de récitation enregistrée par erreur (doc/audit.md, point B3).
     */
    public function destroy(int $id)
    {
        $recitation = Recitation::findOrFail($id);
        $this->authorize('delete', $recitation);

        ActivityLog::recordSyncConflictIfStale($recitation, 'delete');
        $recitation->delete();

        ActivityLog::record('recitation.deleted', $recitation, 'Récitation supprimée');

        return response()->json(null, 204);
    }

    /**
     * Progression de récitation d'un élève : taux de sourates récitées sur la période.
     */
    public function progressForStudent(Request $request, int $studentId)
    {
        $this->authorize('viewAny', Recitation::class);

        $query = Recitation::where('student_id', $studentId);

        $total = (clone $query)->count();
        $recited = (clone $query)->where('status', 'recited')->count();
        $partial = (clone $query)->where('status', 'partial')->count();

        return response()->json([
            'total_sessions' => $total,
            'recited' => $recited,
            'partial' => $partial,
            'not_recited' => $total - $recited - $partial,
            'progress_rate' => $total > 0 ? round($recited / $total * 100, 1) : 0,
        ]);
    }
}

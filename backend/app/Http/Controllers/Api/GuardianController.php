<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\GuardianRequest;
use App\Models\ActivityLog;
use App\Models\Guardian;
use Illuminate\Http\Request;

/**
 * CDC section 8.3 / 18 — Gestion des parents/tuteurs.
 */
class GuardianController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', Guardian::class);

        $query = Guardian::query();

        if ($search = $request->query('search')) {
            $query->where('name', 'like', "%{$search}%")
                ->orWhere('phone', 'like', "%{$search}%");
        }

        return response()->json(
            $query->orderBy('name')->paginate($request->integer('per_page', 20))
        );
    }

    public function store(GuardianRequest $request)
    {
        $this->authorize('create', Guardian::class);

        $guardian = Guardian::create($request->validated());

        ActivityLog::record('guardian.created', $guardian, "Parent ajouté : {$guardian->name}", ['subject' => $guardian->name]);

        return response()->json($guardian, 201);
    }

    public function show(int $id)
    {
        $guardian = Guardian::with('students')->findOrFail($id);
        $this->authorize('view', $guardian);

        return response()->json($guardian);
    }

    public function update(GuardianRequest $request, int $id)
    {
        $guardian = Guardian::findOrFail($id);
        $this->authorize('update', $guardian);

        ActivityLog::recordSyncConflictIfStale($guardian, 'update');
        $guardian->update($request->validated());

        ActivityLog::record('guardian.updated', $guardian, "Parent modifié : {$guardian->name}", ['subject' => $guardian->name]);

        return response()->json($guardian);
    }

    public function destroy(int $id)
    {
        $guardian = Guardian::findOrFail($id);
        $this->authorize('delete', $guardian);

        ActivityLog::recordSyncConflictIfStale($guardian, 'delete');
        $guardian->delete();

        ActivityLog::record('guardian.deleted', $guardian, "Parent supprimé : {$guardian->name}", ['subject' => $guardian->name]);

        return response()->json(null, 204);
    }
}

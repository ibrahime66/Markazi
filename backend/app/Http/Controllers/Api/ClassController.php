<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ClassRequest;
use App\Models\ActivityLog;
use App\Models\ClassModel;
use Illuminate\Http\Request;

/**
 * CDC section 8.4 / 17 — GET/POST/PUT/DELETE /api/classes.
 */
class ClassController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', ClassModel::class);

        $query = ClassModel::query()->withCount('students');

        if ($search = $request->query('search')) {
            $query->where('name', 'like', "%{$search}%");
        }

        return response()->json(
            $query->orderBy('name')->paginate($request->integer('per_page', 20))
        );
    }

    public function store(ClassRequest $request)
    {
        $this->authorize('create', ClassModel::class);

        $class = ClassModel::create($request->validated());

        ActivityLog::record('class.created', $class, "Classe créée : {$class->name}");

        return response()->json($class, 201);
    }

    public function show(int $id)
    {
        $class = ClassModel::with('teacher')->withCount('students')->findOrFail($id);
        $this->authorize('view', $class);

        return response()->json($class);
    }

    public function update(ClassRequest $request, int $id)
    {
        $class = ClassModel::findOrFail($id);
        $this->authorize('update', $class);

        ActivityLog::recordSyncConflictIfStale($class, 'update');
        $class->update($request->validated());

        ActivityLog::record('class.updated', $class, "Classe modifiée : {$class->name}");

        return response()->json($class);
    }

    public function destroy(int $id)
    {
        $class = ClassModel::findOrFail($id);
        $this->authorize('delete', $class);

        ActivityLog::recordSyncConflictIfStale($class, 'delete');
        $class->delete();

        ActivityLog::record('class.deleted', $class, "Classe archivée : {$class->name}");

        return response()->json(null, 204);
    }
}

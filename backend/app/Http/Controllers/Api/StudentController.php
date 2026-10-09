<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StudentRequest;
use App\Models\ActivityLog;
use App\Models\Student;
use Illuminate\Http\Request;

/**
 * CDC section 8.3 / 17 — GET/POST/PUT/DELETE /api/students, recherche et filtres en query params.
 */
class StudentController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', Student::class);

        $query = Student::query()->with(['classModel', 'guardian']);

        if ($search = $request->query('search')) {
            $query->where('name', 'like', "%{$search}%");
        }

        if ($classId = $request->query('class_id')) {
            $query->where('class_id', $classId);
        }

        if ($request->has('is_active')) {
            $query->where('is_active', $request->boolean('is_active'));
        }

        return response()->json(
            $query->orderBy('name')->paginate($request->integer('per_page', 20))
        );
    }

    public function store(StudentRequest $request)
    {
        $this->authorize('create', Student::class);

        $student = Student::create($request->validated());

        ActivityLog::record('student.created', $student, "Élève ajouté : {$student->name}");

        return response()->json($student, 201);
    }

    public function show(int $id)
    {
        $student = Student::with(['classModel', 'guardian'])->findOrFail($id);
        $this->authorize('view', $student);

        return response()->json($student);
    }

    public function update(StudentRequest $request, int $id)
    {
        $student = Student::findOrFail($id);
        $this->authorize('update', $student);

        ActivityLog::recordSyncConflictIfStale($student, 'update');
        $student->update($request->validated());

        ActivityLog::record('student.updated', $student, "Élève modifié : {$student->name}");

        return response()->json($student);
    }

    /**
     * Archivage contrôlé (soft delete) — CDC 8.3 : "archivage et suppression contrôlée".
     */
    public function destroy(int $id)
    {
        $student = Student::findOrFail($id);
        $this->authorize('delete', $student);

        ActivityLog::recordSyncConflictIfStale($student, 'delete');
        $student->delete();

        ActivityLog::record('student.archived', $student, "Élève archivé : {$student->name}");

        return response()->json(null, 204);
    }
}

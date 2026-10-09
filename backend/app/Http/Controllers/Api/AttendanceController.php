<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\AttendanceRequest;
use App\Models\ActivityLog;
use App\Models\Attendance;
use App\Models\Markaz;
use App\Models\Student;
use Carbon\CarbonPeriod;
use Illuminate\Http\Request;

/**
 * CDC section 8.6 / 17 — GET/POST /api/attendances : présences par date/classe.
 */
class AttendanceController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', Attendance::class);

        $query = Attendance::query()->with('student');

        if ($studentId = $request->query('student_id')) {
            $query->where('student_id', $studentId);
        }

        if ($classId = $request->query('class_id')) {
            $query->where('class_id', $classId);
        }

        if ($date = $request->query('date')) {
            $query->whereDate('date', $date);
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

    /**
     * Marque la présence d'un élève. Un enregistrement existant pour le même
     * jour est mis à jour plutôt que dupliqué (contrainte unique student_id+date).
     */
    public function store(AttendanceRequest $request)
    {
        $this->authorize('create', Attendance::class);

        $data = $request->validated();
        $data['recorded_by'] = $request->user()->id;

        // Une présence existe déjà ce jour-là (autre appareil ou saisie
        // antérieure) : si elle est plus récente que l'action rejouée hors
        // ligne, le remplacement est tracé comme conflit (CDC §20).
        $existing = Attendance::where('student_id', $data['student_id'])
            ->whereDate('date', $data['date'])
            ->first();
        if ($existing) {
            ActivityLog::recordSyncConflictIfStale($existing, 'update');
            // Recherche par whereDate (et non updateOrCreate sur 'date') :
            // robuste quel que soit le format de stockage de la date selon
            // le moteur SQL, sinon la contrainte unique lève une erreur 500.
            $existing->update($data);
            $attendance = $existing;
        } else {
            $attendance = Attendance::create($data);
        }

        ActivityLog::record('attendance.recorded', $attendance, 'Présence enregistrée');

        return response()->json($attendance, 201);
    }

    /**
     * Corrige une présence déjà enregistrée (doc/audit.md, point B3 : cette
     * route n'existait pas, rendant impossible la correction d'une saisie
     * erronée — la contrainte unique student_id+date empêchait même de la
     * recréer).
     */
    public function update(AttendanceRequest $request, int $id)
    {
        $attendance = Attendance::findOrFail($id);
        $this->authorize('update', $attendance);

        ActivityLog::recordSyncConflictIfStale($attendance, 'update');
        $attendance->update($request->validated());

        ActivityLog::record('attendance.updated', $attendance, 'Présence corrigée');

        return response()->json($attendance);
    }

    /**
     * Supprime une présence enregistrée par erreur (doc/audit.md, point B3).
     */
    public function destroy(int $id)
    {
        $attendance = Attendance::findOrFail($id);
        $this->authorize('delete', $attendance);

        ActivityLog::recordSyncConflictIfStale($attendance, 'delete');
        $attendance->delete();

        ActivityLog::record('attendance.deleted', $attendance, 'Présence supprimée');

        return response()->json(null, 204);
    }

    /**
     * CDC 8.6 : jours de cours, présences, absences, taux — pour un élève sur une période.
     *
     * Le nombre de jours de cours n'est plus déduit des seules présences
     * déjà saisies (un jour jamais saisi n'était alors ni compté, ni
     * pénalisé) : il est calculé à partir des jours ouvrés réellement
     * configurés pour le Markaz (doc/audit.md, point F6), pour que le taux
     * reflète aussi les oublis de saisie.
     */
    public function statsForStudent(Request $request, int $studentId)
    {
        $this->authorize('viewAny', Attendance::class);

        $request->validate([
            'date_from' => ['required', 'date'],
            'date_to' => ['required', 'date', 'after_or_equal:date_from'],
        ]);

        $student = Student::with('markaz')->findOrFail($studentId);
        $this->authorize('view', $student);

        $dateFrom = $request->query('date_from');
        $dateTo = $request->query('date_to');

        // whereDate (et non whereBetween sur la colonne brute) : le dernier
        // jour de la période reste inclus quel que soit le format de
        // stockage de la date selon le moteur SQL.
        $query = Attendance::where('student_id', $studentId)
            ->whereDate('date', '>=', $dateFrom)
            ->whereDate('date', '<=', $dateTo);

        $present = (clone $query)->where('status', 'present')->count();
        // Une absence justifiée reste une absence dans les taux (CDC §8.6) ;
        // elle est aussi détaillée à part pour l'affichage.
        $absent = (clone $query)->whereIn('status', ['absent', 'justified'])->count();
        $justified = (clone $query)->where('status', 'justified')->count();
        $late = (clone $query)->where('status', 'late')->count();

        $totalCourseDays = $this->countExpectedCourseDays($student->markaz, $dateFrom, $dateTo);

        return response()->json([
            'total_days' => $totalCourseDays,
            'present' => $present,
            'absent' => $absent,
            'justified' => $justified,
            'late' => $late,
            'attendance_rate' => $totalCourseDays > 0 ? round($present / $totalCourseDays * 100, 1) : 0,
            'absence_rate' => $totalCourseDays > 0 ? round($absent / $totalCourseDays * 100, 1) : 0,
        ]);
    }

    /**
     * Compte le nombre de jours de cours réels sur une période, selon les
     * jours ouvrés configurés pour le Markaz (CDC 8.6 : "samedi/dimanche
     * non travaillés par défaut" si rien n'est configuré).
     */
    private function countExpectedCourseDays(?Markaz $markaz, string $dateFrom, string $dateTo): int
    {
        $workingDays = ! empty($markaz?->working_days)
            ? $markaz->working_days
            : ['mon', 'tue', 'wed', 'thu', 'fri'];

        $dayCodes = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

        $count = 0;
        foreach (CarbonPeriod::create($dateFrom, $dateTo) as $date) {
            // dayOfWeekIso : 1 (lundi) à 7 (dimanche).
            if (in_array($dayCodes[$date->dayOfWeekIso - 1], $workingDays, true)) {
                $count++;
            }
        }

        return $count;
    }
}

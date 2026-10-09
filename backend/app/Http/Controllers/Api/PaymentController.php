<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\PaymentRequest;
use App\Models\ActivityLog;
use App\Models\GeneratedDocument;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Validation\Rule;

/**
 * CDC section 8.7 / 17 — GET/POST /api/payments : paiements et historique.
 */
class PaymentController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', Payment::class);

        $query = Payment::query()->with('student');

        if ($studentId = $request->query('student_id')) {
            $query->where('student_id', $studentId);
        }

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        if ($dateFrom = $request->query('date_from')) {
            $query->whereDate('month', '>=', $dateFrom);
        }

        if ($dateTo = $request->query('date_to')) {
            $query->whereDate('month', '<=', $dateTo);
        }

        return response()->json(
            $query->orderByDesc('month')->paginate($request->integer('per_page', 20))
        );
    }

    /**
     * Enregistre un paiement. Détecte les doublons évidents (même élève, même
     * mois, déjà payé) et exige `confirm_duplicate=true` pour les autoriser
     * explicitement — CDC 8.7 : "détection des doublons évidents".
     */
    public function store(PaymentRequest $request)
    {
        $this->authorize('create', Payment::class);

        $data = $request->validated();
        $month = Carbon::parse($data['month'])->startOfMonth();

        $duplicate = Payment::where('student_id', $data['student_id'])
            ->whereYear('month', $month->year)
            ->whereMonth('month', $month->month)
            ->where('status', 'paid')
            ->exists();

        if ($duplicate && ! ($data['confirm_duplicate'] ?? false)) {
            // Message volontairement destiné à l'utilisateur final (affiché tel
            // quel dans le dialogue de confirmation côté app) : pas de détail
            // technique type "confirm_duplicate=true", l'app gère la ré-
            // soumission via le paramètre `duplicate` ci-dessous.
            return response()->json([
                'message' => __('Un paiement payé existe déjà pour cet élève ce mois-ci. Voulez-vous quand même enregistrer ce nouveau paiement ?'),
                'duplicate' => true,
            ], 409);
        }

        unset($data['confirm_duplicate']);
        $data['month'] = $month;
        $data['recorded_by'] = $request->user()->id;

        // Le jour exact du paiement (`paid_at`, affiché sur le reçu) est
        // fourni par l'app quand l'utilisateur le choisit explicitement ;
        // à défaut, on retombe sur "maintenant" pour un paiement créé déjà
        // marqué payé (même logique que updateStatus() ci-dessous).
        if (($data['status'] ?? null) === 'paid' && empty($data['paid_at'])) {
            $data['paid_at'] = ActivityLog::performedAt() ?? now();
        }

        $payment = Payment::create($data);

        if ($payment->status === 'paid') {
            $payment->receipt_number = GeneratedDocument::nextNumber(
                $payment->markaz_id, 'receipt', $payment, $request->user()->id,
            );
            $payment->save();
        }

        ActivityLog::record('payment.recorded', $payment, 'Paiement enregistré', [
            'amount' => $payment->amount,
            'status' => $payment->status,
        ]);

        return response()->json($payment, 201);
    }

    public function show(int $id)
    {
        $payment = Payment::with('student')->findOrFail($id);
        $this->authorize('view', $payment);

        return response()->json($payment);
    }

    /**
     * Change le statut d'un paiement déjà enregistré (ex. "en attente" →
     * "payé"). Contrairement à `store`, ceci modifie l'enregistrement
     * existant au lieu d'en créer un nouveau — corrige un bug où l'app
     * Flutter recréait un paiement en double pour marquer un statut
     * (voir doc/audit.md, point A2). Un numéro de reçu est attribué ici si
     * le paiement devient "payé" et n'en a pas encore.
     */
    public function updateStatus(Request $request, Payment $payment)
    {
        $this->authorize('update', $payment);

        $data = $request->validate([
            'status' => ['required', Rule::in(['paid', 'unpaid', 'partial'])],
        ]);

        ActivityLog::recordSyncConflictIfStale($payment, 'update');

        $wasPaid = $payment->status === 'paid';
        $payment->status = $data['status'];

        if ($payment->status === 'paid') {
            if (! $wasPaid) {
                // Hors ligne (CDC §20) : jour réel où le paiement a été marqué.
                $payment->paid_at = ActivityLog::performedAt() ?? now();
            }
            if (! $payment->receipt_number) {
                $payment->receipt_number = GeneratedDocument::nextNumber(
                    $payment->markaz_id, 'receipt', $payment, $request->user()->id,
                );
            }
        }

        $payment->save();

        ActivityLog::record('payment.status_updated', $payment, 'Statut de paiement mis à jour', [
            'status' => $payment->status,
        ]);

        return response()->json($payment);
    }
}

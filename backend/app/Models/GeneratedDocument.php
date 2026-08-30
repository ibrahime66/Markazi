<?php

namespace App\Models;

use App\Models\Concerns\BelongsToMarkaz;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\DB;

/**
 * CDC section 18 / 21 — registre polymorphique de tous les documents PDF générés.
 */
class GeneratedDocument extends Model
{
    use BelongsToMarkaz, HasFactory;

    protected $fillable = [
        'markaz_id', 'type', 'number', 'documentable_type', 'documentable_id',
        'template_version', 'file_path', 'generated_by',
    ];

    public function generatedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'generated_by');
    }

    /**
     * Génère le prochain numéro de document pour un Markaz et un type donnés,
     * au format "MK-{markaz_id}-{année}-{séquence sur 6 chiffres}" (CDC section 21),
     * ET enregistre immédiatement la ligne de registre correspondante.
     *
     * Correctif (doc/audit.md, point A2) : la version précédente calculait la
     * séquence en comptant les lignes déjà présentes dans generated_documents,
     * mais aucun code n'insérait jamais de ligne dans cette table — le compteur
     * repartait donc systématiquement de 1 et provoquait une violation de la
     * contrainte d'unicité (markaz_id, type, number) dès le deuxième reçu émis
     * dans l'année. Corrigé une première fois en créant la ligne de registre ici.
     *
     * Correctif (doc/audit.md, point D3) : compter des lignes existantes via
     * `lockForUpdate()` ne protège pas contre deux transactions concurrentes
     * qui liraient le même compte avant qu'aucune n'ait inséré (le verrou ne
     * porte que sur des lignes qui existent déjà, pas sur "la prochaine à
     * venir"). La séquence est désormais tenue dans une table dédiée
     * (`document_counters`, une ligne par Markaz/type/année) : `insertOrIgnore`
     * garantit que la ligne existe, puis `lockForUpdate()` sur cette ligne
     * réelle verrouille effectivement les lectures concurrentes le temps de
     * l'incrément — impossible que deux appels obtiennent la même séquence.
     */
    public static function nextNumber(
        int $markazId,
        string $type,
        ?Model $documentable = null,
        ?int $generatedBy = null,
    ): string {
        return DB::transaction(function () use ($markazId, $type, $documentable, $generatedBy) {
            $year = now()->year;

            DB::table('document_counters')->insertOrIgnore([
                'markaz_id' => $markazId,
                'type' => $type,
                'year' => $year,
                'sequence' => 0,
            ]);

            $counter = DB::table('document_counters')
                ->where('markaz_id', $markazId)
                ->where('type', $type)
                ->where('year', $year)
                ->lockForUpdate()
                ->first();

            $sequence = $counter->sequence + 1;

            DB::table('document_counters')->where('id', $counter->id)->update(['sequence' => $sequence]);

            $number = "MK-{$markazId}-{$year}-".str_pad((string) $sequence, 6, '0', STR_PAD_LEFT);

            static::create([
                'markaz_id' => $markazId,
                'type' => $type,
                'number' => $number,
                'documentable_type' => $documentable?->getMorphClass(),
                'documentable_id' => $documentable?->getKey(),
                'generated_by' => $generatedBy,
            ]);

            return $number;
        });
    }
}

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CDC section 18 : "soft delete (deleted_at) sur students, classes et
// payments pour l'archivage sans perte d'historique" — les deux premières
// tables l'avaient dès la conception initiale, payments non (doc/audit.md,
// point F7). Comblé ici pour la traçabilité financière exigée par le CDC
// (section 8.7 / 19) : un paiement enregistré par erreur doit pouvoir être
// archivé sans jamais disparaître réellement de l'historique.
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// doc/audit.md, point I4 : la devise était codée en dur ("FGN") dans
// l'app, bloquant pour des Markaz situés dans d'autres pays. Chaque Markaz
// configure désormais la sienne (code affiché, ex. "GNF", "XOF", "EUR" —
// pas de validation stricte ISO 4217 pour rester tolérant à un usage
// informel comme "Ar" ou "FCFA").
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('markaz', function (Blueprint $table) {
            $table->string('currency', 10)->default('GNF')->after('country');
        });
    }

    public function down(): void
    {
        Schema::table('markaz', function (Blueprint $table) {
            $table->dropColumn('currency');
        });
    }
};

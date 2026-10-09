<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CDC §20 / §27, doc/audit.md point F5 : "une action réalisée hors ligne
// apparaît dans l'historique dès la synchronisation, avec la date réelle de
// réalisation et non la date de synchronisation". `created_at` reste la date
// d'écriture serveur ; `performed_at` porte la date réelle de l'action
// (envoyée par l'app via l'en-tête X-Performed-At lors d'un rejeu, sinon
// identique à created_at).
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('activity_logs', function (Blueprint $table) {
            $table->timestamp('performed_at')->nullable()->after('meta');
            $table->index(['markaz_id', 'performed_at']);
        });
    }

    public function down(): void
    {
        Schema::table('activity_logs', function (Blueprint $table) {
            $table->dropIndex(['markaz_id', 'performed_at']);
            $table->dropColumn('performed_at');
        });
    }
};

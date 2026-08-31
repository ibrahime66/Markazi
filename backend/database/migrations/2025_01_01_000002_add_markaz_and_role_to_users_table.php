<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CDC section 9 : rôle unique "Teacher" actif en V1, modèle de rôles prévu
// pour accueillir Admin Markaz / Super Admin / Parent sans changement structurel.
// CDC section 16 : chaque compte est rattaché à un markaz_id (nullable pour un
// futur Super Admin qui opère au niveau plateforme, hors périmètre V1).
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('markaz_id')
                ->nullable()
                ->after('id')
                ->constrained('markaz')
                ->restrictOnDelete();

            $table->enum('role', ['teacher', 'admin', 'super_admin', 'parent'])
                ->default('teacher')
                ->after('email');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropConstrainedForeignId('markaz_id');
            $table->dropColumn('role');
        });
    }
};

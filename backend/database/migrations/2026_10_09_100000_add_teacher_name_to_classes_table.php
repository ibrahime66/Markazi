<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// doc/audit.md, point H5 : le formulaire de groupe collecte un "Nom de
// l'enseignant" en texte libre, mais la table n'avait qu'un `teacher_id`
// (référence vers un compte utilisateur) — le nom saisi disparaissait à la
// première resynchronisation. En V1 un seul compte maître existe par
// Markaz (CDC §9) : le texte libre correspond à l'usage réel. `teacher_id`
// est conservé pour les rôles futurs (plusieurs enseignants par Markaz).
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('classes', function (Blueprint $table) {
            $table->string('teacher_name')->nullable()->after('teacher_id');
        });
    }

    public function down(): void
    {
        Schema::table('classes', function (Blueprint $table) {
            $table->dropColumn('teacher_name');
        });
    }
};

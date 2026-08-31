<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CDC section 18 : table "parents" — parents/tuteurs des élèves.
// Nommée "guardians" côté base/modèle car "Parent" est un mot réservé du
// langage PHP (impossible de nommer une classe Eloquent "Parent").
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('guardians', function (Blueprint $table) {
            $table->id();
            $table->foreignId('markaz_id')->constrained('markaz')->restrictOnDelete();
            $table->string('name');
            $table->string('phone');
            $table->string('email')->nullable();
            $table->string('address')->nullable();
            $table->timestamps();

            $table->index(['markaz_id', 'id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('guardians');
    }
};

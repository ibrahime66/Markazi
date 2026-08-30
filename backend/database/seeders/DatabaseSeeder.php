<?php

namespace Database\Seeders;

use App\Models\ClassModel;
use App\Models\Markaz;
use App\Models\Student;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

/**
 * Jeu de données de démonstration : un Markaz, un Maître, une classe et
 * quelques élèves — de quoi tester rapidement l'API (CDC section 22).
 */
class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $markaz = Markaz::create([
            'name' => 'Markaz Al-Nour',
            'slogan' => 'Apprendre, mémoriser, transmettre',
            'city' => 'Conakry',
            'country' => 'Guinée',
            'phone' => '+224 600 00 00 00',
            'email' => 'contact@markaz-alnour.gn',
            'working_days' => ['mon', 'tue', 'wed', 'thu', 'fri'],
        ]);

        $teacher = User::create([
            'markaz_id' => $markaz->id,
            'name' => 'Ibrahime Barry',
            'email' => 'ibrahime@markazi.test',
            'password' => 'password',
            'role' => 'teacher',
        ]);

        $class = ClassModel::create([
            'markaz_id' => $markaz->id,
            'name' => 'Classe Hifz 1',
            'level' => 'Intermédiaire',
            'teacher_id' => $teacher->id,
            'max_students' => 25,
            'schedule' => 'Lun, Mer, Ven - 16h-18h',
        ]);

        foreach (['Mamadou Diallo', 'Fatoumata Camara', 'Ousmane Bah'] as $name) {
            Student::create([
                'markaz_id' => $markaz->id,
                'class_id' => $class->id,
                'name' => $name,
                'parent_phone' => '+224 6'.random_int(10000000, 99999999),
                'enrollment_date' => now()->subMonths(random_int(1, 6)),
            ]);
        }
    }
}

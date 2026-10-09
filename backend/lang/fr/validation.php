<?php

/*
| Messages de validation en français (doc/audit.md, point K8).
| Sans ce fichier, Laravel retombait sur l'anglais (fallback_locale) :
| un maître francophone voyait par exemple « The email has already been
| taken. » à l'inscription, alors que la V1 est en français (CDC §7.2).
| Seules les règles utilisées par les Form Requests de l'API sont
| traduites ; toute autre règle retombe sur l'anglais.
*/

return [
    'after_or_equal' => 'Le champ :attribute doit être une date postérieure ou égale au :date.',
    'array' => 'Le champ :attribute doit être une liste.',
    'boolean' => 'Le champ :attribute doit être vrai ou faux.',
    'confirmed' => 'La confirmation du champ :attribute ne correspond pas.',
    'current_password' => 'Le mot de passe est incorrect.',
    'date' => 'Le champ :attribute doit être une date valide.',
    'email' => 'Le champ :attribute doit être une adresse email valide.',
    'exists' => 'La valeur sélectionnée pour :attribute est invalide.',
    'gte' => [
        'numeric' => 'Le champ :attribute doit être supérieur ou égal à :value.',
    ],
    'in' => 'La valeur sélectionnée pour :attribute est invalide.',
    'integer' => 'Le champ :attribute doit être un nombre entier.',
    'max' => [
        'array' => 'Le champ :attribute ne doit pas contenir plus de :max éléments.',
        'numeric' => 'Le champ :attribute ne doit pas dépasser :max.',
        'string' => 'Le champ :attribute ne doit pas dépasser :max caractères.',
    ],
    'min' => [
        'array' => 'Le champ :attribute doit contenir au moins :min éléments.',
        'numeric' => 'Le champ :attribute doit être au moins égal à :min.',
        'string' => 'Le champ :attribute doit contenir au moins :min caractères.',
    ],
    'numeric' => 'Le champ :attribute doit être un nombre.',
    'present' => 'Le champ :attribute doit être présent.',
    'required' => 'Le champ :attribute est obligatoire.',
    'string' => 'Le champ :attribute doit être un texte.',
    'unique' => 'Cette valeur de :attribute est déjà utilisée.',

    'attributes' => [
        'address' => 'adresse',
        'amount' => 'montant',
        'ayah_from' => 'verset de début',
        'ayah_to' => 'verset de fin',
        'birth_date' => 'date de naissance',
        'city' => 'ville',
        'class_id' => 'groupe',
        'country' => 'pays',
        'current_password' => 'mot de passe actuel',
        'currency' => 'devise',
        'date' => 'date',
        'description' => 'description',
        'email' => 'email',
        'enrollment_date' => "date d'inscription",
        'gender' => 'sexe',
        'guardian_id' => 'tuteur',
        'lesson' => 'leçon',
        'level' => 'niveau',
        'markaz_address' => 'adresse du Markaz',
        'markaz_city' => 'ville du Markaz',
        'markaz_country' => 'pays du Markaz',
        'markaz_name' => 'nom du Markaz',
        'markaz_phone' => 'téléphone du Markaz',
        'max_students' => "nombre maximum d'élèves",
        'month' => 'mois',
        'name' => 'nom',
        'note' => 'note',
        'observation' => 'observation',
        'paid_at' => 'jour du paiement',
        'parent_phone' => 'téléphone du parent',
        'password' => 'mot de passe',
        'payment_mode' => 'mode de paiement',
        'phone' => 'téléphone',
        'room' => 'salle',
        'schedule' => 'emploi du temps',
        'slogan' => 'slogan',
        'status' => 'statut',
        'student_id' => 'élève',
        'surah' => 'sourate',
        'teacher_id' => 'enseignant',
        'teacher_name' => "nom de l'enseignant",
        'token' => 'code',
        'website' => 'site web',
        'working_days' => 'jours de cours',
    ],
];

<?php

declare(strict_types=1);

class Doctor
{
    public int $id;
    public string $name;
    public int $monthlyTarget;
    public ?string $preferredDay;
    public ?string $preferredTime;
    public string $consultationType;
    public ?string $availabilityNotes;
    public bool $active;

    public static function all(PDO $pdo): array
    {
        $stmt = $pdo->query('SELECT * FROM doctors WHERE active = 1 ORDER BY name');
        $doctors = [];

        foreach ($stmt as $row) {
            $doctor = new self();
            $doctor->id = (int)$row['id'];
            $doctor->name = $row['name'];
            $doctor->monthlyTarget = (int)$row['monthly_target'];
            $doctor->preferredDay = $row['preferred_day'];
            $doctor->preferredTime = $row['preferred_time'];
            $doctor->consultationType = $row['consultation_type'];
            $doctor->availabilityNotes = $row['availability_notes'];
            $doctor->active = (bool)$row['active'];
            $doctors[] = $doctor;
        }

        return $doctors;
    }
}

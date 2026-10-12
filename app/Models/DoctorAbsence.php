<?php

declare(strict_types=1);

class DoctorAbsence
{
    public static function isAbsent(PDO $pdo, int $doctorId, string $date): bool
    {
        $stmt = $pdo->prepare('SELECT COUNT(*) FROM doctor_absences WHERE doctor_id = :doctor_id AND :date BETWEEN start_date AND end_date');
        $stmt->execute([
            'doctor_id' => $doctorId,
            'date' => $date,
        ]);

        return (int)$stmt->fetchColumn() > 0;
    }

    public static function isAvailableOnDay(PDO $pdo, int $doctorId, int $weekday): bool
    {
        $stmt = $pdo->prepare('SELECT COUNT(*) FROM doctor_availability WHERE doctor_id = :doctor_id AND day_of_week = :weekday');
        $stmt->execute([
            'doctor_id' => $doctorId,
            'weekday' => $weekday,
        ]);

        return (int)$stmt->fetchColumn() > 0;
    }
}

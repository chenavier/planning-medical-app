<?php

declare(strict_types=1);

class Planner
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    public function generateMonth(int $year, int $month): void
    {
        $this->clearMonth($year, $month);

        $doctors = Doctor::all($this->pdo);
        $days = Helpers::monthDays($year, $month);

        foreach ($doctors as $doctor) {
            $assigned = 0;
            $bestDays = [];

            foreach ($days as $day) {
                if (!in_array($day['weekday'], Helpers::workingWeekdays(), true)) {
                    continue;
                }

                if ($this->isHoliday($day['date'])) {
                    continue;
                }

                if (DoctorAbsence::isAbsent($this->pdo, $doctor->id, $day['date'])) {
                    continue;
                }

                if (!DoctorAbsence::isAvailableOnDay($this->pdo, $doctor->id, $day['weekday'])) {
                    continue;
                }

                $score = $this->scoreDay($doctor, $day['weekday']);
                $bestDays[] = ['date' => $day['date'], 'score' => $score];
            }

            usort($bestDays, fn($a, $b) => $b['score'] <=> $a['score']);

            foreach ($bestDays as $candidate) {
                if ($assigned >= $doctor->monthlyTarget) {
                    break;
                }

                $slots = $this->candidateSlots($doctor, $candidate['date']);
                foreach ($slots as $slot) {
                    if ($assigned >= $doctor->monthlyTarget) {
                        break 2;
                    }

                    if ($this->canInsert($candidate['date'], $slot['start'], $slot['room'])) {
                        $this->insertSlot(
                            $doctor->id,
                            $candidate['date'],
                            $slot['start'],
                            $slot['end'],
                            $slot['room'],
                            $doctor->name,
                            $doctor->consultationType
                        );
                        $assigned++;
                    }
                }
            }
        }
    }

    public function getCalendarForMonth(int $year, int $month): array
    {
        $calendar = [];
        foreach (Helpers::monthDays($year, $month) as $day) {
            $calendar[$day['date']] = $this->getSlotsForDate($day['date']);
        }
        return $calendar;
    }

    public function getDoctorSummary(int $year, int $month): array
    {
        $stmt = $this->pdo->prepare('SELECT d.name, d.monthly_target, COUNT(gs.id) AS assigned_count FROM doctors d LEFT JOIN generated_slots gs ON d.id = gs.doctor_id AND YEAR(gs.appointment_date) = :year AND MONTH(gs.appointment_date) = :month WHERE d.active = 1 GROUP BY d.id, d.name, d.monthly_target ORDER BY d.name');
        $stmt->execute(['year' => $year, 'month' => $month]);
        return $stmt->fetchAll();
    }

    private function clearMonth(int $year, int $month): void
    {
        $stmt = $this->pdo->prepare('DELETE FROM generated_slots WHERE YEAR(appointment_date) = :year AND MONTH(appointment_date) = :month');
        $stmt->execute(['year' => $year, 'month' => $month]);
    }

    private function isHoliday(string $date): bool
    {
        $stmt = $this->pdo->prepare('SELECT COUNT(*) FROM opening_days WHERE date = :date AND is_open = 0');
        $stmt->execute(['date' => $date]);
        return (int)$stmt->fetchColumn() > 0;
    }

    private function scoreDay(Doctor $doctor, int $weekday): int
    {
        $score = 0;
        $pref = strtolower((string)$doctor->preferredDay);
        $labels = [1 => 'lundi', 2 => 'mardi', 3 => 'mercredi', 4 => 'jeudi', 5 => 'vendredi', 6 => 'samedi'];
        $target = $labels[$weekday] ?? '';

        if ($pref !== '' && str_contains($pref, $target)) {
            $score += 10;
        }

        if ($doctor->preferredTime === 'matin') {
            $score += 3;
        }

        if ($doctor->preferredTime === 'après-midi' || $doctor->preferredTime === 'apres-midi') {
            $score += 3;
        }

        return $score;
    }

    private function candidateSlots(Doctor $doctor, string $date): array
    {
        $slots = [];
        foreach ([['09:00', '10:30', 1], ['10:30', '12:00', 2], ['13:30', '15:00', 1], ['15:00', '16:30', 2]] as [$start, $end, $room]) {
            if (Helpers::preferredTimeMatches($doctor->preferredTime, $start)) {
                $slots[] = ['start' => $start, 'end' => $end, 'room' => $room];
            }
        }

        return $slots;
    }

    private function canInsert(string $date, string $startTime, int $room): bool
    {
        $stmt = $this->pdo->prepare('SELECT COUNT(*) FROM generated_slots WHERE appointment_date = :date AND start_time = :start_time AND room = :room');
        $stmt->execute(['date' => $date, 'start_time' => $startTime, 'room' => $room]);
        return (int)$stmt->fetchColumn() === 0;
    }

    private function insertSlot(int $doctorId, string $date, string $startTime, string $endTime, int $room, string $doctorName, string $consultationType): void
    {
        $stmt = $this->pdo->prepare('INSERT INTO generated_slots (doctor_id, appointment_date, day_of_week, start_time, end_time, room, consultation_label, consultation_type, status) VALUES (:doctor_id, :date, :weekday, :start_time, :end_time, :room, :label, :consultation_type, :status)');
        $stmt->execute([
            'doctor_id' => $doctorId,
            'date' => $date,
            'weekday' => (int)date('w', strtotime($date)),
            'start_time' => $startTime,
            'end_time' => $endTime,
            'room' => $room,
            'label' => $startTime . ' - ' . $doctorName . ' - Salle ' . $room,
            'consultation_type' => $consultationType,
            'status' => 'planned',
        ]);
    }

    private function getSlotsForDate(string $date): array
    {
        $stmt = $this->pdo->prepare('SELECT gs.*, d.name AS doctor_name FROM generated_slots gs INNER JOIN doctors d ON d.id = gs.doctor_id WHERE gs.appointment_date = :date ORDER BY gs.start_time, gs.room');
        $stmt->execute(['date' => $date]);
        return $stmt->fetchAll();
    }
}

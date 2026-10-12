<?php

declare(strict_types=1);

class Helpers
{
    public static function monthLabel(int $month): string
    {
        $labels = [
            1 => 'Janvier',
            2 => 'Février',
            3 => 'Mars',
            4 => 'Avril',
            5 => 'Mai',
            6 => 'Juin',
            7 => 'Juillet',
            8 => 'Août',
            9 => 'Septembre',
            10 => 'Octobre',
            11 => 'Novembre',
            12 => 'Décembre',
        ];

        return $labels[$month] ?? 'Mois';
    }

    public static function weekdayLabel(int $day): string
    {
        $labels = [
            0 => 'Dimanche',
            1 => 'Lundi',
            2 => 'Mardi',
            3 => 'Mercredi',
            4 => 'Jeudi',
            5 => 'Vendredi',
            6 => 'Samedi',
        ];

        return $labels[$day] ?? 'Jour';
    }

    public static function workingWeekdays(): array
    {
        return [1, 2, 3, 4]; // Lundi à jeudi
    }

    public static function monthDays(int $year, int $month): array
    {
        $days = [];
        $daysInMonth = cal_days_in_month(CAL_GREGORIAN, $month, $year);

        for ($day = 1; $day <= $daysInMonth; $day++) {
            $date = sprintf('%04d-%02d-%02d', $year, $month, $day);
            $timestamp = strtotime($date);
            $days[] = [
                'date' => $date,
                'day' => $day,
                'weekday' => (int)date('w', $timestamp),
                'label' => self::weekdayLabel((int)date('w', $timestamp)),
            ];
        }

        return $days;
    }

    public static function timeSlots(): array
    {
        return [
            ['09:00', '10:30', 1],
            ['10:30', '12:00', 2],
            ['13:30', '15:00', 1],
            ['15:00', '16:30', 2],
        ];
    }

    public static function normalizeDayList(?string $value): array
    {
        if ($value === null || trim($value) === '') {
            return [];
        }

        return array_map('trim', explode(',', strtolower($value)));
    }

    public static function dayMatchesPreference(?string $preferenceDay, int $weekday): bool
    {
        if ($preferenceDay === null || trim($preferenceDay) === '') {
            return true;
        }

        $dayNames = [
            1 => 'lundi',
            2 => 'mardi',
            3 => 'mercredi',
            4 => 'jeudi',
            5 => 'vendredi',
            6 => 'samedi',
            0 => 'dimanche',
        ];

        $target = $dayNames[$weekday] ?? '';
        $pref = strtolower($preferenceDay);

        if (str_contains($pref, $target)) {
            return true;
        }

        return false;
    }

    public static function preferredTimeMatches(?string $preferenceTime, string $slotStart): bool
    {
        if ($preferenceTime === null || trim($preferenceTime) === '') {
            return true;
        }

        $pref = strtolower(trim($preferenceTime));
        if ($pref === 'matin' && ($slotStart >= '09:00' && $slotStart < '12:00')) {
            return true;
        }
        if ($pref === 'après-midi' || $pref === 'apres-midi') {
            return $slotStart >= '13:30';
        }

        return true;
    }
}

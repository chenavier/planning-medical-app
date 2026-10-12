<?php

declare(strict_types=1);

class CalendarRenderer
{
    public static function renderMonth(int $year, int $month, array $calendar): string
    {
        $monthName = Helpers::monthLabel($month);

        $html = '<section class="calendar-wrap">';
        $html .= '<h2>Calendrier mensuel - ' . htmlspecialchars($monthName) . ' ' . $year . '</h2>';
        $html .= '<table class="calendar-table">';
        $html .= '<thead><tr><th>Lundi</th><th>Mardi</th><th>Mercredi</th><th>Jeudi</th></tr></thead>';
        $html .= '<tbody>';

        $days = Helpers::monthDays($year, $month);
        $weeks = [];
        $current = [];

        foreach ($days as $day) {
            if ($day['weekday'] == 1 || empty($current)) {
                $current = [];
                $weeks[] = &$current;
            }
            $current[] = $day;
        }

        foreach ($weeks as $week) {
            $html .= '<tr>';
            foreach ([1, 2, 3, 4] as $targetWeekday) {
                $found = false;
                foreach ($week as $day) {
                    if ((int)$day['weekday'] === $targetWeekday) {
                        $html .= '<td class="day-cell">';
                        $html .= '<div class="day-number">' . $day['day'] . '</div>';
                        $slots = $calendar[$day['date']] ?? [];

                        if ($slots === []) {
                            $html .= '<div class="empty">Aucun RDV</div>';
                        } else {
                            foreach ($slots as $slot) {
                                $html .= '<div class="consultation-line">' . htmlspecialchars($slot['start_time']) . ' - ' . htmlspecialchars($slot['doctor_name']) . ' - Salle ' . (int)$slot['room'] . '</div>';
                            }
                        }

                        $html .= '</td>';
                        $found = true;
                        break;
                    }
                }

                if (!$found) {
                    $html .= '<td class="day-cell empty-cell"></td>';
                }
            }
            $html .= '</tr>';
        }

        $html .= '</tbody></table>';
        $html .= '</section>';

        return $html;
    }
}

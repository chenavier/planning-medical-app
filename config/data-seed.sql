# Ce fichier contient les données de départ pour les médecins.
# Il est importé par le script SQL principal.

INSERT INTO doctors (name, monthly_target, preferred_day, preferred_time, consultation_type, availability_notes, active)
VALUES
('Médecin1', 8, 'lundi', NULL, 'Demi-journée', NULL, 1),
('Médecin2', 6, NULL, NULL, 'Demi-journée', NULL, 1),
('Médecin3', 4, 'matin', NULL, 'Demi-journée', NULL, 1),
('Médecin4', 6, NULL, NULL, 'Journée 3RDV', NULL, 1),
('Médecin5', 4, 'mardi', 'après-midi', 'Demi-journée', 'Présent du 01/10/2026 au 11/10/2026', 1),
('Médecin6', 4, 'mardi,jeudi', NULL, 'Demi-journée', NULL, 1),
('Médecin7', 16, 'mardi,mercredi,jeudi', NULL, 'Journée 4RDV', 'Pas les lundis', 1),
('Médecin8', 8, 'mercredi,jeudi', 'matin', 'Demi-journée', NULL, 1),
('Médecin9', 8, 'mercredi,jeudi', 'après-midi', 'Demi-journée', NULL, 1),
('Médecin10', 6, 'mercredi,jeudi', 'après-midi', 'Demi-journée', NULL, 1),
('Médecin11', 12, NULL, NULL, 'Demi-journée', NULL, 1),
('Médecin12', 4, 'mardi', 'matin', 'Demi-journée', 'Absent la semaine du 12/10/2026', 1),
('Médecin13', 12, NULL, NULL, 'Demi-journée', NULL, 1),
('Médecin14', 6, 'mardi,mercredi', NULL, 'Demi-journée', NULL, 1),
('Médecin15', 6, 'mardi,mercredi', NULL, 'Demi-journée', NULL, 1),
('Médecin16', 8, 'mardi,jeudi', 'matin', 'Demi-journée', NULL, 1)
ON DUPLICATE KEY UPDATE monthly_target = VALUES(monthly_target);

INSERT INTO doctor_availability (doctor_id, day_of_week, day_name, morning, afternoon, notes)
VALUES
(1, 1, 'Lundi', 0, 1, 'Lundi après-midi'),
(2, 1, 'Lundi', 1, 1, 'Disponible'),
(2, 2, 'Mardi', 1, 1, 'Disponible'),
(2, 3, 'Mercredi', 1, 1, 'Disponible'),
(2, 4, 'Jeudi', 1, 1, 'Disponible'),
(3, 1, 'Lundi', 1, 0, 'Lundi matin'),
(3, 2, 'Mardi', 1, 0, 'Matin'),
(3, 3, 'Mercredi', 1, 0, 'Matin'),
(3, 4, 'Jeudi', 1, 0, 'Matin'),
(4, 2, 'Mardi', 1, 1, 'Disponible'),
(4, 3, 'Mercredi', 1, 1, 'Disponible'),
(4, 4, 'Jeudi', 1, 1, 'Disponible'),
(5, 2, 'Mardi', 0, 1, 'Mardi après-midi uniquement'),
(6, 2, 'Mardi', 1, 1, 'Disponible'),
(6, 4, 'Jeudi', 1, 1, 'Disponible'),
(7, 2, 'Mardi', 1, 1, 'Disponible'),
(7, 3, 'Mercredi', 1, 1, 'Disponible'),
(7, 4, 'Jeudi', 1, 1, 'Disponible'),
(8, 3, 'Mercredi', 1, 0, 'Mercredi matin'),
(8, 4, 'Jeudi', 1, 0, 'Jeudi matin'),
(9, 3, 'Mercredi', 0, 1, 'Mercredi après-midi'),
(9, 4, 'Jeudi', 0, 1, 'Jeudi après-midi'),
(10, 3, 'Mercredi', 0, 1, 'Mercredi après-midi'),
(10, 4, 'Jeudi', 0, 1, 'Jeudi après-midi'),
(11, 1, 'Lundi', 1, 1, 'Disponible'),
(11, 2, 'Mardi', 1, 1, 'Disponible'),
(11, 3, 'Mercredi', 1, 1, 'Disponible'),
(11, 4, 'Jeudi', 1, 1, 'Disponible'),
(12, 2, 'Mardi', 1, 0, 'Mardi matin'),
(13, 1, 'Lundi', 1, 1, 'Disponible'),
(13, 2, 'Mardi', 1, 1, 'Disponible'),
(13, 3, 'Mercredi', 1, 1, 'Disponible'),
(13, 4, 'Jeudi', 1, 1, 'Disponible'),
(14, 2, 'Mardi', 1, 1, 'Disponible'),
(14, 3, 'Mercredi', 1, 1, 'Disponible'),
(15, 2, 'Mardi', 1, 1, 'Disponible'),
(15, 3, 'Mercredi', 1, 1, 'Disponible'),
(16, 2, 'Mardi', 1, 0, 'Mardi matin'),
(16, 4, 'Jeudi', 1, 0, 'Jeudi matin')
ON DUPLICATE KEY UPDATE day_name = VALUES(day_name);

INSERT INTO doctor_absences (doctor_id, start_date, end_date, reason, is_approved)
VALUES
(5, '2026-10-12', '2026-10-16', 'Absence planifiée', 1),
(12, '2026-10-12', '2026-10-16', 'Absent la semaine du 12/10/2026', 1)
ON DUPLICATE KEY UPDATE reason = VALUES(reason);

-- =====================================================
-- SCHEMA DE BASE DE DONNEES - PLANNING MEDICAL
-- =====================================================
-- Application de gestion du planning mensuel d'un cabinet médical
-- Avec 2 salles parallèles et contraintes de disponibilité

CREATE DATABASE IF NOT EXISTS medical_planning CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medical_planning;

-- =====================================================
-- TABLE 1: MEDECINS
-- =====================================================
CREATE TABLE IF NOT EXISTS doctors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    monthly_target INT NOT NULL DEFAULT 4,
    preferred_day VARCHAR(200) NULL COMMENT 'lundi, mardi, mercredi, jeudi, etc.',
    preferred_time VARCHAR(100) NULL COMMENT 'matin, après-midi',
    consultation_type VARCHAR(50) NOT NULL DEFAULT 'Demi-journée' COMMENT 'Demi-journée, Journée 3RDV, Journée 1RDV, Journée 4RDV',
    availability_notes TEXT NULL,
    active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_active (active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLE 2: TYPES DE CONSULTATION
-- =====================================================
CREATE TABLE IF NOT EXISTS consultation_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL UNIQUE,
    label VARCHAR(100) NOT NULL,
    slot_duration_minutes INT NOT NULL COMMENT '90 minutes standard',
    consultation_count INT NOT NULL COMMENT 'nombre de RDV dans ce type',
    description TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLE 3: PERIODES DE CONSULTATION (CRÉNEAUX HORAIRES)
-- =====================================================
CREATE TABLE IF NOT EXISTS time_periods (
    id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL UNIQUE,
    label VARCHAR(100) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    period_type VARCHAR(50) NOT NULL COMMENT 'morning, afternoon',
    description TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_period_type (period_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLE 4: JOURS D'OUVERTURE DU CABINET
-- =====================================================
CREATE TABLE IF NOT EXISTS opening_days (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE NOT NULL UNIQUE,
    year INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,
    weekday INT NOT NULL COMMENT '0=Sunday, 1=Monday, ..., 6=Saturday',
    day_name VARCHAR(20) NOT NULL,
    is_open TINYINT(1) DEFAULT 1,
    is_holiday TINYINT(1) DEFAULT 0,
    holiday_name VARCHAR(100) NULL,
    notes TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_date (date),
    INDEX idx_year_month (year, month),
    INDEX idx_is_open (is_open)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLE 5: DISPONIBILITES DES MEDECINS
-- =====================================================
CREATE TABLE IF NOT EXISTS doctor_availability (
    id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT NOT NULL,
    day_of_week INT NOT NULL COMMENT '0=Sunday, 1=Monday, ..., 6=Saturday',
    day_name VARCHAR(20) NOT NULL,
    morning TINYINT(1) DEFAULT 0 COMMENT '09:00-12:00',
    afternoon TINYINT(1) DEFAULT 0 COMMENT '13:30-16:30',
    start_time TIME NULL,
    end_time TIME NULL,
    notes TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    UNIQUE KEY unique_doctor_day (doctor_id, day_of_week),
    INDEX idx_doctor_id (doctor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLE 6: ABSENCES DES MEDECINS
-- =====================================================
CREATE TABLE IF NOT EXISTS doctor_absences (
    id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason VARCHAR(200) NULL,
    is_approved TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    INDEX idx_doctor_id (doctor_id),
    INDEX idx_dates (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLE 7: CRÉNEAUX GENERÉS (PLANNING FINAL)
-- =====================================================
CREATE TABLE IF NOT EXISTS generated_slots (
    id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    day_of_week INT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room INT NOT NULL COMMENT '1 ou 2',
    consultation_label VARCHAR(200) NOT NULL,
    consultation_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'planned' COMMENT 'planned, confirmed, cancelled, completed',
    planning_id INT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    INDEX idx_doctor_id (doctor_id),
    INDEX idx_date (appointment_date),
    INDEX idx_room (room),
    INDEX idx_status (status),
    UNIQUE KEY unique_slot (appointment_date, start_time, room)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLE 8: HISTORIQUE DES PLANNINGS GENERES
-- =====================================================
CREATE TABLE IF NOT EXISTS planning_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    month INT NOT NULL,
    year INT NOT NULL,
    generated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    generated_by VARCHAR(100) NULL,
    status VARCHAR(50) DEFAULT 'draft' COMMENT 'draft, validated, published, archived',
    total_slots INT DEFAULT 0,
    notes TEXT NULL,
    INDEX idx_year_month (year, month),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLE 9: CONFIGURATIONS GLOBALES
-- =====================================================
CREATE TABLE IF NOT EXISTS settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    description TEXT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INSERTIONS INITIALES
-- =====================================================

-- Types de consultation
INSERT INTO consultation_types (code, label, slot_duration_minutes, consultation_count, description)
VALUES 
('demi-journee', 'Demi-journée', 90, 2, '2 consultations de 1h30'),
('journee-3rdv', 'Journée 3RDV', 90, 3, '3 consultations (11h, 13h30-15h, 15h-16h30)'),
('journee-1rdv', 'Journée 1RDV', 90, 1, '1 consultation'),
('journee-4rdv', 'Journée 4RDV', 90, 4, '4 consultations (9h-10h30, 10h30-12h, 13h30-15h, 15h-16h30)')
ON DUPLICATE KEY UPDATE label=VALUES(label);

-- Périodes de consultation
INSERT INTO time_periods (code, label, start_time, end_time, period_type, description)
VALUES 
('slot-0900-1030', 'Créneau 09:00-10:30', '09:00', '10:30', 'morning', 'Matin 1h30'),
('slot-1030-1200', 'Créneau 10:30-12:00', '10:30', '12:00', 'morning', 'Matin 1h30'),
('slot-1330-1500', 'Créneau 13:30-15:00', '13:30', '15:00', 'afternoon', 'Après-midi 1h30'),
('slot-1500-1630', 'Créneau 15:00-16:30', '15:00', '16:30', 'afternoon', 'Après-midi 1h30')
ON DUPLICATE KEY UPDATE label=VALUES(label);

-- Médecins
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
ON DUPLICATE KEY UPDATE monthly_target=VALUES(monthly_target);

-- Disponibilités des médecins (jour de semaine)
INSERT INTO doctor_availability (doctor_id, day_of_week, day_name, morning, afternoon, notes)
SELECT 1, 1, 'Monday', 0, 1, 'Lundi après-midi' UNION ALL
SELECT 2, 1, 'Monday', 1, 1, 'Disponible' UNION ALL
SELECT 2, 2, 'Tuesday', 1, 1, 'Disponible' UNION ALL
SELECT 2, 3, 'Wednesday', 1, 1, 'Disponible' UNION ALL
SELECT 2, 4, 'Thursday', 1, 1, 'Disponible' UNION ALL
SELECT 3, 1, 'Monday', 1, 0, 'Lundi matin' UNION ALL
SELECT 3, 2, 'Tuesday', 1, 0, 'Matin' UNION ALL
SELECT 3, 3, 'Wednesday', 1, 0, 'Matin' UNION ALL
SELECT 3, 4, 'Thursday', 1, 0, 'Matin' UNION ALL
SELECT 4, 2, 'Tuesday', 1, 1, 'Disponible' UNION ALL
SELECT 4, 3, 'Wednesday', 1, 1, 'Disponible' UNION ALL
SELECT 4, 4, 'Thursday', 1, 1, 'Disponible' UNION ALL
SELECT 5, 2, 'Tuesday', 0, 1, 'Mardi après-midi uniquement' UNION ALL
SELECT 6, 2, 'Tuesday', 1, 1, 'Disponible' UNION ALL
SELECT 6, 4, 'Thursday', 1, 1, 'Disponible' UNION ALL
SELECT 7, 2, 'Tuesday', 1, 1, 'Disponible' UNION ALL
SELECT 7, 3, 'Wednesday', 1, 1, 'Disponible' UNION ALL
SELECT 7, 4, 'Thursday', 1, 1, 'Disponible' UNION ALL
SELECT 8, 3, 'Wednesday', 1, 0, 'Mercredi matin' UNION ALL
SELECT 8, 4, 'Thursday', 1, 0, 'Jeudi matin' UNION ALL
SELECT 9, 3, 'Wednesday', 0, 1, 'Mercredi après-midi' UNION ALL
SELECT 9, 4, 'Thursday', 0, 1, 'Jeudi après-midi' UNION ALL
SELECT 10, 3, 'Wednesday', 0, 1, 'Mercredi après-midi' UNION ALL
SELECT 10, 4, 'Thursday', 0, 1, 'Jeudi après-midi' UNION ALL
SELECT 11, 1, 'Monday', 1, 1, 'Disponible' UNION ALL
SELECT 11, 2, 'Tuesday', 1, 1, 'Disponible' UNION ALL
SELECT 11, 3, 'Wednesday', 1, 1, 'Disponible' UNION ALL
SELECT 11, 4, 'Thursday', 1, 1, 'Disponible' UNION ALL
SELECT 12, 2, 'Tuesday', 1, 0, 'Mardi matin' UNION ALL
SELECT 13, 1, 'Monday', 1, 1, 'Disponible' UNION ALL
SELECT 13, 2, 'Tuesday', 1, 1, 'Disponible' UNION ALL
SELECT 13, 3, 'Wednesday', 1, 1, 'Disponible' UNION ALL
SELECT 13, 4, 'Thursday', 1, 1, 'Disponible' UNION ALL
SELECT 14, 2, 'Tuesday', 1, 1, 'Disponible' UNION ALL
SELECT 14, 3, 'Wednesday', 1, 1, 'Disponible' UNION ALL
SELECT 15, 2, 'Tuesday', 1, 1, 'Disponible' UNION ALL
SELECT 15, 3, 'Wednesday', 1, 1, 'Disponible' UNION ALL
SELECT 16, 2, 'Tuesday', 1, 0, 'Mardi matin' UNION ALL
SELECT 16, 4, 'Thursday', 1, 0, 'Jeudi matin'
ON DUPLICATE KEY UPDATE day_name=VALUES(day_name);

-- Absences
INSERT INTO doctor_absences (doctor_id, start_date, end_date, reason, is_approved)
VALUES 
(5, '2026-10-12', '2026-10-16', 'Absence planifiée', 1),
(12, '2026-10-12', '2026-10-16', 'Absent la semaine du 12/10/2026', 1);

-- Settings
INSERT INTO settings (setting_key, setting_value, description)
VALUES 
('app_name', 'Medical Planning System', 'Nom de l\'application'),
('app_version', '1.0.0', 'Version de l\'application'),
('cabinet_name', 'Association Médicale', 'Nom du cabinet'),
('opening_time', '11:00', 'Heure d\'ouverture'),
('closing_time', '16:30', 'Heure de fermeture'),
('number_of_rooms', '2', 'Nombre de salles'),
('consultation_duration', '90', 'Durée standard d\'une consultation en minutes'),
('open_days', 'monday,tuesday,wednesday,thursday', 'Jours d\'ouverture (Monday à partir de 11h)'),
('timezone', 'Europe/Paris', 'Fuseau horaire')
ON DUPLICATE KEY UPDATE setting_value=VALUES(setting_value);

-- =====================================================
-- CREATION DES JOURS D'OUVERTURE POUR OCTOBRE 2026
-- =====================================================
-- Octobre 2026 : 1er octobre = Jeudi, ouverture lundi à partir de 11h au jeudi
-- Jours fériés en octobre : Toussaint (1er novembre n'est pas en octobre en 2026)

INSERT INTO opening_days (date, year, month, day, weekday, day_name, is_open, is_holiday, holiday_name)
SELECT 
    DATE_FORMAT(CONCAT('2026-10-', LPAD(d.day, 2, '0')), '%Y-%m-%d') AS date,
    2026 AS year,
    10 AS month,
    d.day,
    DAYOFWEEK(DATE_FORMAT(CONCAT('2026-10-', LPAD(d.day, 2, '0')), '%Y-%m-%d')) - 1 AS weekday,
    CASE DAYOFWEEK(DATE_FORMAT(CONCAT('2026-10-', LPAD(d.day, 2, '0')), '%Y-%m-%d')) - 1
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    CASE DAYOFWEEK(DATE_FORMAT(CONCAT('2026-10-', LPAD(d.day, 2, '0')), '%Y-%m-%d')) - 1
        WHEN 0 THEN 0 -- Dimanche fermé
        WHEN 1 THEN 1 -- Lundi ouvert
        WHEN 2 THEN 1 -- Mardi ouvert
        WHEN 3 THEN 1 -- Mercredi ouvert
        WHEN 4 THEN 1 -- Jeudi ouvert
        WHEN 5 THEN 0 -- Vendredi fermé
        WHEN 6 THEN 0 -- Samedi fermé
    END AS is_open,
    0 AS is_holiday,
    NULL,
    'Ouvert'
FROM 
    (SELECT 1 AS day UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
     UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 
     UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 
     UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 
     UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 
     UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 
     UNION SELECT 31) d
ON DUPLICATE KEY UPDATE day_name=VALUES(day_name);

-- =====================================================
-- CONTRAINTES ET VERROUS
-- =====================================================

-- Vérifier qu'une salle ne peut pas avoir 2 consultations au même horaire
ALTER TABLE generated_slots
ADD CONSTRAINT check_unique_slot_per_room 
UNIQUE (appointment_date, start_time, room);

-- Index pour les recherches fréquentes
CREATE INDEX idx_slots_doctor_date ON generated_slots(doctor_id, appointment_date);
CREATE INDEX idx_slots_room_date ON generated_slots(room, appointment_date);
CREATE INDEX idx_opening_days_open ON opening_days(is_open, date);

-- =====================================================
-- VIEWS UTILES
-- =====================================================

-- Vue : Planning mensuel par jour
CREATE OR REPLACE VIEW v_planning_by_day AS
SELECT 
    od.date,
    od.day_name,
    od.day,
    CONCAT(od.day_name, ' ', od.day, '/10/2026') AS display_date,
    gs.start_time,
    gs.end_time,
    gs.room,
    d.name AS doctor_name,
    gs.consultation_type,
    gs.consultation_label
FROM opening_days od
LEFT JOIN generated_slots gs ON od.date = gs.appointment_date
LEFT JOIN doctors d ON gs.doctor_id = d.id
WHERE od.year = 2026 AND od.month = 10 AND od.is_open = 1
ORDER BY od.date, gs.room, gs.start_time;

-- Vue : Charge de travail par médecin
CREATE OR REPLACE VIEW v_doctor_workload AS
SELECT 
    d.id,
    d.name,
    d.monthly_target,
    COUNT(gs.id) AS slots_assigned,
    d.monthly_target - COUNT(gs.id) AS slots_remaining,
    ROUND(COUNT(gs.id) * 100.0 / d.monthly_target, 2) AS completion_percentage
FROM doctors d
LEFT JOIN generated_slots gs ON d.id = gs.doctor_id AND YEAR(gs.appointment_date) = 2026 AND MONTH(gs.appointment_date) = 10
WHERE d.active = 1
GROUP BY d.id, d.name, d.monthly_target
ORDER BY d.name;

-- Vue : Disponibilité des salles par jour
CREATE OR REPLACE VIEW v_room_availability AS
SELECT 
    od.date,
    od.day_name,
    od.day,
    1 AS room,
    COUNT(CASE WHEN gs.room = 1 THEN 1 END) AS slots_booked,
    4 - COUNT(CASE WHEN gs.room = 1 THEN 1 END) AS slots_available
FROM opening_days od
LEFT JOIN generated_slots gs ON od.date = gs.appointment_date AND gs.room = 1
WHERE od.year = 2026 AND od.month = 10 AND od.is_open = 1
GROUP BY od.date, od.day_name, od.day
UNION ALL
SELECT 
    od.date,
    od.day_name,
    od.day,
    2 AS room,
    COUNT(CASE WHEN gs.room = 2 THEN 1 END) AS slots_booked,
    4 - COUNT(CASE WHEN gs.room = 2 THEN 1 END) AS slots_available
FROM opening_days od
LEFT JOIN generated_slots gs ON od.date = gs.appointment_date AND gs.room = 2
WHERE od.year = 2026 AND od.month = 10 AND od.is_open = 1
GROUP BY od.date, od.day_name, od.day
ORDER BY date, room;

-- =====================================================
-- FIN DU SCHEMA
-- =====================================================

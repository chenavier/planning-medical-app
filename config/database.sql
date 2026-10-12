CREATE DATABASE IF NOT EXISTS medical_planning CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medical_planning;

CREATE TABLE IF NOT EXISTS doctors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    monthly_target INT NOT NULL DEFAULT 4,
    preferred_day VARCHAR(200) NULL,
    preferred_time VARCHAR(100) NULL,
    consultation_type VARCHAR(50) NOT NULL DEFAULT 'Demi-journée',
    availability_notes TEXT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS doctor_availability (
    id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    morning TINYINT(1) NOT NULL DEFAULT 0,
    afternoon TINYINT(1) NOT NULL DEFAULT 0,
    notes TEXT NULL,
    UNIQUE KEY unique_doctor_day (doctor_id, day_of_week),
    CONSTRAINT fk_doctor_availability_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS doctor_absences (
    id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason VARCHAR(200) NULL,
    is_approved TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_doctor_absences_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS opening_days (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE NOT NULL UNIQUE,
    day_name VARCHAR(20) NOT NULL,
    is_open TINYINT(1) NOT NULL DEFAULT 1,
    is_holiday TINYINT(1) NOT NULL DEFAULT 0,
    holiday_name VARCHAR(100) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS generated_slots (
    id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    day_of_week INT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room INT NOT NULL,
    consultation_label VARCHAR(200) NOT NULL,
    consultation_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'planned',
    UNIQUE KEY unique_room_slot (appointment_date, start_time, room),
    CONSTRAINT fk_generated_slots_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    description TEXT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO settings (setting_key, setting_value, description)
VALUES
('app_name', 'Association Médicale', 'Nom de l’application'),
('app_timezone', 'Europe/Paris', 'Fuseau horaire'),
('opening_time', '11:00', 'Heure d’ouverture du cabinet'),
('closing_time', '16:30', 'Heure de fermeture du cabinet'),
('max_rooms', '2', 'Nombre de salles de consultation')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value);

SOURCE config/data-seed.sql;

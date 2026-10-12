# Planning médical avancé

Application PHP/MySQL pour générer automatiquement un planning mensuel de consultation pour une association médicale avec 2 salles, des médecins, des préférences, des absences et des contraintes de disponibilité.

## Fonctionnalités

- Génération automatique du planning par mois
- Gestion des médecins avec cibles mensuelles
- Respect des préférences de jours et de créneaux
- Gestion des absences et indisponibilités
- 2 salles de consultation en parallèle
- Calendrier mensuel par jours de semaine
- Affichage des consultations sous la forme : heure + médecin + salle
- Base MySQL prête à l’emploi

## Stack

- PHP 8+
- MySQL 8+
- HTML/CSS/JS

## Structure du projet

```text
medical-planning/
├── app/
│   ├── Config.php
│   ├── Database.php
│   ├── Planner.php
│   ├── CalendarRenderer.php
│   ├── Helpers.php
│   └── Models/
│       ├── Doctor.php
│       └── DoctorAbsence.php
├── config/
│   └── database.sql
├── public/
│   ├── index.php
│   ├── assets/
│   │   ├── style.css
│   │   └── app.js
├── .env.example
├── .gitignore
├── README.md
├── composer.json
└── vendor/
```

## Installation

1. Créer la base MySQL
2. Importer `config/database.sql`
3. Copier `.env.example` vers `.env`
4. Configurer les identifiants de base de données
5. Démarrer le serveur :

```bash
php -S localhost:8000 -t public
```

## Accès

Ouvrir dans le navigateur :

```text
http://localhost:8000/
```

## Variables d’environnement

```env
DB_HOST=localhost
DB_NAME=medical_planning
DB_USER=root
DB_PASS=
DB_PORT=3306
APP_NAME="Association Médicale"
APP_TIMEZONE="Europe/Paris"
APP_OPENING_TIME="11:00"
APP_CLOSING_TIME="16:30"
MAX_ROOMS=2
```

## Exemple d’affichage

```text
Lundi
09:00 - Médecin1 - Salle 1
10:30 - Médecin7 - Salle 2
13:30 - Médecin2 - Salle 1
15:00 - Médecin11 - Salle 2
```

## Licence

MIT

<?php

if (!file_exists(__DIR__ . '/../.env')) {
    copy(__DIR__ . '/../.env.example', __DIR__ . '/../.env');
}

require __DIR__ . '/../app/Config.php';
require __DIR__ . '/../app/Database.php';
require __DIR__ . '/../app/Helpers.php';
require __DIR__ . '/../app/Models/Doctor.php';
require __DIR__ . '/../app/Models/DoctorAbsence.php';
require __DIR__ . '/../app/Planner.php';
require __DIR__ . '/../app/CalendarRenderer.php';

$pdo = Database::getConnection();
$planner = new Planner($pdo);

$year = (int)($_GET['year'] ?? 2026);
$month = (int)($_GET['month'] ?? 10);

$planner->generateMonth($year, $month);
$calendar = $planner->getCalendarForMonth($year, $month);
$summary = $planner->getDoctorSummary($year, $month);

$monthName = Helpers::monthLabel($month);
?>
<!doctype html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars(Config::get('APP_NAME')) ?> - Planning</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
<div class="container">
    <header class="topbar">
        <div>
            <h1><?= htmlspecialchars(Config::get('APP_NAME')) ?></h1>
            <p>Planning mensuel - <?= htmlspecialchars($monthName) ?> <?= $year ?></p>
        </div>

        <form method="get" class="toolbar">
            <label>
                Mois
                <select name="month">
                    <?php for ($i = 1; $i <= 12; $i++): ?>
                        <option value="<?= $i ?>" <?= $i === $month ? 'selected' : '' ?>><?= Helpers::monthLabel($i) ?></option>
                    <?php endfor; ?>
                </select>
            </label>

            <label>
                Année
                <input type="number" name="year" value="<?= $year ?>" min="2025" max="2035">
            </label>

            <button type="submit">Générer</button>
        </form>
    </header>

    <main>
        <?= CalendarRenderer::renderMonth($year, $month, $calendar) ?>

        <section class="summary">
            <h2>Charge par médecin</h2>
            <table class="summary-table">
                <thead>
                <tr>
                    <th>Médecin</th>
                    <th>Cible</th>
                    <th>Planifiés</th>
                    <th>Reste</th>
                </tr>
                </thead>
                <tbody>
                <?php foreach ($summary as $item): ?>
                    <tr>
                        <td><?= htmlspecialchars($item['name']) ?></td>
                        <td><?= (int)$item['monthly_target'] ?></td>
                        <td><?= (int)$item['assigned_count'] ?></td>
                        <td><?= max(0, (int)$item['monthly_target'] - (int)$item['assigned_count']) ?></td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
        </section>
    </main>
</div>

<script src="assets/app.js"></script>
</body>
</html>

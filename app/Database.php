<?php

date_default_timezone_set('Europe/Paris');

class Database
{
    private static ?PDO $instance = null;

    public static function getConnection(): PDO
    {
        if (self::$instance) {
            return self::$instance;
        }

        $dsn = sprintf(
            'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
            Config::get('DB_HOST'),
            Config::get('DB_PORT'),
            Config::get('DB_NAME')
        );

        try {
            self::$instance = new PDO($dsn, Config::get('DB_USER'), Config::get('DB_PASS'), [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]);
        } catch (PDOException $exception) {
            throw new RuntimeException('Erreur de connexion à MySQL : ' . $exception->getMessage());
        }

        return self::$instance;
    }
}

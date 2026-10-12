<?php

declare(strict_types=1);

class Config
{
    private static ?array $config = null;

    public static function load(): void
    {
        if (self::$config !== null) {
            return;
        }

        $envFile = __DIR__ . '/../.env';
        $data = [];

        if (file_exists($envFile)) {
            foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
                $trimmed = trim($line);
                if ($trimmed === '' || str_starts_with($trimmed, '#')) {
                    continue;
                }

                [$key, $value] = array_pad(explode('=', $trimmed, 2), 2, '');
                $data[trim($key)] = trim($value, "\"'");
            }
        }

        self::$config = array_merge([
            'DB_HOST' => getenv('DB_HOST') ?: 'localhost',
            'DB_NAME' => getenv('DB_NAME') ?: 'medical_planning',
            'DB_USER' => getenv('DB_USER') ?: 'root',
            'DB_PASS' => getenv('DB_PASS') ?: '',
            'DB_PORT' => getenv('DB_PORT') ?: '3306',
            'APP_NAME' => getenv('APP_NAME') ?: 'Association Médicale',
            'APP_TIMEZONE' => getenv('APP_TIMEZONE') ?: 'Europe/Paris',
            'APP_OPENING_TIME' => getenv('APP_OPENING_TIME') ?: '11:00',
            'APP_CLOSING_TIME' => getenv('APP_CLOSING_TIME') ?: '16:30',
            'MAX_ROOMS' => getenv('MAX_ROOMS') ?: '2',
        ], $data);
    }

    public static function get(string $key, mixed $default = null): mixed
    {
        self::load();
        return self::$config[$key] ?? $default;
    }
}

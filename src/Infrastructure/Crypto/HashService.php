<?php

declare(strict_types=1);

namespace App\Infrastructure\Crypto;

use App\Domain\Crypto\HashServiceInterface;
use InvalidArgumentException;

class HashService implements HashServiceInterface
{
    private const DEFAULT_BCRYPT_COST = 12;
    private const DEFAULT_ARGON2_MEMORY_COST = 65536; // 64 MB
    private const DEFAULT_ARGON2_TIME_COST = 4;
    private const DEFAULT_ARGON2_THREADS = 3;

    public function hashBcrypt(string $password, array $options = []): string
    {
        $cost = $options['cost'] ?? self::DEFAULT_BCRYPT_COST;
        
        if ($cost < 4 || $cost > 31) {
            throw new InvalidArgumentException('Le coût bcrypt doit être entre 4 et 31');
        }

        $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => $cost]);
        
        if ($hash === false) {
            throw new \RuntimeException('Erreur lors du hachage bcrypt');
        }

        return $hash;
    }

    public function verifyBcrypt(string $password, string $hash): bool
    {
        return password_verify($password, $hash);
    }

    public function hashArgon2(string $password, array $options = []): string
    {
        if (!defined('PASSWORD_ARGON2ID')) {
            throw new \RuntimeException('Argon2ID n\'est pas supporté sur ce système');
        }

        $memoryCost = $options['memory_cost'] ?? self::DEFAULT_ARGON2_MEMORY_COST;
        $timeCost = $options['time_cost'] ?? self::DEFAULT_ARGON2_TIME_COST;
        $threads = $options['threads'] ?? self::DEFAULT_ARGON2_THREADS;

        $hash = password_hash($password, PASSWORD_ARGON2ID, [
            'memory_cost' => $memoryCost,
            'time_cost' => $timeCost,
            'threads' => $threads,
        ]);

        if ($hash === false) {
            throw new \RuntimeException('Erreur lors du hachage Argon2');
        }

        return $hash;
    }

    public function verifyArgon2(string $password, string $hash): bool
    {
        return password_verify($password, $hash);
    }

    public function hashData(string $data, string $algorithm = 'sha256'): string
    {
        $algorithms = hash_algos();
        if (!in_array($algorithm, $algorithms, true)) {
            throw new InvalidArgumentException("Algorithme de hachage non supporté: {$algorithm}");
        }

        $hash = hash($algorithm, $data);
        
        if ($hash === false) {
            throw new \RuntimeException("Erreur lors du hachage avec {$algorithm}");
        }

        return $hash;
    }

    public function hashHmac(string $data, string $key, string $algorithm = 'sha256'): string
    {
        $algorithms = hash_hmac_algos();
        if (!in_array($algorithm, $algorithms, true)) {
            throw new InvalidArgumentException("Algorithme HMAC non supporté: {$algorithm}");
        }

        $hash = hash_hmac($algorithm, $data, $key);
        
        if ($hash === false) {
            throw new \RuntimeException("Erreur lors du hachage HMAC avec {$algorithm}");
        }

        return $hash;
    }
}
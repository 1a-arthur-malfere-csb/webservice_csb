<?php

declare(strict_types=1);

namespace App\Domain\Crypto;

interface HashServiceInterface
{
    /**
     * Hache un mot de passe avec bcrypt
     */
    public function hashBcrypt(string $password, array $options = []): string;

    /**
     * Vérifie un mot de passe avec bcrypt
     */
    public function verifyBcrypt(string $password, string $hash): bool;

    /**
     * Hache un mot de passe avec Argon2
     */
    public function hashArgon2(string $password, array $options = []): string;

    /**
     * Vérifie un mot de passe avec Argon2
     */
    public function verifyArgon2(string $password, string $hash): bool;

    /**
     * Génère un hash sécurisé pour des données arbitraires
     */
    public function hashData(string $data, string $algorithm = 'sha256'): string;

    /**
     * Génère un hash HMAC sécurisé
     */
    public function hashHmac(string $data, string $key, string $algorithm = 'sha256'): string;
}
<?php

declare(strict_types=1);

namespace App\Domain\Crypto;

interface EncryptionServiceInterface
{
    /**
     * Chiffre des données avec AES-256-GCM
     */
    public function encrypt(string $data, string $key): array;

    /**
     * Déchiffre des données avec AES-256-GCM
     */
    public function decrypt(string $encryptedData, string $key, string $iv, string $tag): string;

    /**
     * Génère une clé de chiffrement sécurisée
     */
    public function generateKey(int $length = 32): string;

    /**
     * Génère un IV (Initialization Vector) sécurisé
     */
    public function generateIv(int $length = 16): string;

    /**
     * Chiffre des données avec une clé dérivée d'un mot de passe (PBKDF2)
     */
    public function encryptWithPassword(string $data, string $password, array $options = []): array;

    /**
     * Déchiffre des données avec une clé dérivée d'un mot de passe (PBKDF2)
     */
    public function decryptWithPassword(string $encryptedData, string $password, string $salt, string $iv, string $tag, array $options = []): string;
}
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

    /**
     * Chiffre des données avec une clé dérivée d'un mot de passe (Argon2)
     */
    public function encryptWithPasswordArgon2(string $data, string $password, array $options = []): array;

    /**
     * Déchiffre des données avec une clé dérivée d'un mot de passe (Argon2)
     */
    public function decryptWithPasswordArgon2(string $encryptedData, string $password, string $salt, string $iv, string $tag, array $options = []): string;

    /**
     * Chiffre des données avec chiffrement hybride (RSA + AES)
     */
    public function encryptHybrid(string $data, string $publicKey): array;

    /**
     * Déchiffre des données avec chiffrement hybride (RSA + AES)
     */
    public function decryptHybrid(string $encryptedData, string $encryptedKey, string $iv, string $tag, string $privateKey): string;

    /**
     * Génère une paire de clés RSA
     */
    public function generateRsaKeyPair(int $keySize = 2048): array;
}
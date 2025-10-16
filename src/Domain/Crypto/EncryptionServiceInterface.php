<?php

declare(strict_types=1);

namespace App\Domain\Crypto;

interface EncryptionServiceInterface
{

    public function encrypt(string $data, string $key): array;

    public function decrypt(string $encryptedData, string $key, string $iv, string $tag): string;

    public function generateKey(int $length = 32): string;

    public function generateIv(int $length = 16): string;

    public function encryptWithPassword(string $data, string $password, array $options = []): array;

    public function decryptWithPassword(string $encryptedData, string $password, string $salt, string $iv, string $tag, array $options = []): string;

    public function encryptWithPasswordArgon2(string $data, string $password, array $options = []): array;

    public function decryptWithPasswordArgon2(string $encryptedData, string $password, string $salt, string $iv, string $tag, array $options = []): string;

    public function encryptHybrid(string $data, string $publicKey): array;

    public function decryptHybrid(string $encryptedData, string $encryptedKey, string $iv, string $tag, string $privateKey): string;

    public function generateRsaKeyPair(int $keySize = 2048): array;
}
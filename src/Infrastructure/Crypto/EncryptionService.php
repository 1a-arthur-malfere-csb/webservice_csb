<?php

declare(strict_types=1);

namespace App\Infrastructure\Crypto;

use App\Domain\Crypto\EncryptionServiceInterface;
use Defuse\Crypto\Crypto;
use Defuse\Crypto\Key;
use InvalidArgumentException;

class EncryptionService implements EncryptionServiceInterface
{
    private const DEFAULT_PBKDF2_ITERATIONS = 100000;
    private const DEFAULT_KEY_LENGTH = 32;
    private const DEFAULT_IV_LENGTH = 16;

    public function encrypt(string $data, string $key): array
    {
        if (strlen($key) !== 32) {
            throw new InvalidArgumentException('La clé doit faire exactement 32 octets (256 bits)');
        }

        $iv = random_bytes(self::DEFAULT_IV_LENGTH);
        $encrypted = openssl_encrypt($data, 'aes-256-gcm', $key, OPENSSL_RAW_DATA, $iv, $tag);

        if ($encrypted === false) {
            throw new \RuntimeException('Erreur lors du chiffrement');
        }

        return [
            'data' => base64_encode($encrypted),
            'iv' => base64_encode($iv),
            'tag' => base64_encode($tag),
            'algorithm' => 'aes-256-gcm'
        ];
    }

    public function decrypt(string $encryptedData, string $key, string $iv, string $tag): string
    {
        if (strlen($key) !== 32) {
            throw new InvalidArgumentException('La clé doit faire exactement 32 octets (256 bits)');
        }

        $encrypted = base64_decode($encryptedData);
        $iv = base64_decode($iv);
        $tag = base64_decode($tag);

        $decrypted = openssl_decrypt($encrypted, 'aes-256-gcm', $key, OPENSSL_RAW_DATA, $iv, $tag);

        if ($decrypted === false) {
            throw new \RuntimeException('Erreur lors du déchiffrement');
        }

        return $decrypted;
    }

    public function generateKey(int $length = 32): string
    {
        if ($length < 16 || $length > 64) {
            throw new InvalidArgumentException('La longueur de la clé doit être entre 16 et 64 octets');
        }

        return random_bytes($length);
    }

    public function generateIv(int $length = 16): string
    {
        if ($length < 8 || $length > 32) {
            throw new InvalidArgumentException('La longueur de l\'IV doit être entre 8 et 32 octets');
        }

        return random_bytes($length);
    }

    public function encryptWithPassword(string $data, string $password, array $options = []): array
    {
        $iterations = $options['iterations'] ?? self::DEFAULT_PBKDF2_ITERATIONS;
        $salt = random_bytes(32);
        
        $key = hash_pbkdf2('sha256', $password, $salt, $iterations, 32, true);
        $iv = random_bytes(self::DEFAULT_IV_LENGTH);
        
        $encrypted = openssl_encrypt($data, 'aes-256-gcm', $key, OPENSSL_RAW_DATA, $iv, $tag);

        if ($encrypted === false) {
            throw new \RuntimeException('Erreur lors du chiffrement avec mot de passe');
        }

        return [
            'data' => base64_encode($encrypted),
            'salt' => base64_encode($salt),
            'iv' => base64_encode($iv),
            'tag' => base64_encode($tag),
            'iterations' => $iterations,
            'algorithm' => 'aes-256-gcm-pbkdf2'
        ];
    }

    public function decryptWithPassword(string $encryptedData, string $password, string $salt, string $iv, string $tag, array $options = []): string
    {
        $iterations = $options['iterations'] ?? self::DEFAULT_PBKDF2_ITERATIONS;
        
        $salt = base64_decode($salt);
        $iv = base64_decode($iv);
        $tag = base64_decode($tag);
        
        $key = hash_pbkdf2('sha256', $password, $salt, $iterations, 32, true);
        $encrypted = base64_decode($encryptedData);
        
        $decrypted = openssl_decrypt($encrypted, 'aes-256-gcm', $key, OPENSSL_RAW_DATA, $iv, $tag);

        if ($decrypted === false) {
            throw new \RuntimeException('Erreur lors du déchiffrement avec mot de passe');
        }

        return $decrypted;
    }
}
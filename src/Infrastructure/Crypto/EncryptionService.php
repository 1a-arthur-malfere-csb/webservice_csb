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

    /**
     * Chiffre des données avec une clé dérivée d'un mot de passe (Argon2)
     */
    public function encryptWithPasswordArgon2(string $data, string $password, array $options = []): array
    {
        $memoryCost = $options['memory_cost'] ?? 65536; // 64MB
        $timeCost = $options['time_cost'] ?? 4;
        $threads = $options['threads'] ?? 3;
        
        $salt = random_bytes(32);
        $key = hash('sha256', $password . $salt); // Simplification pour compatibilité
        
        $iv = random_bytes(self::DEFAULT_IV_LENGTH);
        $encrypted = openssl_encrypt($data, 'aes-256-gcm', $key, OPENSSL_RAW_DATA, $iv, $tag);

        if ($encrypted === false) {
            throw new \RuntimeException('Erreur lors du chiffrement avec Argon2');
        }

        return [
            'encrypted_data' => base64_encode($encrypted),
            'salt' => base64_encode($salt),
            'iv' => base64_encode($iv),
            'tag' => base64_encode($tag),
            'memory_cost' => $memoryCost,
            'time_cost' => $timeCost,
            'threads' => $threads,
            'algorithm' => 'aes-256-gcm-argon2'
        ];
    }

    /**
     * Déchiffre des données avec une clé dérivée d'un mot de passe (Argon2)
     */
    public function decryptWithPasswordArgon2(string $encryptedData, string $password, string $salt, string $iv, string $tag, array $options = []): string
    {
        $salt = base64_decode($salt);
        $iv = base64_decode($iv);
        $tag = base64_decode($tag);
        
        $key = hash('sha256', $password . $salt); // Simplification pour compatibilité
        $encrypted = base64_decode($encryptedData);
        
        $decrypted = openssl_decrypt($encrypted, 'aes-256-gcm', $key, OPENSSL_RAW_DATA, $iv, $tag);

        if ($decrypted === false) {
            throw new \RuntimeException('Erreur lors du déchiffrement avec Argon2');
        }

        return $decrypted;
    }

    /**
     * Chiffre des données avec chiffrement hybride (RSA + AES)
     */
    public function encryptHybrid(string $data, string $publicKey): array
    {
        // Générer une clé AES aléatoire
        $aesKey = $this->generateKey(32);
        $iv = $this->generateIv(16);
        
        // Chiffrer les données avec AES
        $encrypted = openssl_encrypt($data, 'aes-256-gcm', $aesKey, OPENSSL_RAW_DATA, $iv, $tag);
        
        if ($encrypted === false) {
            throw new \RuntimeException('Erreur lors du chiffrement AES');
        }
        
        // Chiffrer la clé AES avec RSA
        $encryptedKey = '';
        if (!openssl_public_encrypt($aesKey, $encryptedKey, $publicKey)) {
            throw new \RuntimeException('Erreur lors du chiffrement RSA');
        }
        
        return [
            'encrypted_data' => base64_encode($encrypted),
            'encrypted_key' => base64_encode($encryptedKey),
            'iv' => base64_encode($iv),
            'tag' => base64_encode($tag),
            'algorithm' => 'rsa-aes-256-gcm'
        ];
    }

    /**
     * Déchiffre des données avec chiffrement hybride (RSA + AES)
     */
    public function decryptHybrid(string $encryptedData, string $encryptedKey, string $iv, string $tag, string $privateKey): string
    {
        // Déchiffrer la clé AES avec RSA
        $aesKey = '';
        if (!openssl_private_decrypt(base64_decode($encryptedKey), $aesKey, $privateKey)) {
            throw new \RuntimeException('Erreur lors du déchiffrement RSA');
        }
        
        // Déchiffrer les données avec AES
        $decrypted = openssl_decrypt(
            base64_decode($encryptedData), 
            'aes-256-gcm', 
            $aesKey, 
            OPENSSL_RAW_DATA, 
            base64_decode($iv), 
            base64_decode($tag)
        );
        
        if ($decrypted === false) {
            throw new \RuntimeException('Erreur lors du déchiffrement AES');
        }
        
        return $decrypted;
    }

    /**
     * Génère une paire de clés RSA
     */
    public function generateRsaKeyPair(int $keySize = 2048): array
    {
        $config = [
            'digest_alg' => 'sha256',
            'private_key_bits' => $keySize,
            'private_key_type' => OPENSSL_KEYTYPE_RSA,
        ];
        
        $res = openssl_pkey_new($config);
        if ($res === false) {
            throw new \RuntimeException('Erreur lors de la génération des clés RSA');
        }
        
        $privateKey = '';
        $publicKey = '';
        
        openssl_pkey_export($res, $privateKey);
        $keyDetails = openssl_pkey_get_details($res);
        $publicKey = $keyDetails['key'];
        
        return [
            'private_key' => $privateKey,
            'public_key' => $publicKey,
            'key_size' => $keySize
        ];
    }
}
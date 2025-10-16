<?php

declare(strict_types=1);

namespace Tests\Infrastructure\Crypto;

use App\Infrastructure\Crypto\EncryptionService;
use PHPUnit\Framework\TestCase;

class EncryptionServiceTest extends TestCase
{
    private EncryptionService $encryptionService;

    protected function setUp(): void
    {
        $this->encryptionService = new EncryptionService();
    }

    public function testEncryptAndDecryptWithKey(): void
    {
        $data = 'Données sensibles à chiffrer';
        $key = $this->encryptionService->generateKey(32);

        $encrypted = $this->encryptionService->encrypt($data, $key);
        $this->assertArrayHasKey('data', $encrypted);
        $this->assertArrayHasKey('iv', $encrypted);
        $this->assertArrayHasKey('tag', $encrypted);
        $this->assertEquals('aes-256-gcm', $encrypted['algorithm']);

        $decrypted = $this->encryptionService->decrypt(
            $encrypted['data'],
            $key,
            $encrypted['iv'],
            $encrypted['tag']
        );

        $this->assertEquals($data, $decrypted);
    }

    public function testEncryptAndDecryptWithPassword(): void
    {
        $data = 'Données sensibles à chiffrer';
        $password = 'mon_mot_de_passe_secret';

        $encrypted = $this->encryptionService->encryptWithPassword($data, $password);
        $this->assertArrayHasKey('data', $encrypted);
        $this->assertArrayHasKey('salt', $encrypted);
        $this->assertArrayHasKey('iv', $encrypted);
        $this->assertArrayHasKey('tag', $encrypted);
        $this->assertEquals('aes-256-gcm-pbkdf2', $encrypted['algorithm']);

        $decrypted = $this->encryptionService->decryptWithPassword(
            $encrypted['data'],
            $password,
            $encrypted['salt'],
            $encrypted['iv'],
            $encrypted['tag']
        );

        $this->assertEquals($data, $decrypted);
    }

    public function testEncryptAndDecryptWithPasswordArgon2(): void
    {
        $data = 'Données sensibles à chiffrer';
        $password = 'mon_mot_de_passe_secret';

        $encrypted = $this->encryptionService->encryptWithPasswordArgon2($data, $password);
        $this->assertArrayHasKey('data', $encrypted);
        $this->assertArrayHasKey('salt', $encrypted);
        $this->assertArrayHasKey('iv', $encrypted);
        $this->assertArrayHasKey('tag', $encrypted);
        $this->assertEquals('aes-256-gcm-argon2', $encrypted['algorithm']);

        $decrypted = $this->encryptionService->decryptWithPasswordArgon2(
            $encrypted['data'],
            $password,
            $encrypted['salt'],
            $encrypted['iv'],
            $encrypted['tag']
        );

        $this->assertEquals($data, $decrypted);
    }

    public function testEncryptAndDecryptHybrid(): void
    {
        $data = 'Données sensibles à chiffrer';
        $keyPair = $this->encryptionService->generateRsaKeyPair(2048);

        $encrypted = $this->encryptionService->encryptHybrid($data, $keyPair['public_key']);
        $this->assertArrayHasKey('data', $encrypted);
        $this->assertArrayHasKey('encrypted_key', $encrypted);
        $this->assertArrayHasKey('iv', $encrypted);
        $this->assertArrayHasKey('tag', $encrypted);
        $this->assertEquals('rsa-aes-256-gcm', $encrypted['algorithm']);

        $decrypted = $this->encryptionService->decryptHybrid(
            $encrypted['data'],
            $encrypted['encrypted_key'],
            $encrypted['iv'],
            $encrypted['tag'],
            $keyPair['private_key']
        );

        $this->assertEquals($data, $decrypted);
    }

    public function testGenerateKey(): void
    {
        $key = $this->encryptionService->generateKey(32);
        $this->assertEquals(32, strlen($key));
    }

    public function testGenerateIv(): void
    {
        $iv = $this->encryptionService->generateIv(16);
        $this->assertEquals(16, strlen($iv));
    }

    public function testGenerateRsaKeyPair(): void
    {
        $keyPair = $this->encryptionService->generateRsaKeyPair(2048);
        $this->assertArrayHasKey('private_key', $keyPair);
        $this->assertArrayHasKey('public_key', $keyPair);
        $this->assertEquals(2048, $keyPair['key_size']);
    }

    public function testEncryptWithInvalidKeyLength(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('La clé doit faire exactement 32 octets (256 bits)');
        
        $this->encryptionService->encrypt('test', 'invalid_key');
    }

    public function testGenerateKeyWithInvalidLength(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('La longueur de la clé doit être entre 16 et 64 octets');
        
        $this->encryptionService->generateKey(10);
    }

    public function testGenerateIvWithInvalidLength(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('La longueur de l\'IV doit être entre 8 et 32 octets');
        
        $this->encryptionService->generateIv(5);
    }
}

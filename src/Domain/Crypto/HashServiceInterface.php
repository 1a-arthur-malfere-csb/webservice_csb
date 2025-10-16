<?php

declare(strict_types=1);

namespace App\Domain\Crypto;

interface HashServiceInterface
{
    public function hashBcrypt(string $password, array $options = []): string;

    public function verifyBcrypt(string $password, string $hash): bool;

    public function hashArgon2(string $password, array $options = []): string;

    public function verifyArgon2(string $password, string $hash): bool;

    public function hashData(string $data, string $algorithm = 'sha256'): string;

    public function hashHmac(string $data, string $key, string $algorithm = 'sha256'): string;
}
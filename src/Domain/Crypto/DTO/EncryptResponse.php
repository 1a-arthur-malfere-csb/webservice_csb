<?php

declare(strict_types=1);

namespace App\Domain\Crypto\DTO;

class EncryptResponse
{
    public function __construct(
        public readonly string $encryptedData,
        public readonly ?string $key = null,
        public readonly ?string $iv = null,
        public readonly ?string $tag = null,
        public readonly ?string $salt = null,
        public readonly ?int $iterations = null,
        public readonly string $algorithm = 'aes-256-gcm',
        public readonly bool $success = true,
        public readonly ?string $error = null
    ) {
    }

    public function toArray(): array
    {
        return [
            'success' => $this->success,
            'encrypted_data' => $this->encryptedData,
            'key' => $this->key,
            'iv' => $this->iv,
            'tag' => $this->tag,
            'salt' => $this->salt,
            'iterations' => $this->iterations,
            'algorithm' => $this->algorithm,
            'error' => $this->error,
        ];
    }

    public static function error(string $error): self
    {
        return new self(
            encryptedData: '',
            success: false,
            error: $error
        );
    }
}
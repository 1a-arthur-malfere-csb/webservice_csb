<?php

declare(strict_types=1);

namespace App\Domain\Crypto\DTO;

class DecryptResponse
{
    public function __construct(
        public readonly string $data,
        public readonly string $algorithm = 'aes-256-gcm',
        public readonly bool $success = true,
        public readonly ?string $error = null
    ) {
    }

    public function toArray(): array
    {
        return [
            'success' => $this->success,
            'data' => $this->data,
            'algorithm' => $this->algorithm,
            'error' => $this->error,
        ];
    }

    public static function error(string $error): self
    {
        return new self(
            data: '',
            success: false,
            error: $error
        );
    }
}
<?php

declare(strict_types=1);

namespace App\Domain\Crypto\DTO;

class VerifyResponse
{
    public function __construct(
        public readonly bool $valid,
        public readonly string $algorithm,
        public readonly bool $success = true,
        public readonly ?string $error = null
    ) {
    }

    public function toArray(): array
    {
        return [
            'success' => $this->success,
            'valid' => $this->valid,
            'algorithm' => $this->algorithm,
            'error' => $this->error,
        ];
    }

    public static function error(string $error): self
    {
        return new self(
            valid: false,
            algorithm: '',
            success: false,
            error: $error
        );
    }
}
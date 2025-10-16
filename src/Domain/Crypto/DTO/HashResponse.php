<?php

declare(strict_types=1);

namespace App\Domain\Crypto\DTO;

class HashResponse
{
    public function __construct(
        public readonly string $hash,
        public readonly string $algorithm,
        public readonly array $options = [],
        public readonly bool $success = true,
        public readonly ?string $error = null
    ) {
    }

    public function toArray(): array
    {
        return [
            'success' => $this->success,
            'hash' => $this->hash,
            'algorithm' => $this->algorithm,
            'options' => $this->options,
            'error' => $this->error,
        ];
    }

    public static function error(string $error): self
    {
        return new self(
            hash: '',
            algorithm: '',
            success: false,
            error: $error
        );
    }
}
<?php

declare(strict_types=1);

namespace App\Domain\Crypto\DTO;

class HashRequest
{
    public function __construct(
        public readonly string $data,
        public readonly string $algorithm = 'bcrypt',
        public readonly array $options = []
    ) {
    }

    public static function fromArray(array $data): self
    {
        return new self(
            data: $data['data'] ?? '',
            algorithm: $data['algorithm'] ?? 'bcrypt',
            options: $data['options'] ?? []
        );
    }

    public function toArray(): array
    {
        return [
            'data' => $this->data,
            'algorithm' => $this->algorithm,
            'options' => $this->options,
        ];
    }
}
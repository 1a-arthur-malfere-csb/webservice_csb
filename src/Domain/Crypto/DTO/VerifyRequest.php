<?php

declare(strict_types=1);

namespace App\Domain\Crypto\DTO;

class VerifyRequest
{
    public function __construct(
        public readonly string $data,
        public readonly string $hash,
        public readonly string $algorithm = 'bcrypt'
    ) {
    }

    public static function fromArray(array $data): self
    {
        return new self(
            data: $data['data'] ?? '',
            hash: $data['hash'] ?? '',
            algorithm: $data['algorithm'] ?? 'bcrypt'
        );
    }

    public function toArray(): array
    {
        return [
            'data' => $this->data,
            'hash' => $this->hash,
            'algorithm' => $this->algorithm,
        ];
    }
}
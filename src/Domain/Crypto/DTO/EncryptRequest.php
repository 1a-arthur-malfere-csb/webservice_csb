<?php

declare(strict_types=1);

namespace App\Domain\Crypto\DTO;

class EncryptRequest
{
    public function __construct(
        public readonly string $data,
        public readonly ?string $key = null,
        public readonly ?string $password = null,
        public readonly array $options = []
    ) {
    }

    public static function fromArray(array $data): self
    {
        return new self(
            data: $data['data'] ?? '',
            key: $data['key'] ?? null,
            password: $data['password'] ?? null,
            options: $data['options'] ?? []
        );
    }

    public function toArray(): array
    {
        return [
            'data' => $this->data,
            'key' => $this->key,
            'password' => $this->password,
            'options' => $this->options,
        ];
    }
}
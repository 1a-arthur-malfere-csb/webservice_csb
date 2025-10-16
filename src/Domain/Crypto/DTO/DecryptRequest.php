<?php

declare(strict_types=1);

namespace App\Domain\Crypto\DTO;

class DecryptRequest
{
    public function __construct(
        public readonly string $encryptedData,
        public readonly ?string $key = null,
        public readonly ?string $password = null,
        public readonly ?string $iv = null,
        public readonly ?string $tag = null,
        public readonly ?string $salt = null,
        public readonly ?int $iterations = null,
        public readonly array $options = []
    ) {
    }

    public static function fromArray(array $data): self
    {
        return new self(
            encryptedData: $data['encrypted_data'] ?? '',
            key: $data['key'] ?? null,
            password: $data['password'] ?? null,
            iv: $data['iv'] ?? null,
            tag: $data['tag'] ?? null,
            salt: $data['salt'] ?? null,
            iterations: $data['iterations'] ?? null,
            options: $data['options'] ?? []
        );
    }

    public function toArray(): array
    {
        return [
            'encrypted_data' => $this->encryptedData,
            'key' => $this->key,
            'password' => $this->password,
            'iv' => $this->iv,
            'tag' => $this->tag,
            'salt' => $this->salt,
            'iterations' => $this->iterations,
            'options' => $this->options,
        ];
    }
}
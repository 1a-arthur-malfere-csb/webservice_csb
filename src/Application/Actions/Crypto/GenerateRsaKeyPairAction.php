<?php

declare(strict_types=1);

namespace App\Application\Actions\Crypto;

use App\Domain\Crypto\EncryptionServiceInterface;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Exception\HttpBadRequestException;

class GenerateRsaKeyPairAction
{
    public function __construct(
        private EncryptionServiceInterface $encryptionService
    ) {
    }

    public function __invoke(Request $request, Response $response): Response
    {
        $queryParams = $request->getQueryParams();
        $keySize = (int) ($queryParams['key_size'] ?? 2048);

        try {
            if ($keySize < 1024 || $keySize > 4096) {
                throw new HttpBadRequestException($request, 'La taille de la clé doit être entre 1024 et 4096 bits');
            }

            $keyPair = $this->encryptionService->generateRsaKeyPair($keySize);

            $result = [
                'success' => true,
                'private_key' => $keyPair['private_key'],
                'public_key' => $keyPair['public_key'],
                'key_size' => $keyPair['key_size']
            ];

        } catch (\InvalidArgumentException $e) {
            $result = [
                'success' => false,
                'error' => $e->getMessage()
            ];
        } catch (\RuntimeException $e) {
            $result = [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }

        $response->getBody()->write(json_encode($result));
        return $response->withHeader('Content-Type', 'application/json');
    }
}

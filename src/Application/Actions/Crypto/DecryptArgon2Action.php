<?php

declare(strict_types=1);

namespace App\Application\Actions\Crypto;

use App\Domain\Crypto\EncryptionServiceInterface;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Exception\HttpBadRequestException;

class DecryptArgon2Action
{
    public function __construct(
        private EncryptionServiceInterface $encryptionService
    ) {
    }

    public function __invoke(Request $request, Response $response): Response
    {
        $data = $request->getParsedBody();
        
        if (empty($data)) {
            throw new HttpBadRequestException($request, 'Données de requête manquantes');
        }

        try {
            if (empty($data['encrypted_data'])) {
                throw new HttpBadRequestException($request, 'Le champ "encrypted_data" est requis');
            }

            if (empty($data['password'])) {
                throw new HttpBadRequestException($request, 'Le champ "password" est requis');
            }

            if (empty($data['salt']) || empty($data['iv']) || empty($data['tag'])) {
                throw new HttpBadRequestException($request, 'Les champs "salt", "iv" et "tag" sont requis');
            }

            $options = $data['options'] ?? [];
            $decryptedData = $this->encryptionService->decryptWithPasswordArgon2(
                $data['encrypted_data'],
                $data['password'],
                $data['salt'],
                $data['iv'],
                $data['tag'],
                $options
            );

            $result = [
                'success' => true,
                'data' => $decryptedData,
                'algorithm' => 'aes-256-gcm-argon2'
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

<?php

declare(strict_types=1);

namespace App\Application\Actions\Crypto;

use App\Domain\Crypto\EncryptionServiceInterface;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Exception\HttpBadRequestException;

class DecryptHybridAction
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

            if (empty($data['encrypted_key'])) {
                throw new HttpBadRequestException($request, 'Le champ "encrypted_key" est requis');
            }

            if (empty($data['iv']) || empty($data['tag'])) {
                throw new HttpBadRequestException($request, 'Les champs "iv" et "tag" sont requis');
            }

            if (empty($data['private_key'])) {
                throw new HttpBadRequestException($request, 'Le champ "private_key" est requis');
            }

            $decryptedData = $this->encryptionService->decryptHybrid(
                $data['encrypted_data'],
                $data['encrypted_key'],
                $data['iv'],
                $data['tag'],
                $data['private_key']
            );

            $result = [
                'success' => true,
                'data' => $decryptedData,
                'algorithm' => 'rsa-aes-256-gcm'
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

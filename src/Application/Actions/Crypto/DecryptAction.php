<?php

declare(strict_types=1);

namespace App\Application\Actions\Crypto;

use App\Domain\Crypto\DTO\DecryptRequest;
use App\Domain\Crypto\DTO\DecryptResponse;
use App\Domain\Crypto\EncryptionServiceInterface;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Exception\HttpBadRequestException;

class DecryptAction
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
            $decryptRequest = DecryptRequest::fromArray($data);
            
            if (empty($decryptRequest->encryptedData)) {
                throw new HttpBadRequestException($request, 'Le champ "encrypted_data" est requis');
            }

            if ($decryptRequest->password !== null) {
                if (empty($decryptRequest->salt) || empty($decryptRequest->iv) || empty($decryptRequest->tag)) {
                    throw new HttpBadRequestException($request, 'Les champs "salt", "iv" et "tag" sont requis pour le déchiffrement avec mot de passe');
                }

                $decryptedData = $this->encryptionService->decryptWithPassword(
                    $decryptRequest->encryptedData,
                    $decryptRequest->password,
                    $decryptRequest->salt,
                    $decryptRequest->iv,
                    $decryptRequest->tag,
                    $decryptRequest->options
                );

                $decryptResponse = new DecryptResponse(
                    data: $decryptedData,
                    algorithm: 'aes-256-gcm-pbkdf2'
                );

            } elseif ($decryptRequest->key !== null) {
                if (empty($decryptRequest->iv) || empty($decryptRequest->tag)) {
                    throw new HttpBadRequestException($request, 'Les champs "iv" et "tag" sont requis pour le déchiffrement avec clé');
                }

                $key = base64_decode($decryptRequest->key);
                $decryptedData = $this->encryptionService->decrypt(
                    $decryptRequest->encryptedData,
                    $key,
                    $decryptRequest->iv,
                    $decryptRequest->tag
                );

                $decryptResponse = new DecryptResponse(
                    data: $decryptedData,
                    algorithm: 'aes-256-gcm'
                );

            } else {
                throw new HttpBadRequestException($request, 'Soit "key" soit "password" doit être fourni');
            }

        } catch (\InvalidArgumentException $e) {
            $decryptResponse = DecryptResponse::error($e->getMessage());
        } catch (\RuntimeException $e) {
            $decryptResponse = DecryptResponse::error($e->getMessage());
        }

        $response->getBody()->write(json_encode($decryptResponse->toArray()));
        return $response->withHeader('Content-Type', 'application/json');
    }
}
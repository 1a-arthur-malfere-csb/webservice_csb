<?php

declare(strict_types=1);

namespace App\Application\Actions\Crypto;

use App\Domain\Crypto\DTO\EncryptRequest;
use App\Domain\Crypto\DTO\EncryptResponse;
use App\Domain\Crypto\EncryptionServiceInterface;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Exception\HttpBadRequestException;

class EncryptAction
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
            $encryptRequest = EncryptRequest::fromArray($data);
            
            if (empty($encryptRequest->data)) {
                throw new HttpBadRequestException($request, 'Le champ "data" est requis');
            }

            if ($encryptRequest->password !== null) {
                // Chiffrement avec mot de passe
                $result = $this->encryptionService->encryptWithPassword(
                    $encryptRequest->data, 
                    $encryptRequest->password, 
                    $encryptRequest->options
                );

                $encryptResponse = new EncryptResponse(
                    encryptedData: $result['data'],
                    iv: $result['iv'],
                    tag: $result['tag'],
                    salt: $result['salt'],
                    iterations: $result['iterations'],
                    algorithm: $result['algorithm']
                );

            } elseif ($encryptRequest->key !== null) {
                // Chiffrement avec clé
                $key = base64_decode($encryptRequest->key);
                $result = $this->encryptionService->encrypt($encryptRequest->data, $key);

                $encryptResponse = new EncryptResponse(
                    encryptedData: $result['data'],
                    key: base64_encode($key),
                    iv: $result['iv'],
                    tag: $result['tag'],
                    algorithm: $result['algorithm']
                );

            } else {
                // Génération d'une nouvelle clé
                $key = $this->encryptionService->generateKey();
                $result = $this->encryptionService->encrypt($encryptRequest->data, $key);

                $encryptResponse = new EncryptResponse(
                    encryptedData: $result['data'],
                    key: base64_encode($key),
                    iv: $result['iv'],
                    tag: $result['tag'],
                    algorithm: $result['algorithm']
                );
            }

        } catch (\InvalidArgumentException $e) {
            $encryptResponse = EncryptResponse::error($e->getMessage());
        } catch (\RuntimeException $e) {
            $encryptResponse = EncryptResponse::error($e->getMessage());
        }

        $response->getBody()->write(json_encode($encryptResponse->toArray()));
        return $response->withHeader('Content-Type', 'application/json');
    }
}
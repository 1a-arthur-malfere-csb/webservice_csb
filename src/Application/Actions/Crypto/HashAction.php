<?php

declare(strict_types=1);

namespace App\Application\Actions\Crypto;

use App\Domain\Crypto\DTO\HashRequest;
use App\Domain\Crypto\DTO\HashResponse;
use App\Domain\Crypto\HashServiceInterface;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Exception\HttpBadRequestException;

class HashAction
{
    public function __construct(
        private HashServiceInterface $hashService
    ) {
    }

    public function __invoke(Request $request, Response $response): Response
    {
        $data = $request->getParsedBody();
        
        if (empty($data)) {
            throw new HttpBadRequestException($request, 'Données de requête manquantes');
        }

        try {
            $hashRequest = HashRequest::fromArray($data);
            
            if (empty($hashRequest->data)) {
                throw new HttpBadRequestException($request, 'Le champ "data" est requis');
            }

            $hash = match ($hashRequest->algorithm) {
                'bcrypt' => $this->hashService->hashBcrypt($hashRequest->data, $hashRequest->options),
                'argon2' => $this->hashService->hashArgon2($hashRequest->data, $hashRequest->options),
                'sha256' => $this->hashService->hashData($hashRequest->data, 'sha256'),
                'sha512' => $this->hashService->hashData($hashRequest->data, 'sha512'),
                'hmac-sha256' => $this->hashService->hashHmac(
                    $hashRequest->data, 
                    $hashRequest->options['key'] ?? '', 
                    'sha256'
                ),
                'hmac-sha512' => $this->hashService->hashHmac(
                    $hashRequest->data, 
                    $hashRequest->options['key'] ?? '', 
                    'sha512'
                ),
                default => throw new HttpBadRequestException($request, "Algorithme non supporté: {$hashRequest->algorithm}")
            };

            $hashResponse = new HashResponse(
                hash: $hash,
                algorithm: $hashRequest->algorithm,
                options: $hashRequest->options
            );

        } catch (\InvalidArgumentException $e) {
            $hashResponse = HashResponse::error($e->getMessage());
        } catch (\RuntimeException $e) {
            $hashResponse = HashResponse::error($e->getMessage());
        }

        $response->getBody()->write(json_encode($hashResponse->toArray()));
        return $response->withHeader('Content-Type', 'application/json');
    }
}
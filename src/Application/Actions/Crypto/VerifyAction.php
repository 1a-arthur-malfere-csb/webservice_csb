<?php

declare(strict_types=1);

namespace App\Application\Actions\Crypto;

use App\Domain\Crypto\DTO\VerifyRequest;
use App\Domain\Crypto\DTO\VerifyResponse;
use App\Domain\Crypto\HashServiceInterface;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Exception\HttpBadRequestException;

class VerifyAction
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
            $verifyRequest = VerifyRequest::fromArray($data);
            
            if (empty($verifyRequest->data) || empty($verifyRequest->hash)) {
                throw new HttpBadRequestException($request, 'Les champs "data" et "hash" sont requis');
            }

            $valid = match ($verifyRequest->algorithm) {
                'bcrypt' => $this->hashService->verifyBcrypt($verifyRequest->data, $verifyRequest->hash),
                'argon2' => $this->hashService->verifyArgon2($verifyRequest->data, $verifyRequest->hash),
                default => throw new HttpBadRequestException($request, "Algorithme non supporté: {$verifyRequest->algorithm}")
            };

            $verifyResponse = new VerifyResponse(
                valid: $valid,
                algorithm: $verifyRequest->algorithm
            );

        } catch (\InvalidArgumentException $e) {
            $verifyResponse = VerifyResponse::error($e->getMessage());
        } catch (\RuntimeException $e) {
            $verifyResponse = VerifyResponse::error($e->getMessage());
        }

        $response->getBody()->write(json_encode($verifyResponse->toArray()));
        return $response->withHeader('Content-Type', 'application/json');
    }
}
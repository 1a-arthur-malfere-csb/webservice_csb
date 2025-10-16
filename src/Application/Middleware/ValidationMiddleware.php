<?php

declare(strict_types=1);

namespace App\Application\Middleware;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\MiddlewareInterface as Middleware;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Slim\Exception\HttpBadRequestException;

class ValidationMiddleware implements Middleware
{
    public function process(Request $request, RequestHandler $handler): Response
    {
        $method = $request->getMethod();
        
        // Ne valider que les requêtes POST et PUT
        if (!in_array($method, ['POST', 'PUT'], true)) {
            return $handler->handle($request);
        }
        
        $contentType = $request->getHeaderLine('Content-Type');
        
        if (strpos($contentType, 'application/json') === false) {
            throw new HttpBadRequestException($request, 'Content-Type doit être application/json');
        }

        $body = $request->getBody()->getContents();
        
        if (empty($body)) {
            throw new HttpBadRequestException($request, 'Le corps de la requête ne peut pas être vide');
        }

        $data = json_decode($body, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new HttpBadRequestException($request, 'JSON invalide: ' . json_last_error_msg());
        }

        // Validation des données sensibles
        $this->validateSensitiveData($data, $request);

        // Remettre le corps de la requête pour les handlers suivants
        $request = $request->withParsedBody($data);

        return $handler->handle($request);
    }

    private function validateSensitiveData(array $data, Request $request): void
    {
        // Limiter la taille des données
        $maxDataSize = 1024 * 1024; // 1MB
        $dataString = json_encode($data);
        
        if (strlen($dataString) > $maxDataSize) {
            throw new HttpBadRequestException($request, 'Les données sont trop volumineuses (max 1MB)');
        }

        // Validation des champs requis selon l'endpoint
        $path = $request->getUri()->getPath();
        
        switch ($path) {
            case '/api/hash':
                $this->validateHashRequest($data, $request);
                break;
            case '/api/verify':
                $this->validateVerifyRequest($data, $request);
                break;
            case '/api/encrypt':
                $this->validateEncryptRequest($data, $request);
                break;
            case '/api/decrypt':
                $this->validateDecryptRequest($data, $request);
                break;
        }
    }

    private function validateHashRequest(array $data, Request $request): void
    {
        if (empty($data['data'])) {
            throw new HttpBadRequestException($request, 'Le champ "data" est requis');
        }

        $allowedAlgorithms = ['bcrypt', 'argon2', 'sha256', 'sha512', 'hmac-sha256', 'hmac-sha512'];
        if (!empty($data['algorithm']) && !in_array($data['algorithm'], $allowedAlgorithms, true)) {
            throw new HttpBadRequestException($request, 'Algorithme non supporté');
        }

        // Pour HMAC, vérifier que la clé est fournie
        if (in_array($data['algorithm'] ?? '', ['hmac-sha256', 'hmac-sha512'], true)) {
            if (empty($data['options']['key'])) {
                throw new HttpBadRequestException($request, 'La clé est requise pour HMAC');
            }
        }
    }

    private function validateVerifyRequest(array $data, Request $request): void
    {
        if (empty($data['data']) || empty($data['hash'])) {
            throw new HttpBadRequestException($request, 'Les champs "data" et "hash" sont requis');
        }

        $allowedAlgorithms = ['bcrypt', 'argon2'];
        if (!empty($data['algorithm']) && !in_array($data['algorithm'], $allowedAlgorithms, true)) {
            throw new HttpBadRequestException($request, 'Algorithme non supporté pour la vérification');
        }
    }

    private function validateEncryptRequest(array $data, Request $request): void
    {
        if (empty($data['data'])) {
            throw new HttpBadRequestException($request, 'Le champ "data" est requis');
        }

        // Vérifier qu'au moins une méthode de chiffrement est fournie
        if (empty($data['key']) && empty($data['password'])) {
            // C'est OK, on générera une clé
        } else {
            if (!empty($data['key']) && !empty($data['password'])) {
                throw new HttpBadRequestException($request, 'Fournissez soit "key" soit "password", pas les deux');
            }
        }
    }

    private function validateDecryptRequest(array $data, Request $request): void
    {
        if (empty($data['encrypted_data'])) {
            throw new HttpBadRequestException($request, 'Le champ "encrypted_data" est requis');
        }

        if (empty($data['key']) && empty($data['password'])) {
            throw new HttpBadRequestException($request, 'Soit "key" soit "password" doit être fourni');
        }

        if (!empty($data['key']) && !empty($data['password'])) {
            throw new HttpBadRequestException($request, 'Fournissez soit "key" soit "password", pas les deux');
        }
    }
}
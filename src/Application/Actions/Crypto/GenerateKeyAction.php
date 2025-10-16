<?php

declare(strict_types=1);

namespace App\Application\Actions\Crypto;

use App\Domain\Crypto\EncryptionServiceInterface;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Exception\HttpBadRequestException;

class GenerateKeyAction
{
    public function __construct(
        private EncryptionServiceInterface $encryptionService
    ) {
    }

    public function __invoke(Request $request, Response $response): Response
    {
        $queryParams = $request->getQueryParams();
        $length = (int) ($queryParams['length'] ?? 32);

        try {
            if ($length < 16 || $length > 64) {
                throw new HttpBadRequestException($request, 'La longueur de la clé doit être entre 16 et 64 octets');
            }

            $key = $this->encryptionService->generateKey($length);
            $iv = $this->encryptionService->generateIv();

            $result = [
                'success' => true,
                'key' => base64_encode($key),
                'iv' => base64_encode($iv),
                'key_length' => $length,
                'iv_length' => strlen($iv)
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
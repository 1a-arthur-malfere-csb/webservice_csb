<?php

declare(strict_types=1);

namespace App\Application\Actions\Crypto;

use App\Domain\Crypto\EncryptionServiceInterface;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Exception\HttpBadRequestException;

class EncryptHybridAction
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
            if (empty($data['data'])) {
                throw new HttpBadRequestException($request, 'Le champ "data" est requis');
            }

            if (empty($data['public_key'])) {
                throw new HttpBadRequestException($request, 'Le champ "public_key" est requis');
            }

            $result = $this->encryptionService->encryptHybrid(
                $data['data'], 
                $data['public_key']
            );

            $result['success'] = true;

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

<?php

declare(strict_types=1);

use App\Application\Actions\User\ListUsersAction;
use App\Application\Actions\User\ViewUserAction;
use App\Application\Actions\Crypto\HashAction;
use App\Application\Actions\Crypto\VerifyAction;
use App\Application\Actions\Crypto\EncryptAction;
use App\Application\Actions\Crypto\DecryptAction;
use App\Application\Actions\Crypto\GenerateKeyAction;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\App;
use Slim\Interfaces\RouteCollectorProxyInterface as Group;

return function (App $app) {
    $app->options('/{routes:.*}', function (Request $request, Response $response) {
        // CORS Pre-Flight OPTIONS Request Handler
        return $response;
    });

    $app->get('/', function (Request $request, Response $response) {
        $response->getBody()->write(json_encode([
            'message' => 'API de chiffrement et hachage',
            'version' => '1.0.0',
            'endpoints' => [
                'hash' => 'POST /api/hash',
                'verify' => 'POST /api/verify',
                'encrypt' => 'POST /api/encrypt',
                'decrypt' => 'POST /api/decrypt',
                'generate-key' => 'GET /api/generate-key'
            ]
        ]));
        return $response->withHeader('Content-Type', 'application/json');
    });

    $app->group('/users', function (Group $group) {
        $group->get('', ListUsersAction::class);
        $group->get('/{id}', ViewUserAction::class);
    });

    // API de chiffrement et hachage
    $app->group('/api', function (Group $group) {
        // Endpoints de hachage
        $group->post('/hash', HashAction::class);
        $group->post('/verify', VerifyAction::class);
        
        // Endpoints de chiffrement
        $group->post('/encrypt', EncryptAction::class);
        $group->post('/decrypt', DecryptAction::class);
        $group->get('/generate-key', GenerateKeyAction::class);
    });
};

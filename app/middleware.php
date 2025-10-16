<?php

declare(strict_types=1);

use App\Application\Middleware\SessionMiddleware;
use App\Application\Middleware\ValidationMiddleware;
use Slim\App;

return function (App $app) {
    $app->add(SessionMiddleware::class);
    
    $app->group('/api', function () use ($app) {
        $app->add(ValidationMiddleware::class);
    });
};

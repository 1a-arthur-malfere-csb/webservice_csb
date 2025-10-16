<?php

declare(strict_types=1);

use App\Application\Settings\SettingsInterface;
use App\Domain\Crypto\HashServiceInterface;
use App\Domain\Crypto\EncryptionServiceInterface;
use App\Infrastructure\Crypto\HashService;
use App\Infrastructure\Crypto\EncryptionService;
use DI\ContainerBuilder;
use Monolog\Handler\StreamHandler;
use Monolog\Logger;
use Monolog\Processor\UidProcessor;
use Psr\Container\ContainerInterface;
use Psr\Log\LoggerInterface;

return function (ContainerBuilder $containerBuilder) {
    $containerBuilder->addDefinitions([
        LoggerInterface::class => function (ContainerInterface $c) {
            $settings = $c->get(SettingsInterface::class);

            $loggerSettings = $settings->get('logger');
            $logger = new Logger($loggerSettings['name']);

            $processor = new UidProcessor();
            $logger->pushProcessor($processor);

            $handler = new StreamHandler($loggerSettings['path'], $loggerSettings['level']);
            $logger->pushHandler($handler);

            return $logger;
        },

        // Services de chiffrement et hachage
        HashServiceInterface::class => function (ContainerInterface $c) {
            return new HashService();
        },

        EncryptionServiceInterface::class => function (ContainerInterface $c) {
            return new EncryptionService();
        },
    ]);
};

<?php

declare(strict_types=1);

use App\Application\Settings\SettingsInterface;
use App\Domain\Crypto\HashServiceInterface;
use App\Domain\Crypto\EncryptionServiceInterface;
use App\Infrastructure\Crypto\HashService;
use App\Infrastructure\Crypto\EncryptionService;
use App\Application\Actions\Crypto\EncryptArgon2Action;
use App\Application\Actions\Crypto\DecryptArgon2Action;
use App\Application\Actions\Crypto\EncryptHybridAction;
use App\Application\Actions\Crypto\DecryptHybridAction;
use App\Application\Actions\Crypto\GenerateRsaKeyPairAction;
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

        HashServiceInterface::class => function (ContainerInterface $c) {
            return new HashService();
        },

        EncryptionServiceInterface::class => function (ContainerInterface $c) {
            return new EncryptionService();
        },

        EncryptArgon2Action::class => function (ContainerInterface $c) {
            return new EncryptArgon2Action($c->get(EncryptionServiceInterface::class));
        },

        DecryptArgon2Action::class => function (ContainerInterface $c) {
            return new DecryptArgon2Action($c->get(EncryptionServiceInterface::class));
        },

        EncryptHybridAction::class => function (ContainerInterface $c) {
            return new EncryptHybridAction($c->get(EncryptionServiceInterface::class));
        },

        DecryptHybridAction::class => function (ContainerInterface $c) {
            return new DecryptHybridAction($c->get(EncryptionServiceInterface::class));
        },

        GenerateRsaKeyPairAction::class => function (ContainerInterface $c) {
            return new GenerateRsaKeyPairAction($c->get(EncryptionServiceInterface::class));
        },
    ]);
};

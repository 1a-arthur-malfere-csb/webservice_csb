
# ========================================
# STAGE 1: Build - Installation des dépendances
# ========================================
FROM composer:2.6 AS composer

# Copier les fichiers de configuration Composer
COPY composer.json composer.lock ./

# Installer les dépendances de production uniquement
RUN composer install \
    --no-dev \
    --no-scripts \
    --no-autoloader \
    --optimize-autoloader \
    --classmap-authoritative \
    --no-interaction \
    --prefer-dist

# ========================================
# STAGE 2: Runtime - Image finale optimisée
# ========================================
FROM php:8.2-alpine AS runtime

# Métadonnées de l'image
LABEL maintainer="API de Chiffrement et Hachage" \
      description="Microservice PHP Slim Framework pour le chiffrement et hachage" \
      version="1.0.0"

# Variables d'environnement
ENV APP_ENV=production \
    APP_DEBUG=false \
    PHP_MEMORY_LIMIT=256M \
    PHP_MAX_EXECUTION_TIME=30 \
    PHP_UPLOAD_MAX_FILESIZE=1M \
    PHP_POST_MAX_SIZE=1M

# Installer les extensions PHP nécessaires
RUN apk add --no-cache \
    # Extensions PHP essentielles
    php82-json \
    php82-openssl \
    php82-mbstring \
    php82-tokenizer \
    php82-xml \
    php82-ctype \
    php82-fileinfo \
    php82-pdo \
    php82-pdo_sqlite \
    # Outils système légers
    tini \
    # Nettoyage
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -g 1000 appuser && \
    adduser -D -s /bin/sh -u 1000 -G appuser appuser

# Créer les répertoires nécessaires
RUN mkdir -p /var/www/html \
    && mkdir -p /var/www/logs \
    && chown -R appuser:appuser /var/www

# Définir le répertoire de travail
WORKDIR /var/www/html

# Copier les fichiers de l'application
COPY --chown=appuser:appuser . .

# Copier les dépendances installées depuis le stage composer
COPY --from=composer --chown=appuser:appuser /app/vendor ./vendor

# L'autoloader est déjà optimisé dans le stage composer

# Créer le fichier de configuration PHP optimisé
RUN echo "memory_limit = \${PHP_MEMORY_LIMIT}" > /usr/local/etc/php/conf.d/memory.ini && \
    echo "max_execution_time = \${PHP_MAX_EXECUTION_TIME}" > /usr/local/etc/php/conf.d/execution.ini && \
    echo "upload_max_filesize = \${PHP_UPLOAD_MAX_FILESIZE}" > /usr/local/etc/php/conf.d/upload.ini && \
    echo "post_max_size = \${PHP_POST_MAX_SIZE}" > /usr/local/etc/php/conf.d/post.ini && \
    echo "opcache.enable = 1" > /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.memory_consumption = 128" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.interned_strings_buffer = 8" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.max_accelerated_files = 4000" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.revalidate_freq = 2" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.fast_shutdown = 1" >> /usr/local/etc/php/conf.d/opcache.ini

# Créer un script de démarrage optimisé
RUN echo '#!/bin/sh' > /usr/local/bin/start.sh && \
    echo 'echo "🚀 Démarrage de l'\''API de Chiffrement et Hachage..."' >> /usr/local/bin/start.sh && \
    echo 'echo "📊 Environnement: $APP_ENV"' >> /usr/local/bin/start.sh && \
    echo 'echo "🔧 PHP Version: $(php -v | head -n1)"' >> /usr/local/bin/start.sh && \
    echo 'echo "💾 Mémoire: $PHP_MEMORY_LIMIT"' >> /usr/local/bin/start.sh && \
    echo 'echo "🌐 Serveur démarré sur le port 8080"' >> /usr/local/bin/start.sh && \
    echo 'exec php -S 0.0.0.0:8080 -t public' >> /usr/local/bin/start.sh && \
    chmod +x /usr/local/bin/start.sh

# Nettoyer les fichiers inutiles pour réduire la taille
RUN rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && find /var/log -type f -name "*.log" -delete \
    && find /usr/local/lib/php -name "*.a" -delete \
    && find /usr/local/lib/php -name "*.la" -delete

# Changer vers l'utilisateur non-root
USER appuser

# Exposer le port
EXPOSE 8080

# Point d'entrée avec tini pour une meilleure gestion des signaux
ENTRYPOINT ["tini", "--"]

# Commande de démarrage
CMD ["/usr/local/bin/start.sh"]

# Healthcheck pour vérifier que l'API fonctionne
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

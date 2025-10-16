.PHONY: help build test start stop clean logs shell status dev

# Configuration par défaut
IMAGE_NAME = crypto-api
TAG = latest
PORT = 8080
CONTAINER_NAME = crypto-api

# Couleurs
GREEN = \033[0;32m
BLUE = \033[0;34m
YELLOW = \033[1;33m
NC = \033[0m

# Aide par défaut
help: ## Afficher cette aide
	@echo "$(BLUE)🚀 API de Chiffrement et Hachage - Commandes disponibles$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Exemples:$(NC)"
	@echo "  make build          # Construire l'image Docker"
	@echo "  make start          # Démarrer l'API"
	@echo "  make test           # Tester l'API"
	@echo "  make dev            # Mode développement avec docker-compose"

# Construction de l'image Docker
build: ## Construire l'image Docker optimisée
	@echo "$(BLUE)🔨 Construction de l'image Docker...$(NC)"
	@./docker-build.sh -t $(TAG)
	@echo "$(GREEN)✓ Image construite avec succès$(NC)"

# Test de l'image
test-image: ## Tester l'image Docker
	@echo "$(BLUE)🧪 Test de l'image Docker...$(NC)"
	@./docker-build.sh -t $(TAG) -c

# Démarrage de l'API
start: ## Démarrer l'API en mode production
	@echo "$(BLUE)🚀 Démarrage de l'API...$(NC)"
	@./docker-deploy.sh start -p $(PORT) -t $(TAG)
	@echo "$(GREEN)✓ API démarrée sur le port $(PORT)$(NC)"

# Test de l'API
test: ## Tester l'API avec les tests complets
	@echo "$(BLUE)🧪 Test de l'API...$(NC)"
	@./docker-deploy.sh test -p $(PORT)

# Mode développement
dev: ## Démarrer en mode développement avec docker-compose
	@echo "$(BLUE)🔧 Mode développement...$(NC)"
	@./docker-deploy.sh dev
	@echo "$(GREEN)✓ Services démarrés$(NC)"

# Arrêt de l'API
stop: ## Arrêter l'API
	@echo "$(BLUE)🛑 Arrêt de l'API...$(NC)"
	@./docker-deploy.sh stop
	@echo "$(GREEN)✓ API arrêtée$(NC)"

# Affichage des logs
logs: ## Afficher les logs de l'API
	@./docker-deploy.sh logs

# Shell dans le conteneur
shell: ## Ouvrir un shell dans le conteneur
	@./docker-deploy.sh shell

# Statut des conteneurs
status: ## Afficher le statut des conteneurs
	@./docker-deploy.sh status

# Nettoyage
clean: ## Nettoyer les conteneurs et images
	@echo "$(BLUE)🧹 Nettoyage...$(NC)"
	@./docker-deploy.sh clean
	@echo "$(GREEN)✓ Nettoyage terminé$(NC)"

# Nettoyage complet
clean-all: clean ## Nettoyage complet (conteneurs, images, volumes)
	@echo "$(BLUE)🧹 Nettoyage complet...$(NC)"
	@docker system prune -af
	@echo "$(GREEN)✓ Nettoyage complet terminé$(NC)"

# Build et test complet
build-test: build test-image ## Construire et tester l'image
	@echo "$(GREEN)✓ Build et test terminés$(NC)"

# Déploiement complet
deploy: build start test ## Déploiement complet (build + start + test)
	@echo "$(GREEN)🎉 Déploiement complet terminé !$(NC)"

# Redémarrage
restart: stop start ## Redémarrer l'API
	@echo "$(GREEN)✓ API redémarrée$(NC)"

# Mise à jour
update: stop build start ## Mettre à jour l'API (stop + build + start)
	@echo "$(GREEN)✓ API mise à jour$(NC)"

# Test de performance
perf: ## Test de performance de l'API
	@echo "$(BLUE)⚡ Test de performance...$(NC)"
	@if ! command -v ab &> /dev/null; then \
		echo "$(YELLOW)⚠️  Apache Bench (ab) non installé, installation...$(NC)"; \
		sudo apt-get update && sudo apt-get install -y apache2-utils; \
	fi
	@ab -n 1000 -c 10 http://localhost:$(PORT)/
	@echo "$(GREEN)✓ Test de performance terminé$(NC)"

# Analyse de l'image
analyze: ## Analyser la taille et les couches de l'image
	@echo "$(BLUE)📊 Analyse de l'image...$(NC)"
	@docker images $(IMAGE_NAME):$(TAG) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
	@echo ""
	@echo "Couches de l'image:"
	@docker history $(IMAGE_NAME):$(TAG) --format "table {{.CreatedBy}}\t{{.Size}}" --no-trunc

# Push vers registry
push: ## Pousser l'image vers un registry
	@echo "$(BLUE)📤 Push de l'image...$(NC)"
	@./docker-build.sh -t $(TAG) -p
	@echo "$(GREEN)✓ Image poussée$(NC)"

# Installation des dépendances
install: ## Installer les dépendances PHP
	@echo "$(BLUE)📦 Installation des dépendances...$(NC)"
	@composer install --optimize-autoloader
	@echo "$(GREEN)✓ Dépendances installées$(NC)"

# Tests unitaires
test-unit: ## Exécuter les tests unitaires
	@echo "$(BLUE)🧪 Tests unitaires...$(NC)"
	@composer test
	@echo "$(GREEN)✓ Tests unitaires terminés$(NC)"

# Linting
lint: ## Exécuter le linting du code
	@echo "$(BLUE)🔍 Linting du code...$(NC)"
	@composer run-script phpcs
	@echo "$(GREEN)✓ Linting terminé$(NC)"

# Fix du code
fix: ## Corriger automatiquement le code
	@echo "$(BLUE)🔧 Correction du code...$(NC)"
	@composer run-script phpcbf
	@echo "$(GREEN)✓ Code corrigé$(NC)"

# Documentation
docs: ## Générer la documentation
	@echo "$(BLUE)📚 Génération de la documentation...$(NC)"
	@echo "$(GREEN)✓ Documentation disponible dans les fichiers .md$(NC)"

# Informations sur l'environnement
info: ## Afficher les informations sur l'environnement
	@echo "$(BLUE)ℹ️  Informations sur l'environnement$(NC)"
	@echo "Docker version: $$(docker --version)"
	@echo "Docker Compose version: $$(docker-compose --version)"
	@echo "PHP version: $$(php --version | head -n1)"
	@echo "Composer version: $$(composer --version)"
	@echo "Image: $(IMAGE_NAME):$(TAG)"
	@echo "Port: $(PORT)"

# Par défaut
.DEFAULT_GOAL := help

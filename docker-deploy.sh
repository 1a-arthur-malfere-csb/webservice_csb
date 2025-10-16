#!/bin/bash

# Script de déploiement et test Docker pour l'API de chiffrement et hachage

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
IMAGE_NAME="crypto-api"
TAG="latest"
CONTAINER_NAME="crypto-api-test"
PORT="8080"
HEALTH_CHECK_URL="http://localhost:$PORT"

echo -e "${BLUE}🚀 DÉPLOIEMENT DOCKER${NC}"
echo -e "${BLUE}===================${NC}"
echo ""

# Fonction d'aide
show_help() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start       Démarrer l'API en mode production"
    echo "  test        Dester l'API avec les tests complets"
    echo "  dev         Démarrer en mode développement"
    echo "  stop        Arrêter l'API"
    echo "  logs        Afficher les logs"
    echo "  shell       Ouvrir un shell dans le conteneur"
    echo "  clean       Nettoyer les conteneurs et images"
    echo "  status      Afficher le statut des conteneurs"
    echo ""
    echo "Options:"
    echo "  -p, --port PORT     Port à utiliser (défaut: 8080)"
    echo "  -t, --tag TAG       Tag de l'image à utiliser"
    echo "  -h, --help          Afficher cette aide"
}

# Fonction pour vérifier si Docker est disponible
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker n'est pas installé${NC}"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker n'est pas démarré${NC}"
        exit 1
    fi
}

# Fonction pour arrêter les conteneurs existants
stop_existing() {
    echo -e "${YELLOW}🛑 Arrêt des conteneurs existants...${NC}"
    
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        docker stop "$CONTAINER_NAME" > /dev/null
        docker rm "$CONTAINER_NAME" > /dev/null
        echo -e "${GREEN}✓ Conteneur arrêté${NC}"
    fi
}

# Fonction pour démarrer l'API
start_api() {
    echo -e "${BLUE}🚀 Démarrage de l'API...${NC}"
    
    # Vérifier que l'image existe
    if ! docker images | grep -q "$IMAGE_NAME.*$TAG"; then
        echo -e "${YELLOW}⚠️  Image $IMAGE_NAME:$TAG non trouvée, construction...${NC}"
        ./docker-build.sh -t "$TAG"
    fi
    
    # Démarrer le conteneur
    docker run -d \
        --name "$CONTAINER_NAME" \
        -p "$PORT:8080" \
        -e APP_ENV=production \
        -e APP_DEBUG=false \
        "$IMAGE_NAME:$TAG"
    
    echo -e "${GREEN}✓ API démarrée sur le port $PORT${NC}"
    
    # Attendre que l'API soit prête
    echo -e "${YELLOW}⏳ Attente du démarrage de l'API...${NC}"
    sleep 10
    
    # Vérifier la santé
    if curl -f "$HEALTH_CHECK_URL/" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ API prête et accessible${NC}"
    else
        echo -e "${RED}❌ API non accessible${NC}"
        docker logs "$CONTAINER_NAME"
        exit 1
    fi
}

# Fonction pour démarrer en mode développement
start_dev() {
    echo -e "${BLUE}🔧 Démarrage en mode développement...${NC}"
    
    # Démarrer avec docker-compose
    docker-compose up -d
    
    echo -e "${GREEN}✓ Services démarrés${NC}"
    echo -e "${BLUE}API disponible sur: http://localhost:8080${NC}"
    echo -e "${BLUE}Nginx disponible sur: http://localhost:80${NC}"
}

# Fonction pour tester l'API
test_api() {
    echo -e "${BLUE}🧪 Test de l'API...${NC}"
    
    # Vérifier que l'API est accessible
    if ! curl -f "$HEALTH_CHECK_URL/" > /dev/null 2>&1; then
        echo -e "${RED}❌ API non accessible sur $HEALTH_CHECK_URL${NC}"
        exit 1
    fi
    
    # Exécuter les tests complets
    echo -e "${BLUE}Exécution des tests complets...${NC}"
    BASE_URL="$HEALTH_CHECK_URL" ./test_complete.sh
    
    echo -e "${GREEN}✓ Tests terminés${NC}"
}

# Fonction pour afficher les logs
show_logs() {
    echo -e "${BLUE}📋 Logs de l'API...${NC}"
    docker logs -f "$CONTAINER_NAME"
}

# Fonction pour ouvrir un shell
open_shell() {
    echo -e "${BLUE}🐚 Ouverture d'un shell...${NC}"
    docker exec -it "$CONTAINER_NAME" /bin/sh
}

# Fonction pour arrêter l'API
stop_api() {
    echo -e "${BLUE}🛑 Arrêt de l'API...${NC}"
    
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        docker stop "$CONTAINER_NAME" > /dev/null
        docker rm "$CONTAINER_NAME" > /dev/null
        echo -e "${GREEN}✓ API arrêtée${NC}"
    else
        echo -e "${YELLOW}⚠️  Aucun conteneur API en cours d'exécution${NC}"
    fi
    
    # Arrêter docker-compose si actif
    if docker-compose ps -q | grep -q .; then
        docker-compose down
        echo -e "${GREEN}✓ Services docker-compose arrêtés${NC}"
    fi
}

# Fonction pour nettoyer
clean_all() {
    echo -e "${BLUE}🧹 Nettoyage...${NC}"
    
    # Arrêter tous les conteneurs
    stop_api
    
    # Nettoyer les images inutiles
    docker image prune -f
    docker container prune -f
    docker volume prune -f
    
    echo -e "${GREEN}✓ Nettoyage terminé${NC}"
}

# Fonction pour afficher le statut
show_status() {
    echo -e "${BLUE}📊 Statut des conteneurs...${NC}"
    echo ""
    
    # Conteneurs en cours d'exécution
    echo "Conteneurs actifs:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    
    # Images disponibles
    echo "Images disponibles:"
    docker images | grep "$IMAGE_NAME" || echo "Aucune image $IMAGE_NAME trouvée"
    echo ""
    
    # Utilisation des ressources
    echo "Utilisation des ressources:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null || echo "Aucun conteneur en cours d'exécution"
}

# Parse des arguments
COMMAND=""
while [[ $# -gt 0 ]]; do
    case $1 in
        start|test|dev|stop|logs|shell|clean|status)
            COMMAND="$1"
            shift
            ;;
        -p|--port)
            PORT="$2"
            HEALTH_CHECK_URL="http://localhost:$PORT"
            shift 2
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Commande inconnue: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Vérifier Docker
check_docker

# Exécuter la commande
case $COMMAND in
    start)
        stop_existing
        start_api
        echo -e "${GREEN}🎉 API démarrée avec succès !${NC}"
        echo -e "${BLUE}URL: $HEALTH_CHECK_URL${NC}"
        ;;
    test)
        test_api
        ;;
    dev)
        start_dev
        ;;
    stop)
        stop_api
        ;;
    logs)
        show_logs
        ;;
    shell)
        open_shell
        ;;
    clean)
        clean_all
        ;;
    status)
        show_status
        ;;
    "")
        echo -e "${RED}❌ Aucune commande spécifiée${NC}"
        show_help
        exit 1
        ;;
esac

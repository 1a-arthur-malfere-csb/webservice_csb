#!/bin/bash

# Script de déploiement optimisé pour l'API de chiffrement et hachage

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}🚀 DÉPLOIEMENT OPTIMISÉ - API DE CHIFFREMENT ET HACHAGE${NC}"
echo -e "${BLUE}====================================================${NC}"
echo ""

# Configuration
IMAGE_NAME="crypto-api"
TAG="latest"
CONTAINER_NAME="crypto-api-optimized"
PORT="8080"

# Fonction d'aide
show_help() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  full        Déploiement complet (nettoyage + build + test + start)"
    echo "  build       Construction de l'image optimisée"
    echo "  start       Démarrage de l'API"
    echo "  test        Test de l'API"
    echo "  stop        Arrêt de l'API"
    echo "  clean       Nettoyage complet"
    echo "  status      Statut des services"
    echo ""
    echo "Options:"
    echo "  -t, --tag TAG       Tag de l'image (défaut: latest)"
    echo "  -p, --port PORT     Port à utiliser (défaut: 8080)"
    echo "  -h, --help          Afficher cette aide"
}

# Fonction de nettoyage
clean_project() {
    echo -e "${YELLOW}🧹 Nettoyage du projet...${NC}"
    ./cleanup.sh
    echo -e "${GREEN}✓ Projet nettoyé${NC}"
}

# Fonction de construction
build_image() {
    echo -e "${BLUE}🔨 Construction de l'image optimisée...${NC}"
    make build
    echo -e "${GREEN}✓ Image construite${NC}"
}

# Fonction de test
test_api() {
    echo -e "${BLUE}🧪 Test de l'API...${NC}"
    make test
    echo -e "${GREEN}✓ Tests terminés${NC}"
}

# Fonction de démarrage
start_api() {
    echo -e "${BLUE}🚀 Démarrage de l'API...${NC}"
    make start
    echo -e "${GREEN}✓ API démarrée${NC}"
}

# Fonction d'arrêt
stop_api() {
    echo -e "${BLUE}🛑 Arrêt de l'API...${NC}"
    make stop
    echo -e "${GREEN}✓ API arrêtée${NC}"
}

# Fonction de statut
show_status() {
    echo -e "${BLUE}📊 Statut des services...${NC}"
    make status
}

# Fonction de nettoyage complet
clean_all() {
    echo -e "${BLUE}🧹 Nettoyage complet...${NC}"
    make clean-all
    echo -e "${GREEN}✓ Nettoyage complet terminé${NC}"
}

# Fonction de déploiement complet
deploy_full() {
    echo -e "${PURPLE}🚀 DÉPLOIEMENT COMPLET${NC}"
    echo -e "${PURPLE}====================${NC}"
    echo ""
    
    # 1. Nettoyage
    echo -e "${YELLOW}Étape 1/5: Nettoyage du projet${NC}"
    clean_project
    echo ""
    
    # 2. Construction
    echo -e "${YELLOW}Étape 2/5: Construction de l'image${NC}"
    build_image
    echo ""
    
    # 3. Test
    echo -e "${YELLOW}Étape 3/5: Test de l'image${NC}"
    test_api
    echo ""
    
    # 4. Démarrage
    echo -e "${YELLOW}Étape 4/5: Démarrage de l'API${NC}"
    start_api
    echo ""
    
    # 5. Vérification
    echo -e "${YELLOW}Étape 5/5: Vérification finale${NC}"
    show_status
    echo ""
    
    echo -e "${GREEN}🎉 DÉPLOIEMENT COMPLET TERMINÉ !${NC}"
    echo -e "${GREEN}API disponible sur: http://localhost:${PORT}${NC}"
    echo ""
    echo -e "${BLUE}Commandes utiles:${NC}"
    echo "  make logs     # Voir les logs"
    echo "  make shell    # Shell dans le conteneur"
    echo "  make stop     # Arrêter l'API"
    echo "  make test     # Tester l'API"
}

# Parse des arguments
COMMAND=""
while [[ $# -gt 0 ]]; do
    case $1 in
        full|build|start|test|stop|clean|status)
            COMMAND="$1"
            shift
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
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

# Exécuter la commande
case $COMMAND in
    full)
        deploy_full
        ;;
    build)
        build_image
        ;;
    start)
        start_api
        ;;
    test)
        test_api
        ;;
    stop)
        stop_api
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

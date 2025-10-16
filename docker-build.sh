#!/bin/bash

# Script de build Docker optimisé pour l'API de chiffrement et hachage

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
IMAGE_NAME="crypto-api"
TAG="latest"
REGISTRY=""
FULL_IMAGE_NAME="${REGISTRY}${IMAGE_NAME}:${TAG}"

echo -e "${BLUE}🐳 BUILD DOCKER OPTIMISÉ${NC}"
echo -e "${BLUE}========================${NC}"
echo ""

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --tag TAG        Tag de l'image (défaut: latest)"
    echo "  -r, --registry URL   Registry Docker (optionnel)"
    echo "  -p, --push           Pousser l'image vers le registry"
    echo "  -c, --clean          Nettoyer les images inutiles après le build"
    echo "  -h, --help           Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0                           # Build avec tag latest"
    echo "  $0 -t v1.0.0                # Build avec tag v1.0.0"
    echo "  $0 -r myregistry.com/ -p    # Build et push vers registry"
    echo "  $0 -c                       # Build avec nettoyage"
}

# Fonction de nettoyage
cleanup() {
    echo -e "${YELLOW}🧹 Nettoyage des images inutiles...${NC}"
    docker image prune -f
    docker builder prune -f
    echo -e "${GREEN}✓ Nettoyage terminé${NC}"
}

# Fonction de build
build_image() {
    echo -e "${BLUE}🔨 Construction de l'image Docker...${NC}"
    echo "Image: $FULL_IMAGE_NAME"
    echo ""
    
    # Build avec cache optimisé
    docker build \
        --target runtime \
        --tag "$FULL_IMAGE_NAME" \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --progress=plain \
        .
    
    echo -e "${GREEN}✓ Image construite avec succès${NC}"
}

# Fonction de test de l'image
test_image() {
    echo -e "${BLUE}🧪 Test de l'image...${NC}"
    
    # Démarrer le conteneur en arrière-plan
    CONTAINER_ID=$(docker run -d -p 8080:8080 "$FULL_IMAGE_NAME")
    
    # Attendre que le conteneur démarre
    echo "Attente du démarrage du conteneur..."
    sleep 10
    
    # Test de santé
    if curl -f http://localhost:8080/ > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Test de santé réussi${NC}"
    else
        echo -e "${RED}✗ Test de santé échoué${NC}"
        docker logs "$CONTAINER_ID"
        docker stop "$CONTAINER_ID" > /dev/null
        exit 1
    fi
    
    # Arrêter le conteneur
    docker stop "$CONTAINER_ID" > /dev/null
    docker rm "$CONTAINER_ID" > /dev/null
    
    echo -e "${GREEN}✓ Tests terminés avec succès${NC}"
}

# Fonction de push
push_image() {
    echo -e "${BLUE}📤 Push de l'image vers le registry...${NC}"
    docker push "$FULL_IMAGE_NAME"
    echo -e "${GREEN}✓ Image poussée avec succès${NC}"
}

# Fonction d'analyse de l'image
analyze_image() {
    echo -e "${BLUE}📊 Analyse de l'image...${NC}"
    echo ""
    
    # Taille de l'image
    SIZE=$(docker images --format "table {{.Size}}" "$FULL_IMAGE_NAME" | tail -n1)
    echo "Taille de l'image: $SIZE"
    
    # Couches de l'image
    echo ""
    echo "Couches de l'image:"
    docker history "$FULL_IMAGE_NAME" --format "table {{.CreatedBy}}\t{{.Size}}" --no-trunc
    
    # Informations détaillées
    echo ""
    echo "Informations de l'image:"
    docker inspect "$FULL_IMAGE_NAME" | jq -r '.[0] | {
        "Architecture": .Architecture,
        "Os": .Os,
        "Created": .Created,
        "Size": .Size,
        "VirtualSize": .VirtualSize,
        "RootFS": .RootFS.Type
    }'
}

# Parse des arguments
PUSH=false
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tag)
            TAG="$2"
            FULL_IMAGE_NAME="${REGISTRY}${IMAGE_NAME}:${TAG}"
            shift 2
            ;;
        -r|--registry)
            REGISTRY="$2/"
            FULL_IMAGE_NAME="${REGISTRY}${IMAGE_NAME}:${TAG}"
            shift 2
            ;;
        -p|--push)
            PUSH=true
            shift
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Option inconnue: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Vérifier que Docker est disponible
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé${NC}"
    exit 1
fi

# Vérifier que jq est disponible pour l'analyse
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️  jq n'est pas installé, l'analyse détaillée sera limitée${NC}"
fi

# Exécution du build
echo -e "${BLUE}🚀 Démarrage du build Docker${NC}"
echo "Image finale: $FULL_IMAGE_NAME"
echo ""

# Build de l'image
build_image

# Test de l'image
test_image

# Analyse de l'image
analyze_image

# Push si demandé
if [ "$PUSH" = true ]; then
    push_image
fi

# Nettoyage si demandé
if [ "$CLEAN" = true ]; then
    cleanup
fi

echo ""
echo -e "${GREEN}🎉 Build terminé avec succès !${NC}"
echo -e "${GREEN}Image: $FULL_IMAGE_NAME${NC}"
echo ""
echo -e "${BLUE}Commandes utiles:${NC}"
echo "  docker run -p 8080:8080 $FULL_IMAGE_NAME"
echo "  docker-compose up -d"
echo "  docker images | grep $IMAGE_NAME"

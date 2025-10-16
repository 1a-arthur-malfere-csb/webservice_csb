#!/bin/bash

# Script de démarrage et test rapide pour l'API
# Microservice PHP Slim Framework

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 DÉMARRAGE ET TEST DE L'API${NC}"
echo -e "${BLUE}============================${NC}"
echo ""

# Vérifier si le serveur est déjà en cours d'exécution
if curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Le serveur est déjà en cours d'exécution${NC}"
    echo -e "${GREEN}✓ Test de l'API...${NC}"
    ./test_api.sh
else
    echo -e "${BLUE}📦 Installation des dépendances...${NC}"
    composer install --no-dev --optimize-autoloader
    
    echo -e "${BLUE}🔄 Démarrage du serveur en arrière-plan...${NC}"
    composer start &
    SERVER_PID=$!
    
    # Attendre que le serveur démarre
    echo -e "${YELLOW}⏳ Attente du démarrage du serveur...${NC}"
    sleep 3
    
    # Vérifier si le serveur a démarré
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Serveur démarré avec succès (PID: $SERVER_PID)${NC}"
        echo ""
        
        # Exécuter les tests
        echo -e "${GREEN}🧪 Exécution des tests complets...${NC}"
        ./test_complete.sh
        TEST_RESULT=$?
        
        echo ""
        echo -e "${BLUE}🛑 Arrêt du serveur...${NC}"
        kill $SERVER_PID 2>/dev/null
        
        exit $TEST_RESULT
    else
        echo -e "${RED}✗ Échec du démarrage du serveur${NC}"
        kill $SERVER_PID 2>/dev/null
        exit 1
    fi
fi

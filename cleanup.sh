#!/bin/bash

# Script de nettoyage pour supprimer les fichiers inutiles du projet

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧹 NETTOYAGE DU PROJET${NC}"
echo -e "${BLUE}======================${NC}"
echo ""

# Fonction pour afficher la taille avant/après
show_size() {
    local path="$1"
    if [ -d "$path" ]; then
        local size=$(du -sh "$path" 2>/dev/null | cut -f1)
        echo "Taille: $size"
    fi
}

# Afficher la taille initiale
echo -e "${YELLOW}📊 Taille initiale du projet:${NC}"
show_size "."

echo ""
echo -e "${BLUE}🗑️  Suppression des fichiers inutiles...${NC}"

# Supprimer les fichiers de test redondants
echo "Suppression des scripts de test redondants..."
rm -f test_api.sh test_advanced_encryption.sh test_encryption_simple.sh quick_test.sh start_and_test.sh

# Supprimer la documentation redondante
echo "Suppression de la documentation redondante..."
rm -f README.md

# Supprimer les logs
echo "Suppression des logs..."
rm -rf logs/*.log
rm -f logs/README.md

# Nettoyer le cache
echo "Nettoyage du cache..."
rm -rf var/cache/*

# Supprimer les fichiers de configuration de développement
echo "Suppression des fichiers de configuration de développement..."
rm -f .php_cs.cache
rm -f .phpunit.result.cache

# Supprimer les fichiers temporaires
echo "Suppression des fichiers temporaires..."
find . -name "*.tmp" -delete
find . -name "*.bak" -delete
find . -name "*.backup" -delete
find . -name "*~" -delete

# Supprimer les fichiers de l'éditeur
echo "Suppression des fichiers de l'éditeur..."
find . -name "*.swp" -delete
find . -name "*.swo" -delete
find . -name ".DS_Store" -delete
find . -name "Thumbs.db" -delete

# Nettoyer les répertoires vides
echo "Suppression des répertoires vides..."
find . -type d -empty -not -path "./.git*" -delete 2>/dev/null || true

echo ""
echo -e "${GREEN}✅ Nettoyage terminé !${NC}"

# Afficher la taille finale
echo ""
echo -e "${YELLOW}📊 Taille finale du projet:${NC}"
show_size "."

# Afficher les fichiers restants
echo ""
echo -e "${BLUE}📁 Fichiers restants:${NC}"
find . -type f -not -path "./.git/*" -not -path "./vendor/*" | head -20

echo ""
echo -e "${GREEN}🎉 Projet nettoyé avec succès !${NC}"
echo -e "${BLUE}💡 Conseil: Utilisez 'make build' pour construire l'image Docker optimisée${NC}"

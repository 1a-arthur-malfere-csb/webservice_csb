#!/bin/bash

# Script de test rapide pour tester des endpoints spécifiques
# Usage: ./quick_test.sh [endpoint]

# Configuration
BASE_URL="http://localhost:8080"
API_URL="${BASE_URL}/api"

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Fonction d'aide
show_help() {
    echo -e "${BLUE}🔧 SCRIPT DE TEST RAPIDE${NC}"
    echo -e "${BLUE}=======================${NC}"
    echo ""
    echo "Usage: $0 [endpoint]"
    echo ""
    echo "Endpoints disponibles:"
    echo "  home          - Page d'accueil"
    echo "  users         - Liste des utilisateurs"
    echo "  hash          - Test de hachage bcrypt"
    echo "  verify        - Test de vérification de hachage"
    echo "  encrypt       - Test de chiffrement"
    echo "  decrypt       - Test de déchiffrement"
    echo "  generate-key  - Test de génération de clé"
    echo "  all           - Tous les tests"
    echo ""
    echo "Exemples:"
    echo "  $0 hash"
    echo "  $0 encrypt"
    echo "  $0 all"
}

# Test de la page d'accueil
test_home() {
    echo -e "${YELLOW}🏠 Test de la page d'accueil${NC}"
    curl -s "$BASE_URL" | jq .
}

# Test des utilisateurs
test_users() {
    echo -e "${YELLOW}👥 Test des utilisateurs${NC}"
    curl -s "$BASE_URL/users" | jq .
}

# Test de hachage
test_hash() {
    echo -e "${YELLOW}🔐 Test de hachage bcrypt${NC}"
    curl -s -X POST -H "Content-Type: application/json" \
        -d '{"data": "mon_mot_de_passe", "algorithm": "bcrypt", "options": {"cost": 12}}' \
        "$API_URL/hash" | jq .
}

# Test de vérification
test_verify() {
    echo -e "${YELLOW}✅ Test de vérification de hachage${NC}"
    # D'abord créer un hash
    hash_response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d '{"data": "mon_mot_de_passe", "algorithm": "bcrypt"}' \
        "$API_URL/hash")
    
    hash_value=$(echo "$hash_response" | jq -r '.hash')
    echo "Hash généré: $hash_value"
    echo ""
    
    # Puis le vérifier
    curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"data\": \"mon_mot_de_passe\", \"hash\": \"$hash_value\", \"algorithm\": \"bcrypt\"}" \
        "$API_URL/verify" | jq .
}

# Test de chiffrement
test_encrypt() {
    echo -e "${YELLOW}🔒 Test de chiffrement${NC}"
    curl -s -X POST -H "Content-Type: application/json" \
        -d '{"data": "Données sensibles", "password": "mon_mot_de_passe_secret"}' \
        "$API_URL/encrypt" | jq .
}

# Test de déchiffrement
test_decrypt() {
    echo -e "${YELLOW}🔓 Test de déchiffrement${NC}"
    # D'abord chiffrer des données
    encrypt_response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d '{"data": "Données de test", "password": "test_password"}' \
        "$API_URL/encrypt")
    
    echo "Données chiffrées:"
    echo "$encrypt_response" | jq .
    echo ""
    
    # Extraire les paramètres nécessaires
    encrypted_data=$(echo "$encrypt_response" | jq -r '.encrypted_data')
    iv=$(echo "$encrypt_response" | jq -r '.iv')
    tag=$(echo "$encrypt_response" | jq -r '.tag')
    salt=$(echo "$encrypt_response" | jq -r '.salt')
    iterations=$(echo "$encrypt_response" | jq -r '.iterations')
    
    # Déchiffrer
    echo "Déchiffrement:"
    curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"encrypted_data\": \"$encrypted_data\", \"password\": \"test_password\", \"iv\": \"$iv\", \"tag\": \"$tag\", \"salt\": \"$salt\", \"iterations\": $iterations}" \
        "$API_URL/decrypt" | jq .
}

# Test de génération de clé
test_generate_key() {
    echo -e "${YELLOW}🔑 Test de génération de clé${NC}"
    curl -s "$API_URL/generate-key" | jq .
}

# Test de tous les endpoints
test_all() {
    echo -e "${BLUE}🧪 TEST COMPLET DE L'API${NC}"
    echo -e "${BLUE}=======================${NC}"
    echo ""
    
    test_home
    echo ""
    test_users
    echo ""
    test_hash
    echo ""
    test_verify
    echo ""
    test_encrypt
    echo ""
    test_decrypt
    echo ""
    test_generate_key
}

# Vérifier si le serveur est démarré
check_server() {
    if ! curl -s "$BASE_URL" > /dev/null 2>&1; then
        echo -e "${RED}✗ Serveur non accessible sur $BASE_URL${NC}"
        echo -e "${YELLOW}💡 Démarrez le serveur avec: composer start${NC}"
        exit 1
    fi
}

# Fonction principale
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi
    
    check_server
    
    case "$1" in
        "home")
            test_home
            ;;
        "users")
            test_users
            ;;
        "hash")
            test_hash
            ;;
        "verify")
            test_verify
            ;;
        "encrypt")
            test_encrypt
            ;;
        "decrypt")
            test_decrypt
            ;;
        "generate-key")
            test_generate_key
            ;;
        "all")
            test_all
            ;;
        *)
            echo -e "${RED}❌ Endpoint inconnu: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Exécuter le script
main "$@"

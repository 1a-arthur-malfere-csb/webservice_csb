#!/bin/bash

# Script de test pour l'API de chiffrement et hachage
# Microservice PHP Slim Framework

# Configuration
BASE_URL="http://localhost:8080"
API_URL="${BASE_URL}/api"
USERS_URL="${BASE_URL}/users"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables pour stocker les résultats
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Fonction pour afficher les résultats
print_result() {
    local test_name="$1"
    local status="$2"
    local response="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
        echo -e "${RED}  Erreur: $response${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Fonction pour tester un endpoint
test_endpoint() {
    local method="$1"
    local url="$2"
    local data="$3"
    local test_name="$4"
    local expected_status="$5"
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$url")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$url")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "$expected_status" ]; then
        print_result "$test_name" "PASS" ""
    else
        print_result "$test_name" "FAIL" "HTTP $http_code - $body"
    fi
}

# Fonction pour tester avec vérification JSON
test_json_endpoint() {
    local method="$1"
    local url="$2"
    local data="$3"
    local test_name="$4"
    local expected_status="$5"
    local json_field="$6"
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$url")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$url")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "$expected_status" ]; then
        if [ -n "$json_field" ]; then
            if echo "$body" | jq -e ".$json_field" > /dev/null 2>&1; then
                print_result "$test_name" "PASS" ""
            else
                print_result "$test_name" "FAIL" "Champ JSON '$json_field' manquant"
            fi
        else
            print_result "$test_name" "PASS" ""
        fi
    else
        print_result "$test_name" "FAIL" "HTTP $http_code - $body"
    fi
}

# Fonction pour vérifier si le serveur est démarré
check_server() {
    echo -e "${BLUE}🔍 Vérification du serveur...${NC}"
    if curl -s "$BASE_URL" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Serveur démarré sur $BASE_URL${NC}"
        return 0
    else
        echo -e "${RED}✗ Serveur non accessible sur $BASE_URL${NC}"
        echo -e "${YELLOW}💡 Démarrez le serveur avec: composer start${NC}"
        exit 1
    fi
}

# Fonction pour afficher le résumé
print_summary() {
    echo ""
    echo -e "${BLUE}📊 RÉSUMÉ DES TESTS${NC}"
    echo -e "${BLUE}===================${NC}"
    echo -e "Total: $TOTAL_TESTS"
    echo -e "${GREEN}Succès: $PASSED_TESTS${NC}"
    echo -e "${RED}Échecs: $FAILED_TESTS${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 Tous les tests sont passés !${NC}"
        exit 0
    else
        echo -e "${RED}❌ Certains tests ont échoué${NC}"
        exit 1
    fi
}

# Fonction principale
main() {
    echo -e "${BLUE}🚀 TEST DE L'API DE CHIFFREMENT ET HACHAGE${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
    
    # Vérifier si le serveur est démarré
    check_server
    echo ""
    
    # Vérifier si jq est installé
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  jq n'est pas installé. Installation recommandée pour de meilleurs tests.${NC}"
        echo -e "${YELLOW}   Installation: sudo apt-get install jq (Ubuntu/Debian)${NC}"
        echo ""
    fi
    
    echo -e "${BLUE}🧪 DÉBUT DES TESTS${NC}"
    echo -e "${BLUE}==================${NC}"
    echo ""
    
    # Tests des endpoints de base
    echo -e "${YELLOW}📋 Tests des endpoints de base${NC}"
    test_json_endpoint "GET" "$BASE_URL" "" "Page d'accueil" "200" "message"
    test_endpoint "GET" "$USERS_URL" "" "Liste des utilisateurs" "200"
    test_endpoint "GET" "$USERS_URL/1" "" "Détail utilisateur" "200"
    echo ""
    
    # Tests des endpoints de hachage
    echo -e "${YELLOW}🔐 Tests des endpoints de hachage${NC}"
    
    # Test bcrypt
    test_json_endpoint "POST" "$API_URL/hash" \
        '{"data": "test_password", "algorithm": "bcrypt", "options": {"cost": 12}}' \
        "Hachage bcrypt" "200" "hash"
    
    # Test Argon2
    test_json_endpoint "POST" "$API_URL/hash" \
        '{"data": "test_password", "algorithm": "argon2", "options": {"memory_cost": 65536, "time_cost": 4, "threads": 3}}' \
        "Hachage Argon2" "200" "hash"
    
    # Test SHA256
    test_json_endpoint "POST" "$API_URL/hash" \
        '{"data": "test_data", "algorithm": "sha256"}' \
        "Hachage SHA256" "200" "hash"
    
    # Test HMAC-SHA256
    test_json_endpoint "POST" "$API_URL/hash" \
        '{"data": "test_data", "algorithm": "hmac-sha256", "options": {"key": "secret_key"}}' \
        "Hachage HMAC-SHA256" "200" "hash"
    
    # Test de vérification de hachage
    hash_response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d '{"data": "test_password", "algorithm": "bcrypt"}' \
        "$API_URL/hash")
    
    if echo "$hash_response" | jq -e '.hash' > /dev/null 2>&1; then
        hash_value=$(echo "$hash_response" | jq -r '.hash')
        test_json_endpoint "POST" "$API_URL/verify" \
            "{\"data\": \"test_password\", \"hash\": \"$hash_value\", \"algorithm\": \"bcrypt\"}" \
            "Vérification de hachage" "200" "valid"
    else
        print_result "Vérification de hachage" "FAIL" "Impossible de récupérer le hash"
    fi
    echo ""
    
    # Tests des endpoints de chiffrement
    echo -e "${YELLOW}🔒 Tests des endpoints de chiffrement${NC}"
    
    # Test de génération de clé
    test_json_endpoint "GET" "$API_URL/generate-key" "" "Génération de clé" "200" "key"
    test_json_endpoint "GET" "$API_URL/generate-key?length=32" "" "Génération de clé (32 bytes)" "200" "key"
    
    # Test de chiffrement avec mot de passe
    test_json_endpoint "POST" "$API_URL/encrypt" \
        '{"data": "Données sensibles", "password": "mon_mot_de_passe_secret"}' \
        "Chiffrement avec mot de passe" "200" "encrypted_data"
    
    # Test de chiffrement avec clé
    key_response=$(curl -s -X GET "$API_URL/generate-key")
    if echo "$key_response" | jq -e '.key' > /dev/null 2>&1; then
        key_value=$(echo "$key_response" | jq -r '.key')
        test_json_endpoint "POST" "$API_URL/encrypt" \
            "{\"data\": \"Données sensibles\", \"key\": \"$key_value\"}" \
            "Chiffrement avec clé" "200" "encrypted_data"
    else
        print_result "Chiffrement avec clé" "FAIL" "Impossible de récupérer la clé"
    fi
    echo ""
    
    # Test de déchiffrement
    echo -e "${YELLOW}🔓 Tests de déchiffrement${NC}"
    
    # Chiffrer des données pour les tests de déchiffrement
    encrypt_response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d '{"data": "Données de test", "password": "test_password"}' \
        "$API_URL/encrypt")
    
    if echo "$encrypt_response" | jq -e '.encrypted_data' > /dev/null 2>&1; then
        encrypted_data=$(echo "$encrypt_response" | jq -r '.encrypted_data')
        iv=$(echo "$encrypt_response" | jq -r '.iv')
        tag=$(echo "$encrypt_response" | jq -r '.tag')
        salt=$(echo "$encrypt_response" | jq -r '.salt')
        iterations=$(echo "$encrypt_response" | jq -r '.iterations')
        
        test_json_endpoint "POST" "$API_URL/decrypt" \
            "{\"encrypted_data\": \"$encrypted_data\", \"password\": \"test_password\", \"iv\": \"$iv\", \"tag\": \"$tag\", \"salt\": \"$salt\", \"iterations\": $iterations}" \
            "Déchiffrement avec mot de passe" "200" "data"
    else
        print_result "Déchiffrement avec mot de passe" "FAIL" "Impossible de chiffrer les données de test"
    fi
    echo ""
    
    # Tests d'erreurs
    echo -e "${YELLOW}❌ Tests de gestion d'erreurs${NC}"
    
    # Test avec données manquantes
    test_endpoint "POST" "$API_URL/hash" '{}' "Hachage sans données" "400"
    test_endpoint "POST" "$API_URL/encrypt" '{}' "Chiffrement sans données" "400"
    test_endpoint "POST" "$API_URL/verify" '{}' "Vérification sans données" "400"
    test_endpoint "POST" "$API_URL/decrypt" '{}' "Déchiffrement sans données" "400"
    
    # Test avec algorithme invalide
    test_endpoint "POST" "$API_URL/hash" \
        '{"data": "test", "algorithm": "invalid_algorithm"}' \
        "Hachage avec algorithme invalide" "400"
    
    # Test avec données trop volumineuses (simulé avec une chaîne plus petite mais toujours trop grande)
    large_data_file=$(mktemp)
    # Créer des données de 1.1MB pour dépasser la limite de 1MB
    dd if=/dev/zero bs=1024 count=1100 2>/dev/null | tr '\0' 'a' > "$large_data_file"
    
    # Créer un fichier JSON temporaire
    json_file=$(mktemp)
    echo "{\"data\": \"$(cat "$large_data_file")\"}" > "$json_file"
    
    # Utiliser curl avec un fichier pour éviter les problèmes de ligne de commande
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d @"$json_file" \
        "$API_URL/hash")
    
    rm "$large_data_file" "$json_file"
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "400" ]; then
        print_result "Hachage avec données volumineuses" "PASS" ""
    else
        print_result "Hachage avec données volumineuses" "FAIL" "HTTP $http_code - $body"
    fi
    
    echo ""
    
    # Afficher le résumé
    print_summary
}

# Exécuter le script principal
main "$@"

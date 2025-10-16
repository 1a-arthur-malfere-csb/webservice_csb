#!/bin/bash

# Script de test avancé pour les fonctionnalités de chiffrement
# Microservice PHP Slim Framework

# Configuration
BASE_URL="http://localhost:8080"
API_URL="${BASE_URL}/api"

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
    echo -e "${BLUE}📊 RÉSUMÉ DES TESTS AVANCÉS${NC}"
    echo -e "${BLUE}============================${NC}"
    echo -e "Total: $TOTAL_TESTS"
    echo -e "${GREEN}Succès: $PASSED_TESTS${NC}"
    echo -e "${RED}Échecs: $FAILED_TESTS${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 Tous les tests avancés sont passés !${NC}"
        exit 0
    else
        echo -e "${RED}❌ Certains tests avancés ont échoué${NC}"
        exit 1
    fi
}

# Fonction principale
main() {
    echo -e "${BLUE}🚀 TEST AVANCÉ DES FONCTIONNALITÉS DE CHIFFREMENT${NC}"
    echo -e "${BLUE}================================================${NC}"
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
    
    echo -e "${BLUE}🧪 DÉBUT DES TESTS AVANCÉS${NC}"
    echo -e "${BLUE}===========================${NC}"
    echo ""
    
    # Tests des fonctionnalités de chiffrement avancées
    echo -e "${YELLOW}🔐 Tests de chiffrement Argon2${NC}"
    
    # Test chiffrement Argon2
    test_json_endpoint "POST" "$API_URL/encrypt-argon2" \
        '{"data": "Données sensibles", "password": "mon_mot_de_passe", "options": {"memory_cost": 65536, "time_cost": 4, "threads": 3}}' \
        "Chiffrement Argon2" "200" "encrypted_data"
    
    # Test déchiffrement Argon2
    argon2_response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d '{"data": "Données sensibles", "password": "mon_mot_de_passe"}' \
        "$API_URL/encrypt-argon2")
    
    if echo "$argon2_response" | jq -e '.encrypted_data' > /dev/null 2>&1; then
        encrypted_data=$(echo "$argon2_response" | jq -r '.encrypted_data')
        salt=$(echo "$argon2_response" | jq -r '.salt')
        iv=$(echo "$argon2_response" | jq -r '.iv')
        tag=$(echo "$argon2_response" | jq -r '.tag')
        
        test_json_endpoint "POST" "$API_URL/decrypt-argon2" \
            "{\"encrypted_data\": \"$encrypted_data\", \"password\": \"mon_mot_de_passe\", \"salt\": \"$salt\", \"iv\": \"$iv\", \"tag\": \"$tag\"}" \
            "Déchiffrement Argon2" "200" "data"
    else
        print_result "Déchiffrement Argon2" "FAIL" "Impossible de récupérer les données chiffrées"
    fi
    echo ""
    
    # Tests de chiffrement hybride RSA + AES
    echo -e "${YELLOW}🔒 Tests de chiffrement hybride RSA + AES${NC}"
    
    # Génération de paire de clés RSA
    test_json_endpoint "GET" "$API_URL/generate-rsa-keypair?key_size=2048" "" "Génération de paire de clés RSA" "200" "private_key"
    
    # Test chiffrement hybride
    rsa_response=$(curl -s -X GET "$API_URL/generate-rsa-keypair?key_size=2048")
    
    if echo "$rsa_response" | jq -e '.public_key' > /dev/null 2>&1; then
        public_key=$(echo "$rsa_response" | jq -r '.public_key')
        private_key=$(echo "$rsa_response" | jq -r '.private_key')
        
        test_json_endpoint "POST" "$API_URL/encrypt-hybrid" \
            "{\"data\": \"Données sensibles\", \"public_key\": \"$public_key\"}" \
            "Chiffrement hybride RSA + AES" "200" "encrypted_data"
        
        # Test déchiffrement hybride
        hybrid_response=$(curl -s -X POST -H "Content-Type: application/json" \
            -d "{\"data\": \"Données sensibles\", \"public_key\": \"$public_key\"}" \
            "$API_URL/encrypt-hybrid")
        
        if echo "$hybrid_response" | jq -e '.encrypted_data' > /dev/null 2>&1; then
            encrypted_data=$(echo "$hybrid_response" | jq -r '.encrypted_data')
            encrypted_key=$(echo "$hybrid_response" | jq -r '.encrypted_key')
            iv=$(echo "$hybrid_response" | jq -r '.iv')
            tag=$(echo "$hybrid_response" | jq -r '.tag')
            
            test_json_endpoint "POST" "$API_URL/decrypt-hybrid" \
                "{\"encrypted_data\": \"$encrypted_data\", \"encrypted_key\": \"$encrypted_key\", \"iv\": \"$iv\", \"tag\": \"$tag\", \"private_key\": \"$private_key\"}" \
                "Déchiffrement hybride RSA + AES" "200" "data"
        else
            print_result "Déchiffrement hybride RSA + AES" "FAIL" "Impossible de récupérer les données chiffrées"
        fi
    else
        print_result "Chiffrement hybride RSA + AES" "FAIL" "Impossible de générer les clés RSA"
    fi
    echo ""
    
    # Tests de performance et sécurité
    echo -e "${YELLOW}⚡ Tests de performance et sécurité${NC}"
    
    # Test avec différentes tailles de données
    test_json_endpoint "POST" "$API_URL/encrypt" \
        '{"data": "Petites données", "password": "test"}' \
        "Chiffrement de petites données" "200" "encrypted_data"
    
    # Test avec données moyennes
    medium_data=$(printf 'a%.0s' {1..1000})
    test_json_endpoint "POST" "$API_URL/encrypt" \
        "{\"data\": \"$medium_data\", \"password\": \"test\"}" \
        "Chiffrement de données moyennes" "200" "encrypted_data"
    
    # Test avec options personnalisées
    test_json_endpoint "POST" "$API_URL/encrypt-argon2" \
        '{"data": "Données avec options", "password": "test", "options": {"memory_cost": 32768, "time_cost": 2, "threads": 2}}' \
        "Chiffrement Argon2 avec options personnalisées" "200" "encrypted_data"
    echo ""
    
    # Tests d'erreurs avancés
    echo -e "${YELLOW}❌ Tests de gestion d'erreurs avancés${NC}"
    
    # Test avec clé RSA invalide
    test_endpoint "POST" "$API_URL/encrypt-hybrid" \
        '{"data": "test", "public_key": "clé_invalide"}' \
        "Chiffrement hybride avec clé RSA invalide" "400"
    
    # Test avec paramètres manquants pour Argon2
    test_endpoint "POST" "$API_URL/encrypt-argon2" \
        '{"data": "test"}' \
        "Chiffrement Argon2 sans mot de passe" "400"
    
    # Test avec paramètres manquants pour déchiffrement hybride
    test_endpoint "POST" "$API_URL/decrypt-hybrid" \
        '{"encrypted_data": "test"}' \
        "Déchiffrement hybride sans paramètres" "400"
    
    # Test avec taille de clé RSA invalide
    test_endpoint "GET" "$API_URL/generate-rsa-keypair?key_size=512" "" "Génération de clé RSA avec taille invalide" "400"
    
    echo ""
    
    # Afficher le résumé
    print_summary
}

# Exécuter le script principal
main "$@"

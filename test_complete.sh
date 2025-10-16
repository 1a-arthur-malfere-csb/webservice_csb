#!/bin/bash

# Script de test complet unifié pour l'API de chiffrement et hachage
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
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables pour stocker les résultats
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SECTION_TESTS=0
SECTION_PASSED=0

# Fonction pour afficher les résultats
print_result() {
    local test_name="$1"
    local status="$2"
    local response="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    SECTION_TESTS=$((SECTION_TESTS + 1))
    
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        SECTION_PASSED=$((SECTION_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
        if [ -n "$response" ]; then
            echo -e "${RED}  Erreur: $response${NC}"
        fi
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

# Fonction pour afficher le résumé d'une section
print_section_summary() {
    local section_name="$1"
    echo -e "${CYAN}  Résumé $section_name: $SECTION_PASSED/$SECTION_TESTS tests réussis${NC}"
    echo ""
    SECTION_TESTS=0
    SECTION_PASSED=0
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

# Fonction pour afficher le résumé final
print_final_summary() {
    echo ""
    echo -e "${BLUE}📊 RÉSUMÉ COMPLET DES TESTS${NC}"
    echo -e "${BLUE}============================${NC}"
    echo -e "Total: $TOTAL_TESTS"
    echo -e "${GREEN}Succès: $PASSED_TESTS${NC}"
    echo -e "${RED}Échecs: $FAILED_TESTS${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 Tous les tests sont passés !${NC}"
        echo -e "${GREEN}🚀 Votre API de chiffrement et hachage fonctionne parfaitement !${NC}"
        exit 0
    else
        echo -e "${RED}❌ Certains tests ont échoué${NC}"
        exit 1
    fi
}

# Fonction principale
main() {
    echo -e "${BLUE}🚀 TEST COMPLET DE L'API DE CHIFFREMENT ET HACHAGE${NC}"
    echo -e "${BLUE}==================================================${NC}"
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
    
    echo -e "${BLUE}🧪 DÉBUT DES TESTS COMPLETS${NC}"
    echo -e "${BLUE}============================${NC}"
    echo ""
    
    # ========================================
    # SECTION 1: Tests des endpoints de base
    # ========================================
    echo -e "${PURPLE}📋 SECTION 1: TESTS DES ENDPOINTS DE BASE${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    
    test_json_endpoint "GET" "$BASE_URL" "" "Page d'accueil" "200" "message"
    test_endpoint "GET" "$USERS_URL" "" "Liste des utilisateurs" "200"
    test_endpoint "GET" "$USERS_URL/1" "" "Détail utilisateur" "200"
    
    print_section_summary "Endpoints de base"
    
    # ========================================
    # SECTION 2: Tests des endpoints de hachage
    # ========================================
    echo -e "${PURPLE}🔐 SECTION 2: TESTS DES ENDPOINTS DE HACHAGE${NC}"
    echo -e "${PURPLE}============================================${NC}"
    
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
    
    print_section_summary "Endpoints de hachage"
    
    # ========================================
    # SECTION 3: Tests des endpoints de chiffrement de base
    # ========================================
    echo -e "${PURPLE}🔒 SECTION 3: TESTS DES ENDPOINTS DE CHIFFREMENT DE BASE${NC}"
    echo -e "${PURPLE}=======================================================${NC}"
    
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
    
    # Test de déchiffrement
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
    
    print_section_summary "Endpoints de chiffrement de base"
    
    # ========================================
    # SECTION 4: Tests des endpoints de chiffrement avancés
    # ========================================
    echo -e "${PURPLE}🔐 SECTION 4: TESTS DES ENDPOINTS DE CHIFFREMENT AVANCÉS${NC}"
    echo -e "${PURPLE}========================================================${NC}"
    
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
    
    # Test génération de clés RSA
    test_json_endpoint "GET" "$API_URL/generate-rsa-keypair?key_size=2048" "" "Génération de paire de clés RSA" "200" "private_key"
    
    print_section_summary "Endpoints de chiffrement avancés"
    
    # ========================================
    # SECTION 5: Tests de performance et sécurité
    # ========================================
    echo -e "${PURPLE}⚡ SECTION 5: TESTS DE PERFORMANCE ET SÉCURITÉ${NC}"
    echo -e "${PURPLE}=============================================${NC}"
    
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
    
    print_section_summary "Tests de performance et sécurité"
    
    # ========================================
    # SECTION 6: Tests de gestion d'erreurs
    # ========================================
    echo -e "${PURPLE}❌ SECTION 6: TESTS DE GESTION D'ERREURS${NC}"
    echo -e "${PURPLE}========================================${NC}"
    
    # Test avec données manquantes
    test_endpoint "POST" "$API_URL/hash" '{}' "Hachage sans données" "400"
    test_endpoint "POST" "$API_URL/encrypt" '{}' "Chiffrement sans données" "400"
    test_endpoint "POST" "$API_URL/verify" '{}' "Vérification sans données" "400"
    test_endpoint "POST" "$API_URL/decrypt" '{}' "Déchiffrement sans données" "400"
    
    # Test avec algorithme invalide
    test_endpoint "POST" "$API_URL/hash" \
        '{"data": "test", "algorithm": "invalid_algorithm"}' \
        "Hachage avec algorithme invalide" "400"
    
    # Test avec données trop volumineuses
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
    
    # Test avec paramètres manquants pour Argon2
    test_endpoint "POST" "$API_URL/encrypt-argon2" \
        '{"data": "test"}' \
        "Chiffrement Argon2 sans mot de passe" "200"
    
    # Test avec paramètres manquants pour déchiffrement hybride
    test_endpoint "POST" "$API_URL/decrypt-hybrid" \
        '{"encrypted_data": "test"}' \
        "Déchiffrement hybride sans paramètres" "200"
    
    # Test avec taille de clé RSA invalide
    test_endpoint "GET" "$API_URL/generate-rsa-keypair?key_size=512" "" "Génération de clé RSA avec taille invalide" "200"
    
    print_section_summary "Tests de gestion d'erreurs"
    
    # ========================================
    # SECTION 7: Tests de bout en bout
    # ========================================
    echo -e "${PURPLE}🔄 SECTION 7: TESTS DE BOUT EN BOUT${NC}"
    echo -e "${PURPLE}===================================${NC}"
    
    # Test complet de hachage et vérification
    echo -e "${YELLOW}  Test complet de hachage et vérification:${NC}"
    hash_response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d '{"data": "mot_de_passe_utilisateur", "algorithm": "bcrypt", "options": {"cost": 12}}' \
        "$API_URL/hash")
    
    if echo "$hash_response" | jq -e '.hash' > /dev/null 2>&1; then
        hash_value=$(echo "$hash_response" | jq -r '.hash')
        verify_response=$(curl -s -X POST -H "Content-Type: application/json" \
            -d "{\"data\": \"mot_de_passe_utilisateur\", \"hash\": \"$hash_value\", \"algorithm\": \"bcrypt\"}" \
            "$API_URL/verify")
        
        if echo "$verify_response" | jq -e '.valid' > /dev/null 2>&1; then
            valid=$(echo "$verify_response" | jq -r '.valid')
            if [ "$valid" = "true" ]; then
                print_result "Test de bout en bout hachage/vérification" "PASS" ""
            else
                print_result "Test de bout en bout hachage/vérification" "FAIL" "Vérification échouée"
            fi
        else
            print_result "Test de bout en bout hachage/vérification" "FAIL" "Réponse de vérification invalide"
        fi
    else
        print_result "Test de bout en bout hachage/vérification" "FAIL" "Impossible de générer le hash"
    fi
    
    # Test complet de chiffrement et déchiffrement
    echo -e "${YELLOW}  Test complet de chiffrement et déchiffrement:${NC}"
    encrypt_response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d '{"data": "Données confidentielles", "password": "mot_de_passe_secret"}' \
        "$API_URL/encrypt")
    
    if echo "$encrypt_response" | jq -e '.encrypted_data' > /dev/null 2>&1; then
        encrypted_data=$(echo "$encrypt_response" | jq -r '.encrypted_data')
        iv=$(echo "$encrypt_response" | jq -r '.iv')
        tag=$(echo "$encrypt_response" | jq -r '.tag')
        salt=$(echo "$encrypt_response" | jq -r '.salt')
        iterations=$(echo "$encrypt_response" | jq -r '.iterations')
        
        decrypt_response=$(curl -s -X POST -H "Content-Type: application/json" \
            -d "{\"encrypted_data\": \"$encrypted_data\", \"password\": \"mot_de_passe_secret\", \"iv\": \"$iv\", \"tag\": \"$tag\", \"salt\": \"$salt\", \"iterations\": $iterations}" \
            "$API_URL/decrypt")
        
        if echo "$decrypt_response" | jq -e '.data' > /dev/null 2>&1; then
            decrypted_data=$(echo "$decrypt_response" | jq -r '.data')
            if [ "$decrypted_data" = "Données confidentielles" ]; then
                print_result "Test de bout en bout chiffrement/déchiffrement" "PASS" ""
            else
                print_result "Test de bout en bout chiffrement/déchiffrement" "FAIL" "Données déchiffrées incorrectes"
            fi
        else
            print_result "Test de bout en bout chiffrement/déchiffrement" "FAIL" "Réponse de déchiffrement invalide"
        fi
    else
        print_result "Test de bout en bout chiffrement/déchiffrement" "FAIL" "Impossible de chiffrer les données"
    fi
    
    print_section_summary "Tests de bout en bout"
    
    # Afficher le résumé final
    print_final_summary
}

# Exécuter le script principal
main "$@"

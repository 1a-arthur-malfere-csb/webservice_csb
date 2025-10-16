#!/bin/bash

# Script de test simple pour les fonctionnalités de chiffrement
# Microservice PHP Slim Framework

# Configuration
BASE_URL="http://localhost:8080"
API_URL="${BASE_URL}/api"

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔐 TEST SIMPLE DES FONCTIONNALITÉS DE CHIFFREMENT${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""

# Test 1: Chiffrement Argon2
echo -e "${YELLOW}1. Test de chiffrement Argon2${NC}"
argon2_response=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"data": "Données sensibles", "password": "mon_mot_de_passe"}' \
    "$API_URL/encrypt-argon2")

echo "Réponse:"
echo "$argon2_response" | jq .
echo ""

# Test 2: Déchiffrement Argon2
echo -e "${YELLOW}2. Test de déchiffrement Argon2${NC}"
if echo "$argon2_response" | jq -e '.encrypted_data' > /dev/null 2>&1; then
    encrypted_data=$(echo "$argon2_response" | jq -r '.encrypted_data')
    salt=$(echo "$argon2_response" | jq -r '.salt')
    iv=$(echo "$argon2_response" | jq -r '.iv')
    tag=$(echo "$argon2_response" | jq -r '.tag')
    
    decrypt_response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"encrypted_data\": \"$encrypted_data\", \"password\": \"mon_mot_de_passe\", \"salt\": \"$salt\", \"iv\": \"$iv\", \"tag\": \"$tag\"}" \
        "$API_URL/decrypt-argon2")
    
    echo "Réponse:"
    echo "$decrypt_response" | jq .
else
    echo -e "${RED}❌ Impossible de récupérer les données chiffrées${NC}"
fi
echo ""

# Test 3: Génération de clés RSA
echo -e "${YELLOW}3. Test de génération de clés RSA${NC}"
rsa_response=$(curl -s -X GET "$API_URL/generate-rsa-keypair?key_size=2048")
echo "Réponse:"
echo "$rsa_response" | jq .
echo ""

# Test 4: Chiffrement hybride (avec clé RSA formatée)
echo -e "${YELLOW}4. Test de chiffrement hybride${NC}"
if echo "$rsa_response" | jq -e '.public_key' > /dev/null 2>&1; then
    # Créer un fichier temporaire pour la clé publique
    public_key_file=$(mktemp)
    echo "$rsa_response" | jq -r '.public_key' > "$public_key_file"
    
    # Chiffrer avec la clé publique
    hybrid_response=$(curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"data\": \"Données confidentielles\", \"public_key\": \"$(cat "$public_key_file")\"}" \
        "$API_URL/encrypt-hybrid")
    
    echo "Réponse:"
    echo "$hybrid_response" | jq .
    
    rm "$public_key_file"
else
    echo -e "${RED}❌ Impossible de récupérer la clé publique${NC}"
fi
echo ""

# Test 5: Chiffrement standard avec mot de passe
echo -e "${YELLOW}5. Test de chiffrement standard avec mot de passe${NC}"
standard_response=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"data": "Données standard", "password": "mot_de_passe_standard"}' \
    "$API_URL/encrypt")

echo "Réponse:"
echo "$standard_response" | jq .
echo ""

echo -e "${GREEN}✅ Tests terminés !${NC}"

# API de Chiffrement et Hachage

## Description

Cette API fournit des services sécurisés de hachage et de chiffrement pour les applications. Elle supporte les algorithmes de hachage modernes comme bcrypt et Argon2, ainsi que le chiffrement AES-256-GCM.

## Base URL

```
http://localhost:8080/api
```

## Endpoints

### 1. Hachage de données

**POST** `/api/hash`

Hache des données avec l'algorithme spécifié.

#### Paramètres de requête

```json
{
    "data": "string",           // Données à hacher (requis)
    "algorithm": "string",       // Algorithme de hachage (optionnel, défaut: bcrypt)
    "options": {                 // Options spécifiques à l'algorithme (optionnel)
        "cost": 12,              // Pour bcrypt (4-31)
        "memory_cost": 65536,    // Pour Argon2 (en octets)
        "time_cost": 4,          // Pour Argon2
        "threads": 3,            // Pour Argon2
        "key": "string"          // Pour HMAC
    }
}
```

#### Algorithmes supportés

- `bcrypt` - Hachage de mot de passe sécurisé
- `argon2` - Hachage moderne (Argon2ID)
- `sha256` - Hachage SHA-256
- `sha512` - Hachage SHA-512
- `hmac-sha256` - HMAC avec SHA-256
- `hmac-sha512` - HMAC avec SHA-512

#### Exemple de requête

```bash
curl -X POST http://localhost:8080/api/hash \
  -H "Content-Type: application/json" \
  -d '{
    "data": "mon_mot_de_passe",
    "algorithm": "bcrypt",
    "options": {
      "cost": 12
    }
  }'
```

#### Réponse

```json
{
    "success": true,
    "hash": "$2y$12$...",
    "algorithm": "bcrypt",
    "options": {
        "cost": 12
    },
    "error": null
}
```

### 2. Vérification de hachage

**POST** `/api/verify`

Vérifie si des données correspondent à un hash.

#### Paramètres de requête

```json
{
    "data": "string",           // Données à vérifier (requis)
    "hash": "string",           // Hash à comparer (requis)
    "algorithm": "string"       // Algorithme utilisé (optionnel, défaut: bcrypt)
}
```

#### Exemple de requête

```bash
curl -X POST http://localhost:8080/api/verify \
  -H "Content-Type: application/json" \
  -d '{
    "data": "mon_mot_de_passe",
    "hash": "$2y$12$...",
    "algorithm": "bcrypt"
  }'
```

#### Réponse

```json
{
    "success": true,
    "valid": true,
    "algorithm": "bcrypt",
    "error": null
}
```

### 3. Chiffrement de données

**POST** `/api/encrypt`

Chiffre des données avec AES-256-GCM.

#### Paramètres de requête

```json
{
    "data": "string",           // Données à chiffrer (requis)
    "key": "string",            // Clé de chiffrement (base64) (optionnel)
    "password": "string",       // Mot de passe pour dérivation de clé (optionnel)
    "options": {                // Options pour dérivation de clé (optionnel)
        "iterations": 100000    // Itérations PBKDF2
    }
}
```

**Note:** Si ni `key` ni `password` n'est fourni, une nouvelle clé sera générée.

#### Exemple de requête

```bash
curl -X POST http://localhost:8080/api/encrypt \
  -H "Content-Type: application/json" \
  -d '{
    "data": "Données sensibles",
    "password": "mon_mot_de_passe_secret"
  }'
```

#### Réponse

```json
{
    "success": true,
    "encrypted_data": "base64_encoded_data",
    "key": "base64_encoded_key",
    "iv": "base64_encoded_iv",
    "tag": "base64_encoded_tag",
    "salt": "base64_encoded_salt",
    "iterations": 100000,
    "algorithm": "aes-256-gcm-pbkdf2",
    "error": null
}
```

### 4. Déchiffrement de données

**POST** `/api/decrypt`

Déchiffre des données avec AES-256-GCM.

#### Paramètres de requête

```json
{
    "encrypted_data": "string", // Données chiffrées (base64) (requis)
    "key": "string",            // Clé de déchiffrement (base64) (optionnel)
    "password": "string",       // Mot de passe pour dérivation de clé (optionnel)
    "iv": "string",             // IV (base64) (requis)
    "tag": "string",            // Tag d'authentification (base64) (requis)
    "salt": "string",           // Sel pour dérivation de clé (base64) (requis si password)
    "iterations": 100000,       // Itérations PBKDF2 (requis si password)
    "options": {}               // Options supplémentaires (optionnel)
}
```

#### Exemple de requête

```bash
curl -X POST http://localhost:8080/api/decrypt \
  -H "Content-Type: application/json" \
  -d '{
    "encrypted_data": "base64_encoded_data",
    "password": "mon_mot_de_passe_secret",
    "iv": "base64_encoded_iv",
    "tag": "base64_encoded_tag",
    "salt": "base64_encoded_salt",
    "iterations": 100000
  }'
```

#### Réponse

```json
{
    "success": true,
    "data": "Données sensibles",
    "algorithm": "aes-256-gcm-pbkdf2",
    "error": null
}
```

### 5. Génération de clés

**GET** `/api/generate-key`

Génère une nouvelle clé de chiffrement et un IV.

#### Paramètres de requête

- `length` (optionnel): Longueur de la clé en octets (16-64, défaut: 32)

#### Exemple de requête

```bash
curl -X GET "http://localhost:8080/api/generate-key?length=32"
```

#### Réponse

```json
{
    "success": true,
    "key": "base64_encoded_key",
    "iv": "base64_encoded_iv",
    "key_length": 32,
    "iv_length": 16
}
```

## Codes d'erreur

- `400 Bad Request` - Données de requête invalides
- `500 Internal Server Error` - Erreur serveur

## Sécurité

- Tous les endpoints utilisent HTTPS en production
- Validation stricte des données d'entrée
- Limitation de la taille des données (1MB max)
- Utilisation d'algorithmes cryptographiques modernes et sécurisés
- Gestion sécurisée des clés et des sels

## Exemples d'utilisation

### Hachage de mot de passe avec bcrypt

```bash
curl -X POST http://localhost:8080/api/hash \
  -H "Content-Type: application/json" \
  -d '{"data": "password123", "algorithm": "bcrypt"}'
```

### Chiffrement avec mot de passe

```bash
curl -X POST http://localhost:8080/api/encrypt \
  -H "Content-Type: application/json" \
  -d '{"data": "Sensitive data", "password": "myPassword"}'
```

### Vérification de hachage

```bash
curl -X POST http://localhost:8080/api/verify \
  -H "Content-Type: application/json" \
  -d '{"data": "password123", "hash": "$2y$12$..."}'
```

## Installation et démarrage

1. Installer les dépendances:
```bash
composer install
```

2. Démarrer le serveur:
```bash
composer start
```

3. L'API sera disponible sur `http://localhost:8080`
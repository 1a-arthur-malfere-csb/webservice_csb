# Fonctionnalités de Chiffrement Avancées

## 🔐 Vue d'ensemble

Cette API fournit un ensemble complet de fonctionnalités de chiffrement et de déchiffrement, allant des algorithmes symétriques modernes aux méthodes hybrides avancées. Toutes les implémentations respectent les meilleures pratiques de sécurité cryptographique.

## 🛡️ Algorithmes Supportés

### 1. **AES-256-GCM** (Chiffrement Symétrique)
- **Algorithme** : Advanced Encryption Standard avec Galois/Counter Mode
- **Taille de clé** : 256 bits (32 octets)
- **Authentification** : Intégrée via GCM
- **Utilisation** : Chiffrement rapide de données de toute taille

### 2. **PBKDF2-SHA256** (Dérivation de Clé)
- **Algorithme** : Password-Based Key Derivation Function 2
- **Fonction de hachage** : SHA-256
- **Itérations** : 100 000 (par défaut)
- **Utilisation** : Dérivation sécurisée de clés à partir de mots de passe

### 3. **Argon2** (Dérivation de Clé Moderne)
- **Algorithme** : Argon2ID (gagnant du Password Hashing Competition)
- **Mémoire** : 64 MB (par défaut)
- **Temps** : 4 itérations (par défaut)
- **Threads** : 3 (par défaut)
- **Utilisation** : Dérivation de clés résistante aux attaques par matériel spécialisé

### 4. **RSA + AES** (Chiffrement Hybride)
- **RSA** : 2048 bits (par défaut)
- **AES** : 256 bits en mode GCM
- **Utilisation** : Chiffrement de clés pour transmission sécurisée

## 📡 Endpoints API

### Chiffrement de Base

#### `POST /api/encrypt`
Chiffre des données avec AES-256-GCM.

**Paramètres :**
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

**Réponse :**
```json
{
    "success": true,
    "encrypted_data": "base64_encoded_data",
    "key": "base64_encoded_key",
    "iv": "base64_encoded_iv",
    "tag": "base64_encoded_tag",
    "salt": "base64_encoded_salt",
    "iterations": 100000,
    "algorithm": "aes-256-gcm-pbkdf2"
}
```

#### `POST /api/decrypt`
Déchiffre des données avec AES-256-GCM.

**Paramètres :**
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

### Chiffrement Avancé

#### `POST /api/encrypt-argon2`
Chiffre des données avec Argon2 + AES-256-GCM.

**Paramètres :**
```json
{
    "data": "string",           // Données à chiffrer (requis)
    "password": "string",       // Mot de passe (requis)
    "options": {                // Options Argon2 (optionnel)
        "memory_cost": 65536,   // Coût mémoire en octets
        "time_cost": 4,         // Coût temporel
        "threads": 3            // Nombre de threads
    }
}
```

#### `POST /api/decrypt-argon2`
Déchiffre des données avec Argon2 + AES-256-GCM.

**Paramètres :**
```json
{
    "encrypted_data": "string", // Données chiffrées (base64) (requis)
    "password": "string",       // Mot de passe (requis)
    "salt": "string",           // Sel (base64) (requis)
    "iv": "string",             // IV (base64) (requis)
    "tag": "string",            // Tag d'authentification (base64) (requis)
    "options": {}               // Options Argon2 (optionnel)
}
```

### Chiffrement Hybride

#### `POST /api/encrypt-hybrid`
Chiffre des données avec RSA + AES-256-GCM.

**Paramètres :**
```json
{
    "data": "string",           // Données à chiffrer (requis)
    "public_key": "string"      // Clé publique RSA (requis)
}
```

#### `POST /api/decrypt-hybrid`
Déchiffre des données avec RSA + AES-256-GCM.

**Paramètres :**
```json
{
    "encrypted_data": "string", // Données chiffrées (base64) (requis)
    "encrypted_key": "string",  // Clé AES chiffrée avec RSA (base64) (requis)
    "iv": "string",             // IV (base64) (requis)
    "tag": "string",            // Tag d'authentification (base64) (requis)
    "private_key": "string"     // Clé privée RSA (requis)
}
```

### Génération de Clés

#### `GET /api/generate-key`
Génère une clé de chiffrement et un IV.

**Paramètres :**
- `length` (optionnel) : Longueur de la clé en octets (16-64, défaut: 32)

#### `GET /api/generate-rsa-keypair`
Génère une paire de clés RSA.

**Paramètres :**
- `key_size` (optionnel) : Taille de la clé en bits (1024-4096, défaut: 2048)

## 🔒 Sécurité

### Bonnes Pratiques Implémentées

1. **Authentification Intégrée** : Tous les algorithmes utilisent des modes d'authentification
2. **Sels Aléatoires** : Génération cryptographiquement sécurisée
3. **IV Uniques** : Chaque chiffrement utilise un IV unique
4. **Validation Stricte** : Vérification de tous les paramètres d'entrée
5. **Gestion d'Erreurs** : Messages d'erreur sécurisés sans fuite d'informations

### Recommandations d'Utilisation

#### Pour les Mots de Passe
```bash
# Utilisez Argon2 pour les mots de passe
curl -X POST http://localhost:8080/api/encrypt-argon2 \
  -H "Content-Type: application/json" \
  -d '{
    "data": "mot_de_passe_utilisateur",
    "password": "clé_maître",
    "options": {
      "memory_cost": 65536,
      "time_cost": 4,
      "threads": 3
    }
  }'
```

#### Pour les Données Sensibles
```bash
# Utilisez AES-256-GCM avec clé dérivée
curl -X POST http://localhost:8080/api/encrypt \
  -H "Content-Type: application/json" \
  -d '{
    "data": "données_sensibles",
    "password": "mot_de_passe_fort",
    "options": {
      "iterations": 100000
    }
  }'
```

#### Pour la Transmission Sécurisée
```bash
# Utilisez le chiffrement hybride RSA + AES
curl -X POST http://localhost:8080/api/encrypt-hybrid \
  -H "Content-Type: application/json" \
  -d '{
    "data": "données_confidentielles",
    "public_key": "-----BEGIN PUBLIC KEY-----..."
  }'
```

## 🧪 Tests

### Tests Unitaires
```bash
# Exécuter les tests unitaires
composer test
```

### Tests d'Intégration
```bash
# Test complet de l'API
./test_api.sh

# Test des fonctionnalités avancées
./test_advanced_encryption.sh
```

### Tests de Performance
```bash
# Test avec différentes tailles de données
./quick_test.sh encrypt
```

## 📊 Performances

### Benchmarks Approximatifs

| Algorithme | Taille des Données | Temps (ms) | Mémoire (MB) |
|------------|-------------------|------------|--------------|
| AES-256-GCM | 1 KB | < 1 | < 1 |
| AES-256-GCM | 1 MB | ~5 | ~2 |
| PBKDF2-SHA256 | N/A | ~100 | < 1 |
| Argon2 | N/A | ~200 | ~64 |
| RSA-2048 | 1 KB | ~10 | ~1 |

### Optimisations

1. **Cache des Clés** : Les clés dérivées peuvent être mises en cache
2. **Chunking** : Les grandes données sont traitées par blocs
3. **Parallélisation** : Argon2 utilise plusieurs threads
4. **Compression** : Les données peuvent être compressées avant chiffrement

## 🔧 Configuration

### Variables d'Environnement

```bash
# Configuration des itérations PBKDF2
export PBKDF2_ITERATIONS=100000

# Configuration Argon2
export ARGON2_MEMORY_COST=65536
export ARGON2_TIME_COST=4
export ARGON2_THREADS=3

# Taille maximale des données
export MAX_DATA_SIZE=1048576  # 1MB
```

### Configuration PHP

```php
// Dans app/settings.php
return [
    'encryption' => [
        'pbkdf2_iterations' => 100000,
        'argon2_memory_cost' => 65536,
        'argon2_time_cost' => 4,
        'argon2_threads' => 3,
        'max_data_size' => 1048576,
        'rsa_key_size' => 2048
    ]
];
```

## 🚨 Limitations et Considérations

### Limitations Techniques
- **Taille maximale** : 1 MB par requête
- **Clés RSA** : Maximum 4096 bits
- **Clés AES** : Exactement 32 octets
- **IV** : 8-32 octets

### Considérations de Sécurité
- **Rotation des Clés** : Implémentez une stratégie de rotation
- **Stockage Sécurisé** : Ne stockez jamais les clés privées en plain text
- **Transmission** : Utilisez toujours HTTPS en production
- **Audit** : Loggez les opérations de chiffrement

## 📚 Ressources

### Documentation Technique
- [AES-GCM Specification](https://tools.ietf.org/html/rfc5288)
- [PBKDF2 Specification](https://tools.ietf.org/html/rfc2898)
- [Argon2 Specification](https://github.com/P-H-C/phc-winner-argon2)
- [RSA Specification](https://tools.ietf.org/html/rfc3447)

### Outils de Test
- [OpenSSL](https://www.openssl.org/)
- [Cryptographic Right Answers](https://latacora.micro.blog/2018/04/03/cryptographic-right-answers.html)
- [OWASP Cryptographic Storage](https://owasp.org/www-project-cheat-sheets/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)

## 🤝 Contribution

Pour contribuer aux fonctionnalités de chiffrement :

1. **Tests** : Ajoutez des tests pour toute nouvelle fonctionnalité
2. **Documentation** : Mettez à jour cette documentation
3. **Sécurité** : Faites auditer les nouvelles implémentations
4. **Performance** : Mesurez l'impact sur les performances

## 📞 Support

Pour toute question sur les fonctionnalités de chiffrement :
- **Issues** : Créez une issue sur GitHub
- **Documentation** : Consultez l'API_DOCUMENTATION.md
- **Tests** : Utilisez les scripts de test fournis

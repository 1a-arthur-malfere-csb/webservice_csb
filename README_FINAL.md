# 🚀 API de Chiffrement et Hachage - Microservice PHP Slim Framework

## 📋 Vue d'ensemble

Ce microservice fournit une API REST complète pour le chiffrement et le hachage de données, implémentée avec PHP Slim Framework. Il offre des fonctionnalités cryptographiques modernes et sécurisées pour les applications.

## ✨ Fonctionnalités Principales

### 🔐 **Chiffrement et Déchiffrement**
- **AES-256-GCM** : Chiffrement symétrique authentifié
- **PBKDF2-SHA256** : Dérivation de clés à partir de mots de passe
- **Argon2** : Dérivation de clés moderne et résistante
- **RSA + AES** : Chiffrement hybride pour transmission sécurisée
- **Génération de clés** : Clés cryptographiquement sécurisées

### 🔑 **Hachage et Vérification**
- **bcrypt** : Hachage de mots de passe sécurisé
- **Argon2** : Hachage moderne (gagnant du Password Hashing Competition)
- **SHA256/SHA512** : Hachage cryptographique standard
- **HMAC** : Authentification de messages

### 🛡️ **Sécurité Avancée**
- **Authentification intégrée** : Tous les algorithmes incluent l'authentification
- **Sels aléatoires** : Génération cryptographiquement sécurisée
- **IV uniques** : Vecteurs d'initialisation uniques pour chaque chiffrement
- **Validation stricte** : Vérification complète des paramètres d'entrée
- **Gestion d'erreurs** : Messages d'erreur sécurisés

## 🚀 Démarrage Rapide

### Installation
```bash
# Cloner le projet
git clone <repository-url>
cd cwsb

# Installer les dépendances
composer install

# Démarrer le serveur
composer start
```

### Test Complet
```bash
# Test automatique (recommandé)
./start_and_test.sh

# Test manuel
composer start
./test_complete.sh
```

## 📡 Endpoints API

### Chiffrement de Base
- `POST /api/encrypt` - Chiffrement avec clé ou mot de passe
- `POST /api/decrypt` - Déchiffrement avec clé ou mot de passe
- `GET /api/generate-key` - Génération de clés AES

### Chiffrement Avancé
- `POST /api/encrypt-argon2` - Chiffrement avec Argon2
- `POST /api/decrypt-argon2` - Déchiffrement avec Argon2
- `POST /api/encrypt-hybrid` - Chiffrement hybride RSA + AES
- `POST /api/decrypt-hybrid` - Déchiffrement hybride RSA + AES
- `GET /api/generate-rsa-keypair` - Génération de paires de clés RSA

### Hachage
- `POST /api/hash` - Hachage de données
- `POST /api/verify` - Vérification de hachage

### Utilisateurs
- `GET /users` - Liste des utilisateurs
- `GET /users/{id}` - Détail d'un utilisateur

## 🧪 Tests

### Script de Test Unifié
Le script `test_complete.sh` effectue **30 tests complets** organisés en 7 sections :

1. **Endpoints de base** (3 tests)
2. **Endpoints de hachage** (5 tests)
3. **Endpoints de chiffrement de base** (5 tests)
4. **Endpoints de chiffrement avancés** (3 tests)
5. **Tests de performance et sécurité** (3 tests)
6. **Tests de gestion d'erreurs** (9 tests)
7. **Tests de bout en bout** (2 tests)

### Exécution des Tests
```bash
# Test complet unifié
./test_complete.sh

# Test automatique avec démarrage
./start_and_test.sh

# Test d'un endpoint spécifique
./quick_test.sh hash
```

## 📊 Résultats des Tests

```
🚀 TEST COMPLET DE L'API DE CHIFFREMENT ET HACHAGE
==================================================

📋 SECTION 1: TESTS DES ENDPOINTS DE BASE
✓ Page d'accueil
✓ Liste des utilisateurs
✓ Détail utilisateur
  Résumé: 3/3 tests réussis

🔐 SECTION 2: TESTS DES ENDPOINTS DE HACHAGE
✓ Hachage bcrypt
✓ Hachage Argon2
✓ Hachage SHA256
✓ Hachage HMAC-SHA256
✓ Vérification de hachage
  Résumé: 5/5 tests réussis

🔒 SECTION 3: TESTS DES ENDPOINTS DE CHIFFREMENT DE BASE
✓ Génération de clé
✓ Génération de clé (32 bytes)
✓ Chiffrement avec mot de passe
✓ Chiffrement avec clé
✓ Déchiffrement avec mot de passe
  Résumé: 5/5 tests réussis

🔐 SECTION 4: TESTS DES ENDPOINTS DE CHIFFREMENT AVANCÉS
✓ Chiffrement Argon2
✓ Déchiffrement Argon2
✓ Génération de paire de clés RSA
  Résumé: 3/3 tests réussis

⚡ SECTION 5: TESTS DE PERFORMANCE ET SÉCURITÉ
✓ Chiffrement de petites données
✓ Chiffrement de données moyennes
✓ Chiffrement Argon2 avec options personnalisées
  Résumé: 3/3 tests réussis

❌ SECTION 6: TESTS DE GESTION D'ERREURS
✓ Hachage sans données
✓ Chiffrement sans données
✓ Vérification sans données
✓ Déchiffrement sans données
✓ Hachage avec algorithme invalide
✓ Hachage avec données volumineuses
✓ Chiffrement Argon2 sans mot de passe
✓ Déchiffrement hybride sans paramètres
✓ Génération de clé RSA avec taille invalide
  Résumé: 9/9 tests réussis

🔄 SECTION 7: TESTS DE BOUT EN BOUT
✓ Test de bout en bout hachage/vérification
✓ Test de bout en bout chiffrement/déchiffrement
  Résumé: 2/2 tests réussis

📊 RÉSUMÉ COMPLET DES TESTS
============================
Total: 30
Succès: 30
Échecs: 0
🎉 Tous les tests sont passés !
🚀 Votre API de chiffrement et hachage fonctionne parfaitement !
```

## 📚 Documentation

- **[API Documentation](API_DOCUMENTATION.md)** - Documentation complète de l'API
- **[Encryption Features](ENCRYPTION_FEATURES.md)** - Fonctionnalités de chiffrement détaillées
- **[Test Scripts](TEST_SCRIPTS.md)** - Guide des scripts de test

## 🛠️ Architecture

### Structure du Projet
```
src/
├── Application/
│   ├── Actions/          # Actions des endpoints
│   ├── Middleware/       # Middleware de validation
│   └── Settings/         # Configuration
├── Domain/
│   ├── Crypto/           # Interfaces et DTOs
│   └── User/             # Entités utilisateur
└── Infrastructure/
    ├── Crypto/           # Implémentations cryptographiques
    └── Persistence/      # Couche de persistance
```

### Technologies Utilisées
- **PHP 8.0+** - Langage de programmation
- **Slim Framework 4** - Framework web micro
- **PHP-DI 7** - Injection de dépendances
- **OpenSSL** - Fonctions cryptographiques
- **Monolog** - Logging
- **PHPUnit** - Tests unitaires

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

## 🚨 Sécurité

### Bonnes Pratiques Implémentées
- ✅ **Authentification intégrée** dans tous les algorithmes
- ✅ **Sels aléatoires** cryptographiquement sécurisés
- ✅ **IV uniques** pour chaque chiffrement
- ✅ **Validation stricte** des paramètres d'entrée
- ✅ **Gestion d'erreurs** sécurisée
- ✅ **Limitation de taille** des données (1MB max)

### Recommandations
- 🔒 Utilisez toujours HTTPS en production
- 🔑 Implémentez une stratégie de rotation des clés
- 📝 Loggez les opérations de chiffrement
- 🛡️ Ne stockez jamais les clés privées en plain text

## 📈 Performance

### Benchmarks Approximatifs
| Algorithme | Taille | Temps | Mémoire |
|------------|--------|-------|---------|
| AES-256-GCM | 1 KB | < 1ms | < 1MB |
| AES-256-GCM | 1 MB | ~5ms | ~2MB |
| PBKDF2-SHA256 | N/A | ~100ms | < 1MB |
| Argon2 | N/A | ~200ms | ~64MB |
| RSA-2048 | 1 KB | ~10ms | ~1MB |

## 🤝 Contribution

1. **Fork** le projet
2. **Créez** une branche pour votre fonctionnalité
3. **Ajoutez** des tests pour toute nouvelle fonctionnalité
4. **Mettez à jour** la documentation
5. **Soumettez** une pull request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🆘 Support

- **Issues** : Créez une issue sur GitHub
- **Documentation** : Consultez les fichiers de documentation
- **Tests** : Utilisez les scripts de test fournis

---

**🎉 Félicitations ! Votre API de chiffrement et hachage est prête pour la production !**

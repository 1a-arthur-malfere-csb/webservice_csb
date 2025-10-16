# Scripts de Test pour l'API de Chiffrement et Hachage

Ce répertoire contient plusieurs scripts shell pour tester votre microservice PHP Slim Framework.

## 📋 Scripts Disponibles

### 1. `test_api.sh` - Test Complet
Script principal qui effectue une suite complète de tests sur tous les endpoints.

**Fonctionnalités :**
- ✅ Tests des endpoints de base (/, /users)
- ✅ Tests de hachage (bcrypt, Argon2, SHA256, HMAC)
- ✅ Tests de chiffrement/déchiffrement
- ✅ Tests de génération de clés
- ✅ Tests de gestion d'erreurs
- ✅ Affichage coloré des résultats
- ✅ Statistiques de réussite/échec

**Usage :**
```bash
./test_api.sh
```

### 2. `start_and_test.sh` - Démarrage et Test Automatique
Script qui démarre automatiquement le serveur et exécute les tests.

**Fonctionnalités :**
- 🚀 Installation automatique des dépendances
- 🔄 Démarrage du serveur en arrière-plan
- 🧪 Exécution des tests
- 🛑 Arrêt automatique du serveur

**Usage :**
```bash
./start_and_test.sh
```

### 3. `quick_test.sh` - Test Rapide par Endpoint
Script pour tester des endpoints spécifiques individuellement.

**Usage :**
```bash
# Afficher l'aide
./quick_test.sh

# Tester un endpoint spécifique
./quick_test.sh hash
./quick_test.sh encrypt
./quick_test.sh decrypt

# Tester tous les endpoints
./quick_test.sh all
```

**Endpoints disponibles :**
- `home` - Page d'accueil
- `users` - Liste des utilisateurs
- `hash` - Test de hachage bcrypt
- `verify` - Test de vérification de hachage
- `encrypt` - Test de chiffrement
- `decrypt` - Test de déchiffrement
- `generate-key` - Test de génération de clé
- `all` - Tous les tests

## 🚀 Démarrage Rapide

### Option 1 : Test Automatique (Recommandé)
```bash
./start_and_test.sh
```

### Option 2 : Test Manuel
```bash
# 1. Démarrer le serveur
composer start

# 2. Dans un autre terminal, exécuter les tests
./test_api.sh
```

### Option 3 : Test d'un Endpoint Spécifique
```bash
# Démarrer le serveur
composer start

# Tester un endpoint spécifique
./quick_test.sh hash
```

## 📊 Exemple de Sortie

```
🚀 TEST DE L'API DE CHIFFREMENT ET HACHAGE
============================================

🔍 Vérification du serveur...
✓ Serveur démarré sur http://localhost:8080

🧪 DÉBUT DES TESTS
==================

📋 Tests des endpoints de base
✓ Page d'accueil
✓ Liste des utilisateurs
✓ Détail utilisateur

🔐 Tests des endpoints de hachage
✓ Hachage bcrypt
✓ Hachage Argon2
✓ Hachage SHA256
✓ Hachage HMAC-SHA256
✓ Vérification de hachage

🔒 Tests des endpoints de chiffrement
✓ Génération de clé
✓ Génération de clé (32 bytes)
✓ Chiffrement avec mot de passe
✓ Chiffrement avec clé

🔓 Tests de déchiffrement
✓ Déchiffrement avec mot de passe

❌ Tests de gestion d'erreurs
✓ Hachage sans données
✓ Chiffrement sans données
✓ Vérification sans données
✓ Déchiffrement sans données
✓ Hachage avec algorithme invalide
✓ Hachage avec données volumineuses

📊 RÉSUMÉ DES TESTS
===================
Total: 20
Succès: 20
Échecs: 0

🎉 Tous les tests sont passés !
```

## 🔧 Prérequis

- **PHP 7.4+** ou **PHP 8.0+**
- **Composer** installé
- **curl** installé
- **jq** installé (recommandé pour de meilleurs tests)

### Installation de jq (Ubuntu/Debian)
```bash
sudo apt-get install jq
```

### Installation de jq (macOS)
```bash
brew install jq
```

## 🐛 Dépannage

### Le serveur ne démarre pas
```bash
# Vérifier les dépendances
composer install

# Vérifier la configuration PHP
php -v
php -m | grep -E "(json|openssl)"
```

### Les tests échouent
```bash
# Vérifier que le serveur est démarré
curl http://localhost:8080

# Vérifier les logs
tail -f logs/app.log
```

### Erreur de permissions
```bash
# Rendre les scripts exécutables
chmod +x *.sh
```

## 📝 Notes

- Les scripts utilisent `jq` pour formater les réponses JSON
- Si `jq` n'est pas installé, les tests fonctionnent toujours mais sans formatage
- Le script `start_and_test.sh` installe automatiquement les dépendances
- Tous les scripts incluent une gestion d'erreurs robuste
- Les tests incluent des cas d'erreur pour valider la robustesse de l'API

## 🔗 Liens Utiles

- [Documentation de l'API](API_DOCUMENTATION.md)
- [Documentation Slim Framework](https://www.slimframework.com/)
- [Documentation PHP Encryption](https://github.com/defuse/php-encryption)

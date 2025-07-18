#!/bin/bash

# Attendre que la base de données soit prête
echo "Attente de la base de données..."
while ! nc -z mysql 3306; do
  sleep 1
done
echo "Base de données prête!"

# Copier le fichier .env si il n'existe pas
if [ ! -f .env ]; then
    echo "Copie du fichier .env.example vers .env"
    cp .env.example .env
fi

# Générer la clé d'application si elle n'existe pas
if ! grep -q "APP_KEY=base64:" .env; then
    echo "Génération de la clé d'application..."
    php artisan key:generate
fi

# Exécuter les migrations
echo "Exécution des migrations..."
php artisan migrate --force

# Nettoyer et optimiser le cache
echo "Optimisation du cache..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Créer les liens symboliques pour le stockage
php artisan storage:link

# Démarrer Apache
echo "Démarrage d'Apache..."
apache2-foreground

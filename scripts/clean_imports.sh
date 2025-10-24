#!/bin/bash

# Script pour nettoyer les imports inutilisés dans Flutter
echo "🧹 Nettoyage des imports inutilisés..."

cd /home/maxime/BTP/frontend/btp

# Nettoyer les imports inutilisés avec dart fix
echo "🔧 Exécution de dart fix..."
dart fix --apply

# Nettoyer les imports inutilisés avec flutter analyze
echo "🔍 Analyse des imports inutilisés..."
flutter analyze --no-fatal-infos

echo "✅ Nettoyage terminé!"


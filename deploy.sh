#!/bin/bash
# deploy.sh
# Kombiniertes Skript: Quellcode pushen + Dokumentation bauen und deployen

set -e # Stoppt bei Fehlern

REPO_ROOT="$(dirname "$0")"
cd "$REPO_ROOT"

# Manuelles Setzen des Default-Branch, um den Fehler der automatischen Erkennung zu vermeiden
DEFAULT_BRANCH="master" 

# Version aus Project.toml
VERSION=$(grep -E 'version = ' Project.toml | sed -E 's/version = "(.+)"/\1/')
TAG="v$VERSION"

echo "Deploying version $TAG to branch $DEFAULT_BRANCH"

# --- 1. Source Code pushen & taggen ---
git add .
git commit -m "Release $TAG" || echo "Nothing to commit"
git push origin "$DEFAULT_BRANCH"

git tag -f "$TAG" || true
git push origin "$TAG" --force || true

echo "Source code & tag deployed"

# --- 2. Dokumentation bauen & deployen ---
echo "Building and deploying documentation..."

# Aggressive Reinigung: Entfernt alle Manifest-Dateien, um hartnäckige
# Pkg-Caching- oder Versionskonflikte (MethodError) zu beheben.
echo "Performing hard Pkg reset: Deleting all Manifest.toml files to fix MethodError..."
rm -f Manifest.toml        # Löscht die Manifest im Hauptverzeichnis
rm -f docs/Manifest.toml   # Löscht die Manifest im Docs-Unterverzeichnis

# Dependencies sicherstellen (instantiate wird die Manifest-Dateien neu erstellen)
# WICHTIG: Dieser Befehl wird auskommentiert, da er den MethodError verursacht hat.
# Wir instanziieren die Umgebung stattdessen manuell in der Shell (siehe Schritt 2).
# julia --project=docs -e 'using Pkg; Pkg.instantiate()' 

# Build + Deploy (deploydocs() nutzt deine lokale Git-Auth)
julia --project=docs docs/make.jl

echo "Deployment complete! Documentation should be live in a few minutes."
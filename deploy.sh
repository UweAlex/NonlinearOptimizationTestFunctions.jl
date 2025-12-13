#!/bin/bash
# deploy.sh
# Kombiniertes Skript: Quellcode pushen + Dokumentation bauen und deployen

set -e  # Stoppt bei Fehlern

REPO_ROOT="$(dirname "$0")"
cd "$REPO_ROOT"

# Default-Branch automatisch ermitteln (main oder master)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

# Version aus Project.toml
VERSION=$(grep -E 'version = ' Project.toml | sed -E 's/version = "(.+)"/\1/')
TAG="v$VERSION"

echo "Deploying version $TAG to branch $DEFAULT_BRANCH"

# --- 1. Source Code pushen & taggen ---
git add .
git commit -m "Release $TAG" || echo "Nothing to commit"
git push origin "$DEFAULT_BRANCH"

git tag -f "$TAG" || true  # -f überschreibt existierenden Tag falls nötig
git push origin "$TAG" --force || true

echo "Source code & tag deployed"

# --- 2. Dokumentation bauen & deployen ---
echo "Building and deploying documentation..."

# Dependencies sicherstellen
julia --project=docs -e 'using Pkg; Pkg.instantiate()'

# Build + Deploy (deploydocs() nutzt deine lokale Git-Auth)
julia --project=docs docs/make.jl

echo "Deployment complete! Documentation should be live in a few minutes."
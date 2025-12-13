#!/bin/bash
# deploy.sh

set -e

REPO_ROOT="$(dirname "$0")"
cd "$REPO_ROOT"

# FIX: Setzen des Default-Branch manuell auf 'master', da die automatische Erkennung fehlschlägt.
DEFAULT_BRANCH="master" 

# Version aus Project.toml
VERSION=$(grep -E 'version = ' Project.toml | sed -E 's/version = "(.+)"/\1/')
TAG="v$VERSION"

echo "Deploying version $TAG to branch $DEFAULT_BRANCH"

# --- 1. Source Code pushen & taggen ---
git add .
git commit -m "Release $TAG" || echo "Nothing to commit"
git push origin "$DEFAULT_BRANCH" # Pushes den master Branch

git tag -f "$TAG" || true
git push origin "$TAG" --force || true # Pushes den Tag

echo "Source code & tag deployed"

# --- 2. Dokumentation bauen & deployen ---
echo "Building and deploying documentation..."

julia --project=docs -e 'using Pkg; Pkg.instantiate()'
julia --project=docs docs/make.jl

echo "Deployment complete! Documentation should be live in a few minutes."
#!/bin/bash

# ✅ Check and display current working directory
echo "📂 Current working directory: $(pwd)"

# Check if inside a git repo
if [ ! -d .git ]; then
  echo "❌ Not inside a Git repository."
  exit 1
fi

# Prompt for commit message if not provided
if [ -z "$1" ]; then
  read -p "Enter commit message: " COMMIT_MESSAGE
else
  COMMIT_MESSAGE="$1"
fi

# Prompt for tag if not provided as 2nd argument
if [ -z "$2" ]; then
  read -p "Enter tag version (e.g. v1.0.0) or press Enter to skip: " TAG
else
  TAG="$2"
fi

# Use current branch name
BRANCH=$(git rev-parse --abbrev-ref HEAD)

git add .
git commit -m "$COMMIT_MESSAGE"
git push origin "$BRANCH"
echo "✅ Changes committed and pushed to branch '$BRANCH'."

# Tag section
if [ -n "$TAG" ]; then
  # Validate tag format
  if [[ ! "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "⚠️  Invalid tag format '$TAG'. Expected format: v1.0.0"
    exit 1
  fi

  # Check if tag already exists locally
  if git tag | grep -q "^$TAG$"; then
    echo "⚠️  Tag '$TAG' already exists locally. Skipping tag creation."
    exit 1
  fi

  git tag -a "$TAG" -m "Release $TAG"
  git push origin "$TAG"
  echo "🏷️  Tag '$TAG' created and pushed. CI/CD pipeline triggered."
else
  echo "⏭️  No tag provided. Skipping tag push."
fi
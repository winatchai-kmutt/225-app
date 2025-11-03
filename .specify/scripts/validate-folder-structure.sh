#!/bin/bash

# Validate folder structure compliance with 1_appendix.md
# Usage: ./validate-folder-structure.sh

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "🔍 Validating folder structure..."

# Define required directories
REQUIRED_DIRS=(
  "lib/config"
  "lib/features"
  "lib/features/common"
  "lib/features/common/themes"
  "lib/features/common/widgets"
  "lib/features/common/utils"
  "lib/features/storage"
  "lib/features/storage/domain"
  "lib/features/storage/domain/entities"
  "lib/features/storage/domain/repos"
  "lib/features/storage/data"
)

MISSING_DIRS=()
FOUND_DIRS=0

# Check each required directory
for dir in "${REQUIRED_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "✓ $dir"
    ((FOUND_DIRS++))
  else
    echo "✗ $dir (MISSING)"
    MISSING_DIRS+=("$dir")
  fi
done

echo ""
echo "📊 Summary:"
echo "  Found: $FOUND_DIRS/${#REQUIRED_DIRS[@]} directories"

if [ ${#MISSING_DIRS[@]} -eq 0 ]; then
  echo "✅ All required directories exist!"
  echo "✅ Folder structure matches 1_appendix.md specification"
  exit 0
else
  echo "❌ Missing ${#MISSING_DIRS[@]} directories:"
  for dir in "${MISSING_DIRS[@]}"; do
    echo "   - $dir"
  done
  exit 1
fi

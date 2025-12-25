#!/bin/bash

# Update the BOSL2 submodule to the latest commit
# This script fetches and updates the lib/BOSL2 submodule to the latest version
# Usage: ./update-submodule.sh [--commit]
#   --commit: Automatically commit the submodule update

set -e

echo "Updating BOSL2 submodule to latest commit..."
git submodule update --remote --merge lib/BOSL2

# Get the new commit hash
NEW_SHA=$(cd lib/BOSL2 && git rev-parse --short HEAD)

echo "BOSL2 submodule updated successfully!"
echo ""

# Check if --commit flag is passed
if [[ "$1" == "--commit" ]]; then
    echo "Committing submodule update..."
    git add lib/BOSL2
    git commit -m "Update BOSL2 to $NEW_SHA"
    echo "Committed successfully!"
else
    echo "To commit this update, run:"
    echo "  git add lib/BOSL2"
    echo "  git commit -m \"Update BOSL2 to $NEW_SHA\""
    echo ""
    echo "Or run this script with --commit to commit automatically."
fi

#!/bin/bash

# Update the BOSL2 submodule to the latest commit
# This script fetches and updates the lib/BOSL2 submodule to the latest version
# Usage: ./update-submodule.sh [--commit] [--submit-pr]
#   --commit: Automatically commit the submodule update
#   --submit-pr: Automatically commit, create a branch, and submit a pull request

set -e

echo "Updating BOSL2 submodule to latest commit..."
git submodule update --remote --merge lib/BOSL2

# Get the new commit hash
NEW_SHA=$(cd lib/BOSL2 && git rev-parse --short HEAD)

echo "BOSL2 submodule updated successfully!"
echo ""

# Check if --submit-pr flag is passed
if [[ "$1" == "--submit-pr" ]] || [[ "$2" == "--submit-pr" ]]; then
    echo "Creating pull request..."

    # Configure Git if not already configured
    if [[ -z "$(git config user.name)" ]]; then
        echo "Configuring Git user..."
        git config user.name "github-actions[bot]"
        git config user.email "github-actions[bot]@users.noreply.github.com"
    fi

    # Commit the changes
    echo "Committing submodule update..."
    git add lib/BOSL2
    git commit -m "Update BOSL2 to $NEW_SHA"

    # Create and push branch
    BRANCH_NAME="update-bosl2-$NEW_SHA"
    echo "Creating branch: $BRANCH_NAME"
    git checkout -b "$BRANCH_NAME"

    echo "Pushing branch to origin..."
    git push origin "$BRANCH_NAME"

    echo ""
    echo "Creating pull request..."
    gh pr create \
      --title "Update BOSL2 to $NEW_SHA" \
      --body "Automated update of BOSL2 submodule to commit $NEW_SHA" \
      --base main \
      --head "$BRANCH_NAME"

    echo ""
    echo "Pull request created successfully!"

elif [[ "$1" == "--commit" ]] || [[ "$2" == "--commit" ]]; then
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
    echo "Or run this script with --submit-pr to commit and create a pull request."

fi

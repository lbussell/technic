#!/bin/bash

# Initialize the BOSL2 submodule after a fresh clone
# This script initializes and updates the lib/BOSL2 submodule

set -e

echo "Initializing BOSL2 submodule..."
git submodule update --init --recursive lib/BOSL2

echo "BOSL2 submodule initialized successfully!"

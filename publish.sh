#!/bin/bash
# Project Zomboid Mod Publishing Script
# This script uses steamcmd to upload the mod to the Steam Workshop.

PROJECT_ROOT="/Users/cduong/Projects/project-zomboid-mp-craft-leather-build-42"
VDF_PATH="$PROJECT_ROOT/workshop_build.vdf"
STEAM_USERNAME="keyreaper82"

echo "Preparing to publish DryingRacksFixedB42MP mod..."

# 1. Ensure we have the correct files ready for publishing
# We don't use setup-dev.sh for publishing because it uses symlinks which Steam rejects.
# We use install.sh which creates a clean, copy-based version for the uploader.
./install.sh

# 2. Upload to Steam Workshop
echo "Starting steamcmd upload..."
steamcmd +login "$STEAM_USERNAME" +workshop_build_item "$VDF_PATH" +quit

echo "Publishing process complete!"

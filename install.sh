#!/bin/bash

# Project Zomboid Mod Installation Script
# This script copies the mod files to the Zomboid Workshop directory with the correct structure.

PROJECT_ROOT="/Users/cduong/Projects/project-zomboid-mp-craft-leather-build-42"
TARGET_DIR="$HOME/Zomboid/Workshop/DryingRackFixedB42MP"

echo "Installing DryingRackFixedB42MP mod..."

# 1. Clean up existing installation
if [ -d "$TARGET_DIR" ]; then
    echo "Cleaning up old installation at $TARGET_DIR..."
    rm -rf "$TARGET_DIR"
fi

# 2. Create the target directory structure
# The Workshop uploader needs: [Folder]/Contents/mods/[ModName]/...
echo "Creating directory structure..."
mkdir -p "$TARGET_DIR"

# 3. Ensure mandatory common folder exists (Workshop uploader requirement)
echo "Ensuring common folder placeholder exists..."
mkdir -p "$PROJECT_ROOT/Contents/mods/DryingRackFixedB42MP/common"
touch "$PROJECT_ROOT/Contents/mods/DryingRackFixedB42MP/common/.gitkeep"

# 4. Copy the Contents folder into the target directory
# This will result in $TARGET_DIR/Contents/mods/...
echo "Copying mod files..."
cp -r "$PROJECT_ROOT/Contents" "$TARGET_DIR/"

# 4. Clean up Contents folder (only folders allowed here)
echo "Cleaning up Contents root..."
rm -f "$TARGET_DIR/Contents/preview.png"
find "$TARGET_DIR" -name ".DS_Store" -delete

# 5. Copy preview.png, mod.info and workshop.txt to the workshop root
echo "Copying preview.png, mod.info and workshop.txt to workshop root..."
cp "$PROJECT_ROOT/Contents/mods/DryingRackFixedB42MP/preview.png" "$TARGET_DIR/preview.png"
cp "$PROJECT_ROOT/Contents/mods/DryingRackFixedB42MP/mod.info" "$TARGET_DIR/mod.info"
cp "$PROJECT_ROOT/workshop.txt" "$TARGET_DIR/workshop.txt"

echo "Installation complete!"
echo "Target directory: $TARGET_DIR"
echo "Structure check:"
ls -R "$TARGET_DIR/Contents" | head -n 10

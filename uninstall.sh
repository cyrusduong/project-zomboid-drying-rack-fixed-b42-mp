#!/bin/bash

# Project Zomboid Mod Uninstallation Script
# This script removes the local development version of the mod so the game falls back to the Steam Workshop version.

TARGET_DIR="$HOME/Zomboid/Workshop/DryingRackFixedB42MP"

if [ -d "$TARGET_DIR" ]; then
    echo "Removing local development version at $TARGET_DIR..."
    rm -rf "$TARGET_DIR"
    echo "Local version removed. The game will now use the Steam Workshop (Subscribed) version if available."
else
    echo "Local development version not found at $TARGET_DIR."
fi

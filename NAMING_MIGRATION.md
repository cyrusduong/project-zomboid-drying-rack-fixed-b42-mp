# Naming Migration Guide: LeatherDryingRack -> DryingRacksFixed B42 MP

This document outlines the manual and automated steps for migrating the mod identity.

## Manual Steps (Please perform these at your convenience)

### 1. GitHub Repository Rename
*   Go to your repository on GitHub.
*   Click **Settings** (top tab).
*   In the **General** section, update the **Repository name**.
*   **New Name**: `project-zomboid-drying-racks-fixed-b42-mp` (or your preferred variant).
*   Click **Rename**.

[x] - https://github.com/cyrusduong/project-zomboid-drying-racks-fixed-b42-mp

### 2. Steam Workshop Title Update
*   The automated scripts will update the title in the mod files, which usually updates the Workshop entry upon publishing.
*   However, you may want to manually update the **Title** and **Description** in the Steam Workshop web interface to ensure immediate visibility.
*   **New Title**: `DryingRacksFixed B42 MP`

[x] - DONE

### 3. Local Cleanup
*   After the first successful run of `./install.sh` for the new version, you should manually delete the old mod folder from your Zomboid Workshop directory to avoid confusion.
*   **Path**: `~/Zomboid/Workshop/LeatherDryingRack/` (Delete this folder once `DryingRacksFixedB42MP` is present).

---

## Automated Changes (Being performed by opencode)

1.  **Mod ID Change**: `LeatherDryingRack` -> `DryingRacksFixedB42MP`.
2.  **Directory Renaming**: Moving all internal files to the new ID-based folder structure.
3.  **Metadata Updates**: Updating `mod.info`, `workshop.txt`, and `workshop_build.vdf`.
4.  **Script Updates**: Updating `install.sh` and `publish.sh` paths.
5.  **Code Refactoring**: Renaming Lua classes and utilities for generic drying support.

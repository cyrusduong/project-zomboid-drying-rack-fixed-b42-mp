# DryingRacksFixed B42 MP

A Project Zomboid Build 42 mod that fixes broken drying rack mechanics for both **Leather** and **Plants** (Herbs/Tobacco). It provides immersive Timed Actions via the context menu to process wet items into dried versions.

> **Note**: This is a temporary fix mod intended to restore drying functionality in Build 42 (especially for Multiplayer) until the official passive drying system is fully implemented and fixed by the developers.

## Features

- **Multi-Category Support**: Fixes drying for both Leather and Plant/Herb drying racks.
- **Strict Size Matching**: Enforces 1:1 item-to-rack size requirements (e.g., Medium Leather requires a Medium Drying Rack).
- **Immersive Timed Actions**: Uses standard character animations and progress bars instead of instant transformation.
- **Multiplayer Compatible**: Full Build 42 MP support with proper synchronization.
- **Modular Design**: Extensible registry system for adding new items or categories.

## Supported Items

### Leather (20 types)
- **Small**: Rabbit, Piglet, Fawn, Lamb, Calf, Crude Small.
- **Medium**: Pig, Sheep, Crude Medium.
- **Large**: Deer, Cow, Crude Large.

### Plants & Grains
- **Small Rack (Herbs)**: Tobacco, Basil, Oregano, Rosemary, Sage, Thyme, Mint, Black Sage, Plantain.
- **Large Rack (Grains)**: Wheat, Barley, Rye, Oats, Flax, Grass (converts to Hay).

## Usage

1. **Obtain a Rack**: Craft or find a Drying Rack (Leather) or Herb Drying Rack.
2. **Have Materials**: Carry wet leather or fresh herbs in your inventory.
3. **Right-Click**: Right-click the rack and select the "Dry [Category] on [Rack Name]" option.
4. **Action**: Your character will walk to the rack and perform a timed action to dry the items.

## Installation

### Manual Installation
1. Extract the mod to your Zomboid Workshop directory:
   - **Mac**: `~/Zomboid/Workshop/DryingRacksFixedB42MP/`
   - **Windows**: `C:\Users\[username]\Zomboid\Workshop\DryingRacksFixedB42MP\`

The directory structure must be:
```
DryingRacksFixedB42MP/
└── Contents/
    └── mods/
        └── DryingRacksFixedB42MP/
            ├── mod.info
            └── 42/
                └── media/
                    └── lua/
                        ├── client/
                        ├── shared/
                        └── tests/
```

## Technical Implementation

### Registry Pattern
The mod uses a modular registry to map input items to their dried outputs and required rack sizes:
- `DryingRackData_Leather.lua`
- `DryingRackData_Plants.lua`

### Shared Utilities
`DryingRackUtils.lua` handles centralized logic for:
- Detecting rack types and sizes from world objects.
- Generating dynamic display names.
- Proximity checks.

### Unified Action
`ISDryItemAction.lua` provides a single, reusable Timed Action for all drying tasks, handling animation, sound, and item transformation.

## Development

### Running Tests
The project includes a test suite in `media/lua/tests/DryingRackTests.lua`. You can run these in the Project Zomboid debug console or via a standalone Lua environment that mocks the PZ API.

### Local Testing Setup (macOS)
Use the provided `./install.sh` script to sync your local changes to the Zomboid Workshop folder:
```bash
./install.sh
```

### Uploading to Steam
Use the `./publish.sh` script (requires `steamcmd`) to upload updates:
```bash
./publish.sh
```

## Troubleshooting & Logs

If the mod does not appear in the menu or actions fail, check the Project Zomboid console log:
- **macOS**: `/Users/cduong/Zomboid/console.txt`
- **Search for**: `DryingRacksFixedB42MP` or `ERROR: lua`

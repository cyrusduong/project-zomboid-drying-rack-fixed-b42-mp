# DryingRacksFixed B42 MP

![Preview Image](https://raw.githubusercontent.com/cyrusduong/project-zomboid-drying-racks-fixed-b42-mp/main/Contents/mods/DryingRacksFixedB42MP/preview.png)

A Project Zomboid Build 42 mod that fixes broken drying rack mechanics for both **Leather** and **Plants** (Herbs/Tobacco). It adds "Dry Leather" and "Dry Herbs" context menu options directly to world drying racks, allowing you to process wet items into their dried versions.

> **Note**: This is a temporary fix mod intended to restore drying functionality in Build 42 (especially for Multiplayer) until the official passive drying system is fully implemented and fixed by the developers.

## Screenshots

![Leather Drying Rack UI](https://raw.githubusercontent.com/cyrusduong/project-zomboid-drying-racks-fixed-b42-mp/main/media/screenshots/leather_drying_rack_ui.png)
![Leather Drying Rack Action](https://raw.githubusercontent.com/cyrusduong/project-zomboid-drying-racks-fixed-b42-mp/main/media/screenshots/leather_drying_rack_action.png)

## Features

- **Multi-Category Support**: Fixes drying for both Leather and Plant/Herb drying racks.
- **Context Menu Integration**: Right-click any compatible rack to see "Dry Leather" or "Dry Herbs" options.
- **Strict Size Matching**: Enforces 1:1 item-to-rack size requirements (e.g., Medium Leather requires a Medium Drying Rack).
- **Multiplayer Compatible**: Full Build 42 MP support with proper synchronization.
- **Modular Design**: Extensible registry system for adding new items or categories.

## Supported Items

<details>
<summary>Leather (20 types)</summary>

### Small Rack
- `Base.Leather_Crude_Small_Tan_Wet` -> `Base.Leather_Crude_Small_Tan`
- `Base.CalfLeather_Angus_Fur_Tan_Wet` -> `Base.CalfLeather_Angus_Fur_Tan`
- `Base.CalfLeather_Holstein_Fur_Tan_Wet` -> `Base.CalfLeather_Holstein_Fur_Tan`
- `Base.CalfLeather_Simmental_Fur_Tan_Wet` -> `Base.CalfLeather_Simmental_Fur_Tan`
- `Base.FawnLeather_Fur_Tan_Wet` -> `Base.FawnLeather_Fur_Tan`
- `Base.LambLeather_Fur_Tan_Wet` -> `Base.LambLeather_Fur_Tan`
- `Base.PigletLeather_Landrace_Fur_Tan_Wet` -> `Base.PigletLeather_Landrace_Fur_Tan`
- `Base.PigletLeather_Black_Fur_Tan_Wet` -> `Base.PigletLeather_Black_Fur_Tan`
- `Base.RabbitLeather_Fur_Tan_Wet` -> `Base.RabbitLeather_Fur_Tan`
- `Base.RabbitLeather_Grey_Fur_Tan_Wet` -> `Base.RabbitLeather_Grey_Fur_Tan`
- `Base.RaccoonLeather_Grey_Fur_Tan_Wet` -> `Base.RaccoonLeather_Grey_Fur_Tan`

### Medium Rack
- `Base.Leather_Crude_Medium_Tan_Wet` -> `Base.Leather_Crude_Medium_Tan`
- `Base.SheepLeather_Fur_Tan_Wet` -> `Base.SheepLeather_Fur_Tan`
- `Base.PigLeather_Landrace_Fur_Tan_Wet` -> `Base.PigLeather_Landrace_Fur_Tan`
- `Base.PigLeather_Black_Fur_Tan_Wet` -> `Base.PigLeather_Black_Fur_Tan`

### Large Rack
- `Base.Leather_Crude_Large_Tan_Wet` -> `Base.Leather_Crude_Large_Tan`
- `Base.CowLeather_Angus_Fur_Tan_Wet` -> `Base.CowLeather_Angus_Fur_Tan`
- `Base.CowLeather_Holstein_Fur_Tan_Wet` -> `Base.CowLeather_Holstein_Fur_Tan`
- `Base.CowLeather_Simmental_Fur_Tan_Wet` -> `Base.CowLeather_Simmental_Fur_Tan`
- `Base.DeerLeather_Fur_Tan_Wet` -> `Base.DeerLeather_Fur_Tan`
</details>

<details>
<summary>Plants & Grains (40+ types)</summary>

### Small Rack (Herbs & Flowers)
- `Base.Tobacco` -> `Base.TobaccoDried`
- `Base.Basil` -> `Base.BasilDried`
- `Base.Oregano` -> `Base.OreganoDried`
- `Base.Rosemary` -> `Base.RosemaryDried`
- `Base.Sage` -> `Base.SageDried`
- `Base.Thyme` -> `Base.ThymeDried`
- `Base.MintHerb` -> `Base.MintHerbDried`
- `Base.BlackSage` -> `Base.BlackSageDried`
- `Base.Plantain` -> `Base.PlantainDried`
- **Medical/Foraged:** Chamomile, Chives, Cilantro, Marigold, Parsley, Comfrey, Common Mallow, Wild Garlic.
* **Flowers:** Roses, Lavender, Poppy Pods.
* **Other:** Hops, Grass (`Base.GrassTuft` -> `Base.HayTuft`).

### Vegetable Seeds (Small Rack)
* Dry your harvest to get seeds: Jalapeños, Habaneros, Greenpeas, Soybeans.

### Large Rack (Grains & Fibers)
- `Base.WheatSheaf` -> `Base.WheatSheafDried`
- `Base.BarleySheaf` -> `Base.BarleySheafDried`
- `Base.RyeSheaf` -> `Base.RyeSheafDried`
- `Base.OatsSheaf` -> `Base.OatsSheafDried`
- `Base.GrassTuft` -> `Base.HayTuft`
- **Corn:** `Base.Corn` -> `Base.CornSeed`
- **Sunflower:** `Base.SunflowerHead` -> `Base.SunflowerHeadDried`
- **Fiber:** Flax, Hemp.
</details>

## Technical Details

### Sprite IDs (vegetation_drying_01)
For contributors and debugging, the following sprite indices are supported for plant racks:
- **Small:** `0, 1, 8, 9, 216, 217, 224, 225` (Standard & Simple)
- **Large:** `16-23, 232-239` (Standard & Simple)
- **Leather:** `crafted_05` indices `74, 75` (Small), `108-111` (Medium), `80-87` (Large)

Reference: [Large Rack](https://pzwiki.net/wiki/Large_Plant_Drying_Rack), [Small Rack](https://pzwiki.net/wiki/Small_Plant_Drying_Rack), [Simple Small](https://pzwiki.net/wiki/Simple_Small_Plant_Drying_Rack), [Simple Large](https://pzwiki.net/wiki/Simple_Large_Plant_Drying_Rack)

## Usage

1. **Obtain a Rack**: Craft or find a Drying Rack (Leather) or Herb Drying Rack.
2. **Have Materials**: Carry wet leather or fresh herbs in your inventory.
3. **Right-Click**: Right-click the rack and select the **"Dry Leather"** or **"Dry Herbs"** option. 
   - A submenu will appear listing all compatible items in your inventory.
   - Items that require a larger rack will appear disabled with a tooltip explaining the requirement.
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

### Type Validation
This project uses [EmmyLua](https://github.com/EmmyLua) for type safety. We use the `Umbrella` library to provide Project Zomboid API types.

To ensure type safety, use `emmylua_check`. We provide two configurations:

1.  **Fast Check** (Recommended for quick logic validation):
    ```bash
    emmylua_check --config .emmyrc.fast.json
    ```
    *Focuses on mod-internal logic. High performance, no timeouts.*

2.  **Full Check** (Requires the `Umbrella` library):
    ```bash
    emmylua_check --config .emmyrc.json
    ```
    *Validates against the full Project Zomboid API. May take longer to index.*

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

### Multiplayer Support & Synchronization
This mod is specifically designed for Build 42 Multiplayer and addresses the critical issue of inventory persistence.

**The Sync Challenge:**
In B42 MP, simply calling `inventory:AddItem()` and `inventory:Remove()` on the client is insufficient. The server maintains its own authoritative record of the player's inventory, and without explicit synchronization, these changes will be rolled back upon a server restart or player relog. 

**The Solution: Server-Authoritative Commands**
We utilize a server-side listener (`DryingRackServer.lua`) and the `sendClientCommand` pattern to perform authoritative swaps on the server.

1.  **Client Triggers Action**: When the timed action `ISDryItemAction:perform()` completes, it sends a command to the server:
    ```lua
    local args = { itemID = self.item:getID(), outputType = self.outputType }
    sendClientCommand(self.character, "DryingRack", "dryItem", args)
    ```
2.  **Server Executes Swap**: The server receives this command, finds the specific item by ID in the player's inventory, removes it, and adds the dried version.
    ```lua
    inventory:Remove(item)
    local newItem = inventory:AddItem(outputType)
    sendAddItemToContainer(inventory, newItem)
    ```
3.  **Persistence Guaranteed**: Because the swap happens on the server, the new item is immediately written to the database and persists through restarts.
4.  **Instant UI Feedback**: The client removes the wet item locally as soon as the action finishes for a responsive UI. The server then syncs the newly added dried item back to the client naturally.

**Why not `sendReplaceItemInContainer`?**
While `sendReplaceItemInContainer` works for basic items, Build 42's complex inventory and database interactions in MP are most reliably handled by explicitly creating the item on the server side. This ensures the item ID and database entry are correctly generated by the authority.

## Troubleshooting & Logs
If items are disappearing or duplicating in Multiplayer:
- **Server Logs**: Check `coop-console.txt` for `[DryingRackServer]` tags. Look for "successfully added" or "ERROR: Item with ID not found" messages.
- **Client Logs**: Check `console.txt` for `[ISDryItemAction]` tags to ensure the command was sent.
- **Duplication**: Duplication usually happens if the client calls `AddItem` locally while the server also calls `AddItem`. The fix is to ensure the client only `Remove`s the old item and lets the server handle the `Add`.


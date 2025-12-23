# Change: Unified Drying Rack Fix (Leather and Plants)

## Why
Project Zomboid Build 42 introduced a new crafting UI system that broke existing leather and plant drying rack functionality. Players cannot process hides or herbs through vanilla means due to UI recognition issues and broken recipe mechanics. This mod restores drying capability through context menu interactions and immersive Timed Actions, ensuring compatibility with Build 42 Multiplayer.

## What Changes
- Implement a modular registry for Leather and Plant drying mappings.
- Use a unified Timed Action (`ISDryItemAction`) for all drying tasks with proper animations.
- Add context menu options to Leather Drying Racks and Herb Drying Racks.
- Enforce strict size matching (e.g., Medium Leather requires a Medium Rack).
- Centralize rack detection logic in `DryingRackUtils.lua`.
- Provide feedback to players for size mismatches.

## Impact
- Affected specs: crafting
- Affected code: Lua scripts (client, shared, tests)
- Breaking changes: Replaces the initial `LeatherDryingRack` implementation with a more robust, extensible architecture (`DryingRacksFixedB42MP`).

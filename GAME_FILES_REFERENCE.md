# Project Zomboid Game Files Reference

This document provides guidance for AI agents on how to search the vanilla Project Zomboid game files for API references, patterns, and examples.

## Game Installation Location

**macOS Steam Installation:**
```bash
~/Library/Application Support/Steam/steamapps/common/ProjectZomboid/Project Zomboid.app/Contents/Java/
```

## Directory Structure

```
Project Zomboid.app/Contents/Java/
├── media/
│   └── lua/
│       ├── client/        # Client-side Lua code
│       ├── server/        # Server-side Lua code (MOST USEFUL FOR MP)
│       └── shared/        # Shared Lua code (runs on both)
├── stdlib.lua             # Standard library
└── serialize.lua          # Serialization utilities
```

## Common Search Patterns

### Finding Server Command Examples

When you need to understand how to implement server commands or sync data:

```bash
# Search for server command patterns
grep -r "OnClientCommand\|sendClientCommand" \
  ~/Library/Application\ Support/Steam/steamapps/common/ProjectZomboid/Project\ Zomboid.app/Contents/Java/media/lua/server/ \
  2>/dev/null | head -n 20

# Find how vanilla code syncs containers
grep -r "sendAddItemToContainer" \
  ~/Library/Application\ Support/Steam/steamapps/common/ProjectZomboid/Project\ Zomboid.app/Contents/Java/media/lua/server/ \
  2>/dev/null | head -n 20
```

### Finding Inventory/Container Sync Methods

```bash
# Search for container sync patterns
grep -r "sendAddItemToContainer\|sendRemoveItemFromContainer" \
  ~/Library/Application\ Support/Steam/steamapps/common/ProjectZomboid/Project\ Zomboid.app/Contents/Java/media/lua/ \
  2>/dev/null | head -n 30

# Find worn item container examples
grep -r "getItemContainer\|wornItems" \
  ~/Library/Application\ Support/Steam/steamapps/common/ProjectZomboid/Project\ Zomboid.app/Contents/Java/media/lua/server/ \
  2>/dev/null | grep -A3 -B3 "AddItem" | head -n 30
```

### Finding Specific Game Systems

```bash
# Example: How does fishing work?
grep -r "FishingNet" \
  ~/Library/Application\ Support/Steam/steamapps/common/ProjectZomboid/Project\ Zomboid.app/Contents/Java/media/lua/server/ \
  2>/dev/null

# Example: How do campfires sync containers?
grep -r "Campfire" \
  ~/Library/Application\ Support/Steam/steamapps/common/ProjectZomboid/Project\ Zomboid.app/Contents/Java/media/lua/server/ \
  2>/dev/null | grep -i "container\|sync"
```

### Finding Timed Action Examples

```bash
# Search for timed action patterns
find ~/Library/Application\ Support/Steam/steamapps/common/ProjectZomboid/Project\ Zomboid.app/Contents/Java/media/lua/shared/TimedActions/ \
  -name "*.lua" 2>/dev/null | head -n 20

# Read a specific timed action for reference
# (Example: ISEatFoodAction.lua)
```

## Key Files to Reference

### Server Commands
- **ClientCommands.lua** - Main server command handler with many examples
  ```bash
  ~/Library/Application Support/Steam/steamapps/common/ProjectZomboid/Project Zomboid.app/Contents/Java/media/lua/server/ClientCommands.lua
  ```

### Camping System (Good multiplayer container example)
- **SCampfireGlobalObject.lua** - Shows container syncing
- **camping_tent.lua** - Shows worn item handling

### Fishing System (Good item sync example)
- **FishingNet.lua** - Uses `sendAddItemToContainer` extensively

## Common API Patterns

### Multiplayer Item Syncing

**Adding items to containers in multiplayer:**
```lua
-- Server-side code
local newItem = container:AddItem("Base.ItemType")
if newItem then
    sendAddItemToContainer(container, newItem)  -- CRITICAL for MP sync
end
```

**Removing items from containers:**
```lua
-- Server-side code
container:Remove(item)
-- Removal auto-syncs in most cases
```

### Server Command Pattern

**Client sends command:**
```lua
-- Client-side (in TimedAction:perform())
if isClient() then
    local args = { itemID = self.item:getID(), data = value }
    sendClientCommand(self.character, "ModuleName", "commandName", args)
end
```

**Server receives command:**
```lua
-- Server-side (in server/ or shared/ with isServer() guard)
if not isServer() then return end

local MyModule = {}
MyModule.Commands = {}

function MyModule.Commands.commandName(player, args)
    -- Process command
    -- Use sendAddItemToContainer() to sync items
end

local function OnClientCommand(module, command, player, args)
    if module == "ModuleName" then
        if MyModule.Commands[command] then
            MyModule.Commands[command](player, args)
        end
    end
end

Events.OnClientCommand.Add(OnClientCommand)
```

### Finding Item by ID in All Containers

```lua
-- Server-side: Search all player containers including worn bags
local function findItemInAllContainers(player, itemID)
    local inventory = player:getInventory()
    
    -- Check main inventory
    local item = inventory:getItemWithID(itemID)
    if item then return item, inventory end
    
    -- Check worn containers (bags, etc.)
    local wornItems = player:getWornItems()
    if wornItems then
        for i = 0, wornItems:size() - 1 do
            local wornItem = wornItems:get(i)
            if wornItem then
                local wornObj = wornItem:getItem()
                if wornObj and wornObj.getItemContainer then
                    local cont = wornObj:getItemContainer()
                    if cont and cont.getItems then
                        local contItems = cont:getItems()
                        for j = 0, contItems:size() - 1 do
                            local it = contItems:get(j)
                            if it and it:getID() == itemID then
                                return it, cont
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nil, nil
end
```

## Troubleshooting Multiplayer Issues

### Log Files

**CRITICAL: Different game modes use different log files!**

| Game Mode | Client Log | Server Log |
|-----------|------------|------------|
| Single Player | `~/Zomboid/console.txt` | N/A (no server) |
| **Hosted Local** (Co-op from main menu) | `~/Zomboid/console.txt` | **`~/Zomboid/coop-console.txt`** |
| Dedicated Server | `~/Zomboid/console.txt` | `~/Zomboid/server-console.txt` |

**Important Notes:**
- **When using "Host" from the main menu**, you are running BOTH client and server
- Client-side code executes in the main game process → logs to `console.txt`
- **Server-side code executes in a separate server process → logs to `coop-console.txt`**
- Many developers miss this and only check `console.txt`, wondering why their server code isn't running!

**How to debug hosted local multiplayer:**
```bash
# Watch both logs in separate terminals
tail -f ~/Zomboid/console.txt      # Terminal 1: Client logs
tail -f ~/Zomboid/coop-console.txt # Terminal 2: Server logs (THIS IS WHERE SERVER CODE RUNS!)

# Search for your mod's server-side logs
grep "YourModName" ~/Zomboid/coop-console.txt | tail -n 50

# Search for errors in server log
grep -i "error\|exception" ~/Zomboid/coop-console.txt | tail -n 20
```

### Common Issues

1. **Items not syncing to client:**
   - Missing `sendAddItemToContainer(container, item)` call after `AddItem()`
   - Example: Server adds item to container but client never sees it until reconnect/reload
   
2. **Server file not loading:**
   - Check if file is in `server/` or `shared/` directory
   - Shared files need `if not isServer() then return end` guard at the top
   - **Look for load messages in `coop-console.txt` (NOT `console.txt`!)**
   - Add a print statement at the end of your server file to confirm it loaded

3. **Client-server architecture confusion:**
   - **Hosted local runs client and server in SEPARATE processes**
   - Client process: `isClient()=true, isServer()=false` → logs to `console.txt`
   - Server process: `isClient()=false, isServer()=true` → logs to `coop-console.txt`
   - Even though you're the host, your client code still needs to send server commands
   - Always use client-server command pattern in multiplayer, even for hosted local

4. **Server commands not being received:**
   - Check `coop-console.txt` for `OnClientCommand` logs
   - Verify `Events.OnClientCommand.Add(handler)` is being called
   - Make sure server file has proper guard: `if not isServer() then return end`
   - Remember: `sendClientCommand()` is sent FROM client TO server

5. **Can't find server-side errors:**
   - **ALWAYS check `coop-console.txt` for hosted local games!**
   - Stack traces for server-side errors appear in the server log, not client log
   - Example: "Object tried to call nil" errors in server code → `coop-console.txt`

## Quick Reference Commands

```bash
# Find all Lua files
find ~/Library/Application\ Support/Steam/steamapps/common/ProjectZomboid/Project\ Zomboid.app/Contents/Java/ \
  -name "*.lua" -type f 2>/dev/null | head -n 20

# Search for specific function/pattern in server code
grep -r "PATTERN" \
  ~/Library/Application\ Support/Steam/steamapps/common/ProjectZomboid/Project\ Zomboid.app/Contents/Java/media/lua/server/ \
  2>/dev/null

# Search entire Lua codebase
grep -r "PATTERN" \
  ~/Library/Application\ Support/Steam/steamapps/common/ProjectZomboid/Project\ Zomboid.app/Contents/Java/media/lua/ \
  2>/dev/null | head -n 50
```

## Notes for AI Agents

- **Always check vanilla code first** when implementing multiplayer features
- **Server logs are in `coop-console.txt`** for hosted local servers, not `console.txt`
- **Use `sendAddItemToContainer()`** after every server-side `AddItem()` call
- **The Umbrella library** in this project is useful for type hints but may not be complete
- **Grep examples are faster** than trying to remember API from documentation

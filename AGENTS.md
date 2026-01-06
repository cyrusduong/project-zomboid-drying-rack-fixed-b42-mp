<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# Project Zomboid Mod Development Instructions

## Local Testing Setup

When working on Project Zomboid mods, follow this setup for local testing:

### Required Directory Structure
The workshop uploader and game engine require specific structure:

```
~/Zomboid/Workshop/DryingRacksFixedB42MP/
└── Contents/                   # All mod files must be inside this
    └── mods/
        └── DryingRacksFixedB42MP/
            ├── mod.info         # Mod metadata (nested only)
            ├── preview.png      # Workshop thumbnail (nested only)
            ├── .emmyrc.json    # EmmyLua configuration
            └── 42/
                └── media/
                    └── lua/
                        ├── client/
                        ├── shared/
                        └── tests/
```

### Installation Commands
```bash
# Remove any existing installation
rm -rf ~/Zomboid/Workshop/DryingRacksFixedB42MP

# Copy Contents folder (workshop uploader requirement)
cp -r /path/to/project/Contents ~/Zomboid/Workshop/DryingRacksFixedB42MP
```

### Critical Constraints
- **No symlinks**: Workshop uploader and game engine don't support symlinks
- **Nested only**: `mod.info` and `preview.png` exist only in nested location (per B42 standard)
- **Contents folder**: Workshop uploader requires ALL files inside `Contents/`
- **Build 42 structure**: Use `42/media/lua/` for Build 42 compatibility

### Testing Workflow
1. Edit files in project source (`/path/to/project/`).
2. **Sync Changes**: Run `./install.sh` to update the physical files in `~/Zomboid/Workshop/LeatherDryingRack`.
3. Launch Project Zomboid.
4. Enable the mod and test in-game.

### Mod Discovery Mitigation (macOS)
Build 42 on macOS has difficulty with symlinks.
- **Use Physical Copies**: Always copy files directly to the target directory via `./install.sh`.
- **Workshop Path**: The project uses `~/Zomboid/Workshop/DryingRacksFixedB42MP` as the active mod location.

### Type Safety & Validation
- **EmmyLua Integration**: This project uses EmmyLua for type checking. Ensure all Lua files have proper type annotations.
- **Validation**: Before submitting changes, verify that there are no type errors. The project leverages the `Umbrella` library for Project Zomboid API types.
- **Tooling (Fast Check)**: For AI assistants, use `.emmyrc.fast.json` to perform a quick syntax and internal reference check without the heavy API library.
  ```bash
  /Users/cduong/.cargo/bin/emmylua_check --config Contents/mods/DryingRacksFixedB42MP/.emmyrc.fast.json Contents/mods/DryingRacksFixedB42MP/42/media/lua/
  ```
- **Tooling (Full Check)**: For manual validation, use the standard `.emmyrc.json`.
- **Global Suppression**: Many Project Zomboid globals (e.g., `IsoPlayer`, `Events`, `luautils`) will show as undefined in the "Fast Check". This is expected; focus on errors within the mod's own logic.

### Code Style & Formatting
- **Lua Indentation**: Use **Tabs** for indentation in all Lua files to maintain consistency with the project's LSP (lua_ls) settings.
- **Trailing Whitespace**: Ensure no trailing whitespace is left in the files.
- **Spacing**: Follow standard Lua spacing conventions (e.g., space around operators like `x = 1 + 2`).

### Steam Workshop Configuration
- **VDF Formatting**: The `workshop_build.vdf` file uses Steam's BBCode formatting (e.g., `[b]`, `[i]`, `[url]`). Standard Markdown is **not** supported and will be rendered as literal text on the Workshop page.
- **Quoting**: Avoid using internal double quotes (`"`) or escaped quotes (`\"`) inside the `description` or `changenote` values, as they can interfere with VDF parsing or render incorrectly on the Steam Workshop. Use BBCode tags like `[b]` or `[i]` for emphasis instead.

### Scripting Utilities
- **./install.sh**: Synchronizes local project files to the Zomboid Workshop directory.
- **./publish.sh**: Wrapper script that runs `./install.sh` and then uses `steamcmd` to upload the mod to the Steam Workshop.

## Troubleshooting & Logs
When debugging issues in Project Zomboid, always check the console log for errors (e.g., Lua stack traces, mod loading failures).

### Log Files (Single Player)
- **Log Path (macOS)**: `/Users/cduong/Zomboid/console.txt`
- **Search for**: `DryingRacksFixedB42MP` or `ERROR: lua` to find relevant logs.

### Log Files (Multiplayer - Hosted Local)
When using "Host" from the main menu, you run BOTH client and server in separate processes:
- **Client log**: `~/Zomboid/console.txt` - Client-side Lua code logs here
- **Server log**: `~/Zomboid/coop-console.txt` - **Server-side Lua code logs here!**

**CRITICAL:** Many developers only check `console.txt` and miss server-side errors in `coop-console.txt`!

```bash
# Watch both logs when testing multiplayer
tail -f ~/Zomboid/console.txt      # Client logs
tail -f ~/Zomboid/coop-console.txt # Server logs (check this for server command handlers!)
```

## Vanilla Game Files Reference

When implementing features (especially multiplayer/server features), reference vanilla game code for API usage patterns:

- **See `GAME_FILES_REFERENCE.md`** for comprehensive guide on searching vanilla code
- **Game files location:** `~/Library/Application Support/Steam/steamapps/common/ProjectZomboid/Project Zomboid.app/Contents/Java/media/lua/`
- **Most useful:** `server/ClientCommands.lua` for server command examples
- **Key pattern:** Always use `sendAddItemToContainer(container, item)` after server-side `AddItem()` calls

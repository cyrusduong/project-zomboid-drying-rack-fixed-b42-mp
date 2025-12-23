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
~/Zomboid/Workshop/DryingRackFixedB42MP/
└── Contents/                   # All mod files must be inside this
    └── mods/
        └── DryingRackFixedB42MP/
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
rm -rf ~/Zomboid/Workshop/DryingRackFixedB42MP

# Copy Contents folder (workshop uploader requirement)
cp -r /path/to/project/Contents ~/Zomboid/Workshop/DryingRackFixedB42MP
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
- **Workshop Path**: The project uses `~/Zomboid/Workshop/DryingRackFixedB42MP` as the active mod location.

### Code Style & Formatting
- **Lua Indentation**: Use **Tabs** for indentation in all Lua files to maintain consistency with the project's LSP (lua_ls) settings.
- **Trailing Whitespace**: Ensure no trailing whitespace is left in the files.
- **Spacing**: Follow standard Lua spacing conventions (e.g., space around operators like `x = 1 + 2`).

### Scripting Utilities
- **./install.sh**: Synchronizes local project files to the Zomboid Workshop directory.
- **./publish.sh**: Wrapper script that runs `./install.sh` and then uses `steamcmd` to upload the mod to the Steam Workshop.

## Troubleshooting & Logs
When debugging issues in Project Zomboid, always check the console log for errors (e.g., Lua stack traces, mod loading failures).
- **Log Path (macOS)**: `/Users/cduong/Zomboid/console.txt`
- **Search for**: `DryingRackFixedB42MP` or `ERROR: lua` to find relevant logs.

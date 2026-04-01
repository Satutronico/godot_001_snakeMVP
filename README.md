# godot_001_snakeMVP

Classic Snake game built as an MVP to explore PC game development with Godot 4, using only command-line tooling and procedural asset generation — no external art tools or the Godot editor GUI required.

---

## Project folder structure

```
godot_001_snakeMVP/
├── project.godot          # Project configuration (entry scene, window size, autoloads, renderer)
├── icon.svg               # Application icon — hand-written SVG, no external tool
├── .gitignore             # Excludes .godot/ cache and build artefacts
│
├── scenes/
│   ├── Menu.tscn          # Main menu scene (entry point)
│   └── Game.tscn          # Gameplay scene
│
└── scripts/
    ├── SaveData.gd        # Autoload singleton — loads/saves player name, max score, max level
    ├── Menu.gd            # Menu screen: name input, level progression table, scene transition
    └── Game.gd            # Snake logic, level system, collision, HUD, procedural rendering
```

> `scenes/Main.tscn` and `scripts/Main.gd` are legacy files from the initial commit and are no longer referenced.

---

## Godot resources in use

| Resource | Purpose |
|---|---|
| `project.godot` | Project settings — window size (640×640), main scene, autoload, renderer |
| `ConfigFile` API | Persists save data to `user://save.cfg` (OS user-data folder) |
| `Node2D._draw()` | Procedural rendering of grid, snake, food, and eyes via draw primitives |
| `Control` nodes | Menu UI — `Label`, `LineEdit`, `Button`, `ColorRect` created at runtime |
| Autoload singleton | `SaveData` is registered globally so both scenes share the same data |
| `get_tree().change_scene_to_file()` | Scene transitions between menu and game |
| Input actions | `ui_up/down/left/right` (arrow keys), `ui_accept` (Enter) — built-in Godot defaults |

---

## Godot addons / extensions in use

None. This project uses no third-party addons or plugins from the Godot Asset Library.

---

## Additional tools in use

| Tool | Role |
|---|---|
| **Godot 4.6.1 console binary** `Godot_v4.6.1-stable_win64_console.exe` | Runs and imports the project from the command line |
| **Git** | Version control |
| **SVG** (hand-written XML) | Procedural icon generation — no external image editor used |

No external asset-generation tools (Blender, Aseprite, GIMP, etc.) are used. All visuals are drawn at runtime by GDScript using Godot's `CanvasItem` draw API.

---

## Launch the game from PowerShell

Make sure Godot is installed at `C:\Godot4\`. Then from the repo root:

```powershell
# Run the game (windowed, with console output)
& "C:\Godot4\Godot_v4.6.1-stable_win64_console.exe" --path "$PWD"
```

```powershell
# Run headless (no window — useful for CI or script testing)
& "C:\Godot4\Godot_v4.6.1-stable_win64_console.exe" --path "$PWD" --headless
```

> If `GODOT` is set in your VSCode terminal environment (configured in `.vscode/settings.json`), you can also use:
> ```powershell
> & $Env:GODOT --path "$PWD"
> ```

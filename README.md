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
    ├── SaveData.gd        # Autoload singleton — loads/saves player name and top-5 ranking
    ├── Menu.gd            # Menu screen: name input, top-5 ranking table, scene transition
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

## Godot configuration

Settings defined in `project.godot`:

| Setting | Value | Reason |
|---|---|---|
| `config/features` | `"4.6", "Forward Plus"` | Targets Godot 4.6; Forward Plus is the default 3D-capable renderer but is overridden below |
| `run/main_scene` | `res://scenes/Menu.tscn` | Game starts at the menu, not directly in gameplay |
| `window/size/viewport_width` | `640` | Fixed grid: 32 columns × 20 px |
| `window/size/viewport_height` | `640` | Fixed grid: 32 rows × 20 px |
| `window/size/resizable` | `false` | Pixel grid must not scale or distort |
| `renderer/rendering_method` | `gl_compatibility` | Lightweight OpenGL 3.3 compatibility renderer — sufficient for 2D, wider hardware support |
| `renderer/rendering_method.mobile` | `gl_compatibility` | Same renderer enforced on mobile targets |
| `[autoload] SaveData` | `*res://scripts/SaveData.gd` | `*` prefix makes it a singleton Node, auto-instantiated before any scene loads |

---

## GDScript: `_process` and `_physics_process` usage

Godot provides two main per-frame callbacks:

- **`_process(delta)`** — called every rendered frame; frequency depends on frame rate (uncapped or vsync). `delta` is the time in seconds since the last frame.
- **`_physics_process(delta)`** — called at a fixed interval (default 60 Hz), decoupled from frame rate. Intended for physics simulation and movement that must be deterministic.

### Why this project uses only `_process`

Snake is a turn-based grid game driven by a **custom software timer** (`tick_timer`), not by continuous physics. There is no rigid-body simulation, no collision physics engine, and no need for deterministic fixed-step integration. Using `_process` is the correct choice here.

### Per-scene breakdown

#### `Menu.gd` — extends `Control`

| Callback | Used | Reason |
|---|---|---|
| `_ready()` | Yes | Builds the entire UI tree once at scene load |
| `_process(delta)` | No | Menu is fully static after `_ready()`; no animation or polling needed |
| `_physics_process(delta)` | No | No physics involvement |

#### `Game.gd` — extends `Node2D`

| Callback | Used | Reason |
|---|---|---|
| `_ready()` | Yes | Creates HUD labels and starts the first game |
| `_input(event)` | Yes | Reads arrow keys and Enter outside of the frame loop for immediate response |
| `_process(delta)` | Yes | See table below |
| `_physics_process(delta)` | No | Movement is grid-based and timer-driven, not physics-based |

What `_process(delta)` handles in `Game.gd`:

| Task | How |
|---|---|
| Game timer | `game_time += delta` — real-world elapsed seconds, displayed as `m:ss` in the HUD |
| Level-up flash | `flash_timer -= delta` — fades a colour overlay over ~0.45 s |
| Snake movement | `tick_timer += delta`; when it exceeds `tick_rate`, one grid step is executed and the timer resets. `tick_rate` starts at 150 ms and decreases with each level |

The separation between `delta` accumulation (every frame) and `tick_rate` gating (fixed logical steps) means the game loop remains smooth on any frame rate while snake speed stays predictable.

#### `SaveData.gd` — extends `Node` (Autoload singleton)

| Callback | Used | Reason |
|---|---|---|
| `_ready()` | No | Data is loaded explicitly via `load_data()` when the menu scene starts |
| `_process(delta)` | No | Passive data store; no per-frame work needed |
| `_physics_process(delta)` | No | No physics involvement |

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

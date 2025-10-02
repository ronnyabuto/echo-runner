# Development Guide - Run for the Echo

## Project Structure

This is a complete Godot 4.x implementation with full gameplay systems. All code is production-ready, using placeholder assets that can be replaced with final art.

## Quick Start

### Opening the Project

1. Install Godot 4.3 or later from https://godotengine.org/
2. Open Godot
3. Click "Import"
4. Navigate to this folder and select `project.godot`
5. Click "Import & Edit"

### Running the Game

- Press **F5** or click the Play button in Godot editor
- Game starts at Main Menu
- Select "Start Game" to play Level 1

### Testing Individual Levels

- Open any level scene in `scenes/levels/`
- Press **F6** or click "Play Scene" to test that specific level

## Architecture

### Core Systems

#### GameManager (Autoload Singleton)
Location: `scripts/managers/game_manager.gd`

Handles:
- Score tracking and updates
- Level progression
- High score persistence
- Game settings storage
- Save/load functionality

Key methods:
- `start_level(level_name)` - Initialize level
- `add_score(points)` - Add to current score
- `complete_level()` - Handle level completion
- `get_high_score(level_name)` - Retrieve best score

#### AudioManager (Autoload Singleton)
Location: `scripts/managers/audio_manager.gd`

Handles:
- SFX playback with pooling
- Music management
- Volume controls
- Audio bus routing

Key methods:
- `play_sfx(sfx_name)` - Play sound effect
- `play_music(music_name)` - Start music track
- `set_sfx_volume(volume)` - Adjust SFX volume
- `register_sfx(name, stream)` - Add audio to library

### Player System

#### Player Controller
Location: `scripts/core/player.gd`, `scenes/player/Player.tscn`

Features:
- Platformer movement with air control
- Coyote time and jump buffering
- Shockwave charging mechanics
- Collectible tracking
- Voice evolution system

Key exports:
- `move_speed`: Horizontal movement speed
- `jump_velocity`: Jump force (negative)
- `max_shockwave_charge`: Time to charge honesty blast

#### Shockwave System
Location: `scripts/core/shockwave.gd`, `scenes/player/Shockwave.tscn`

Physics-based audio waveform that:
- Expands radially from spawn point
- Pushes physics bodies
- Damages enemies
- Activates platforms
- Attracts collectibles

Power multiplier affects radius and force.

### Enemy System

#### Base Enemy
Location: `scripts/enemies/base_enemy.gd`, `scenes/enemies/BaseEnemy.tscn`

Reusable AI with:
- Patrol behavior
- Player detection and chase
- Wall/edge detection
- Shockwave reaction (stun + knockback)
- Health and damage

Easily extended for variants.

### Boss System

#### Lobbyist Boss (Mid-Boss)
Location: `scripts/bosses/lobbyist_boss.gd`, `scenes/bosses/LobbyistBoss.tscn`

Three phases:
1. **Cash Rain** - Spawns projectiles above player
2. **Influence Shields** - Creates bubble shields around self
3. **Bribed Minions** - Spawns controlled enemies

Phases cycle based on timer and completion conditions.

#### Machine Candidate (Final Boss)
Location: `scripts/bosses/machine_candidate.gd`, `scenes/bosses/MachineCandidate.tscn`

Three phases:
1. **Propaganda Wall** - Moving wall segments to destroy
2. **Drone Barrage** - Spawns homing attack drones
3. **Resonance Core** - Timed vulnerability windows with truth nodes

Final phase requires precise timing to hit truth nodes during resonance window.

### Level System

#### BaseLevel
Location: `scripts/core/base_level.gd`

Template for all levels providing:
- Player spawning
- Shockwave instantiation
- Level exit detection
- Time tracking
- Score integration

All levels inherit from this.

### UI System

#### Menus
- **MainMenu**: Entry point with level select, settings, quit
- **LevelSelect**: Shows all levels with high scores
- **Settings**: Audio, accessibility, gameplay options
- **PauseMenu**: In-game pause with resume/restart/quit
- **LevelComplete**: End screen with score, time, next level
- **HUD**: In-game overlay with score, voices, charge bar

### Collectible System

Location: `scripts/collectibles/voice_collectible.gd`

Four evolution stages:
1. **FLYER** (Blue) - Basic collectible
2. **VOTE** (Gold) - Unlocks at 10 voices
3. **VIRAL_CLIP** (Pink) - Unlocks at 25 voices, enables double jump
4. **CROWD_ECHO** (Green) - Unlocks at 50 voices, converts enemies

Each stage increases score multiplier.

## Replacing Placeholder Assets

### Sprites

All sprites use `PlaceholderTexture2D`. To replace:

1. Create pixel art sprites matching these dimensions:
   - Player: 32×48 pixels
   - Enemies: 40×40 pixels
   - Collectibles: 24×24 pixels
   - Bosses: 80×80 (Lobbyist), 100×100 (Machine)
   - Projectiles: 20×20 pixels

2. Import sprites into `assets/sprites/`

3. Open each scene (`.tscn` files) in Godot

4. Select the Sprite2D node

5. In Inspector, drag your sprite into the "Texture" property

6. Adjust `offset`, `region_rect` if using sprite sheets

### Audio

The AudioManager is set up but has no audio files. To add:

1. Create/generate audio files:
   - **SFX**: Use Bfxr (https://www.bfxr.net/) for retro sounds
   - **Music**: Short chiptune loops (OGG recommended for web)

2. Import audio into `audio/` folder

3. In `audio_manager.gd` `_ready()` function, register audio:
   ```gdscript
   register_sfx("jump", preload("res://audio/sfx/jump.wav"))
   register_sfx("shockwave", preload("res://audio/sfx/shockwave.wav"))
   register_music("level1", preload("res://audio/music/level1.ogg"))
   ```

4. Call `play_sfx()` or `play_music()` as needed

Current SFX hooks:
- jump, shockwave, collect, enemy_hit, enemy_die, boss_die
- shield_break, resonance_hit, drone_shoot

### Tilesets

Currently levels use static ColorRect platforms. To add tilesets:

1. Create tileset image (powers of 2, e.g., 512×512)

2. Import into `assets/tilesets/`

3. In Godot, create new TileSet resource

4. Add your tileset image as a texture

5. Define tiles with collision shapes

6. In each level, assign TileSet to TileMap node

7. Paint tiles in the TileMap editor

## Adding New Levels

1. Duplicate `scenes/levels/Level1_RallyRow.tscn`

2. Rename to your level name

3. Modify in Godot editor:
   - Change layout (platforms, enemies, collectibles)
   - Set `level_name` export variable
   - Adjust `time_limit` and `collectible_goal`

4. Add to `scripts/ui/level_select.gd`:
   ```gdscript
   level_data.append({
       "name": "Your Level Name",
       "scene": "res://scenes/levels/YourLevel.tscn",
       "description": "Description"
   })
   ```

5. Update `scripts/ui/level_complete.gd` `_on_next_pressed()` for progression

## Tuning Gameplay

### Player Feel
`scripts/core/player.gd`:
- `move_speed`: How fast player runs (default: 300)
- `jump_velocity`: Jump height (default: -500, negative = up)
- `acceleration`: Ground acceleration (default: 2000)
- `air_acceleration`: Air control (default: 1200)
- `coyote_time`: Grace period for jumps (default: 0.15s)

### Shockwave Power
`scripts/core/shockwave.gd`:
- `base_radius`: Starting size (default: 150)
- `expansion_speed`: Growth rate (default: 400)
- `push_force`: Knockback strength (default: 500)
- `lifetime`: Duration (default: 0.8s)

### Enemy Difficulty
`scripts/enemies/base_enemy.gd`:
- `max_health`: Hit points (default: 3)
- `move_speed`: Patrol/chase speed (default: 100)
- `detection_range`: How far they see player (default: 300)

### Boss Health
- **Lobbyist**: `max_health: 30` in scene inspector
- **Machine Candidate**: `max_health: 50` in scene inspector

## Exporting

### HTML5 (Web)

1. **Editor > Manage Export Templates** - Download templates if needed

2. **Project > Export**

3. Select "HTML5" preset (already configured in `export_presets.cfg`)

4. Click **Export Project**

5. Choose `builds/web/` folder

6. Test locally:
   ```bash
   cd builds/web
   python -m http.server 8000
   # Visit http://localhost:8000
   ```

7. Deploy `builds/web/` folder to any web host

### Android

1. Install Android SDK and build tools

2. In Godot: **Editor > Export > Android**

3. Set up keystore for signing

4. Click **Export Project**

5. Choose `builds/android/run_for_the_echo.apk`

6. Install on device: `adb install builds/android/run_for_the_echo.apk`

### Performance Tips

- Keep sprite resolutions low (pixel art style)
- Use compressed audio (OGG for web)
- Limit particle effects on mobile
- Pool frequently instantiated objects
- Avoid allocations in `_physics_process`

## Common Issues

### Player falls through floor
- Check collision layers (Player: layer 1, Environment: layer 4)
- Ensure floor has StaticBody2D with CollisionShape2D

### Shockwave doesn't hit enemies
- Verify Shockwave collision mask includes layer 2 (Enemy)
- Check enemy collision layer is 2

### Boss doesn't take damage
- Boss may be invulnerable during certain phases
- Check `is_vulnerable` flag in boss script

### UI doesn't show
- Ensure HUD/Menus are CanvasLayer nodes
- Check z-index (UI should be higher than game objects)

### Audio doesn't play
- Register audio files in `audio_manager.gd`
- Check audio bus volumes in Project Settings

## Performance Targets

- **60 FPS** on mid-range devices
- **< 100 MB** total size with assets
- **< 2 second** load times between levels
- **Minimal GC spikes** during gameplay

## Testing Checklist

- [ ] Player movement feels responsive
- [ ] Jump timing feels good (adjust coyote time if needed)
- [ ] Shockwave visually reads as expanding wave
- [ ] Collectibles are visible and satisfying to grab
- [ ] Enemies react to shockwave (stun + knockback)
- [ ] Boss phases are clear and telegraphed
- [ ] UI is readable at all screen sizes
- [ ] Score system tracks correctly
- [ ] High scores persist between sessions
- [ ] Pause menu works (ESC key)
- [ ] Level complete/game over screens function
- [ ] Settings save and apply correctly

## Next Steps

1. **Art Pass**: Replace all placeholders with final pixel art
2. **Audio Pass**: Add SFX and music tracks
3. **Polish**: Screen shake, particles, juice effects
4. **Playtesting**: Balance difficulty curves
5. **Mobile Controls**: Add virtual joystick overlay
6. **Analytics**: Integrate telemetry for player behavior
7. **Leaderboards**: Add online high scores via Supabase

## Support

This is a complete MVP implementation. All systems are functional and ready for art/audio integration.

For questions about the codebase:
- Check inline comments in scripts
- Review signal connections in scenes
- Reference Godot 4.x documentation

---

**Version**: 1.0 MVP
**Engine**: Godot 4.3+
**License**: Project source provided for commissioned scope

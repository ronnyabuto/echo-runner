# Run for the Echo

A retro pixel side-scroller where your voice is a weapon, a tool, and a rumor. Collect the People's Voices, amplify them into a shockwave that reshapes the world, and topple a mechanical "machine candidate."

## Game Overview

**Genre**: Action Side-Scroller / Platformer
**Target Platform**: HTML5 (Web), Android, iOS
**Engine**: Godot 4.x
**Art Style**: Retro pixel art with limited color palette

## Core Gameplay

### Controls

- **Keyboard**:
  - Arrow Keys / WASD: Move left/right
  - Space / W / Up Arrow: Jump
  - E / X: Charge and release shockwave
  - ESC: Pause

- **Mobile** (Touch):
  - Left side: Virtual joystick for movement
  - Right side: Jump button
  - Hold to charge shockwave, release to fire

### Mechanics

1. **Shockwave System**: Your primary tool and weapon
   - Press and hold to charge
   - Release to fire an expanding audio waveform
   - Pushes enemies, breaks obstacles, activates platforms
   - Charge longer for "Honesty Blast" (increased power and radius)

2. **Collectible Evolution**: Four stages of voice collection
   - **Flyers** (basic) → **Votes** → **Viral Clips** → **Crowd Echo**
   - Each stage unlocks new abilities and interactions
   - Viral Clips: Spawn temporary platforms
   - Crowd Echo: Temporarily convert enemies to allies

3. **Crowd Memory**: Levels remember your loudest shockwaves
   - Ghost echoes replay to help solve timing puzzles
   - Emergent strategies without extra level design

## Levels

### Level 1: Rally Row
Beginner-friendly level with basic platforming, cheering pickups, and light hazards. Learn the core mechanics.

### Level 2: Media Maze
Moving headline platforms, microphones that bounce you, and increased enemy presence. Collectibles evolve to "viral clips."

### Level 3: Lobby Lane (Mid-Boss)
Arena battle against the **Lobbyist** with three phases:
- **Cash Rain**: Dodge falling projectiles
- **Influence Shields**: Use shockwave to pop bubble shields
- **Bribed Minions**: Flip enemies with Crowd Echo ability

### Level 4: Election Factory (Final Boss)
Face the **Machine Candidate** in an epic showdown:
- **Propaganda Wall**: Destroy moving wall segments
- **Drone Barrage**: Dodge and destroy attack drones
- **Resonance Core**: Time your shockwave to hit "truth nodes" during vulnerability windows

## Features

- **Fast, Replayable Gameplay**: Short runs with randomized obstacle sequences
- **Score System**: Speed × Voices × Honesty Streak multiplier
- **High Score Tracking**: Per-level best scores and times
- **Accessibility Options**: Color-blind mode, adjustable audio cues, difficulty settings
- **Save System**: Auto-saves progress and high scores locally

## Technical Details

### Project Structure

```
project/
├── scenes/
│   ├── player/          # Player character and shockwave
│   ├── enemies/         # Enemy AI and variants
│   ├── bosses/          # Mid-boss and final boss
│   ├── collectibles/    # Voice collectibles
│   ├── levels/          # All 4 game levels
│   └── ui/              # Menus, HUD, settings
├── scripts/
│   ├── core/            # Core game systems
│   ├── managers/        # Game and audio managers
│   ├── enemies/         # Enemy behaviors
│   ├── bosses/          # Boss AI
│   └── ui/              # UI controllers
├── assets/
│   ├── sprites/         # Placeholder sprite sheets
│   └── tilesets/        # Level tilesets
└── audio/               # Audio bus configuration
```

### Key Systems

- **GameManager**: Handles scoring, level progression, save/load
- **AudioManager**: Manages SFX and music playback
- **Player**: Character controller with shockwave mechanics
- **BaseEnemy**: Reusable enemy AI with patrol and chase behaviors
- **BaseLevel**: Level template with spawn points and exit triggers

### Export Targets

1. **HTML5** (Primary)
   - Canvas-based web build
   - Optimized for modern browsers
   - No plugins required

2. **Android**
   - APK export configured
   - Touch controls enabled
   - Targeting Android 5.0+

3. **iOS** (Future)
   - Xcode project export ready
   - Touch controls compatible

## Development Notes

### Performance Targets

- 60 FPS on mid-range devices
- Minimal memory allocation during gameplay
- Object pooling for projectiles and effects
- Compressed textures and audio

### Art Placeholders

All sprites currently use Godot's PlaceholderTexture2D with color coding:
- **Player**: Blue (0.4, 0.8, 1.0)
- **Enemies**: Red (1.0, 0.3, 0.3)
- **Collectibles**: Variable by type (cyan, gold, pink, green)
- **Bosses**: Purple/Gray

Replace these with actual pixel art assets maintaining similar dimensions.

### Audio Placeholders

The AudioManager is configured but currently has no audio files. Add:
- SFX: jump, shockwave, collect, enemy_hit, enemy_die, boss_die, etc.
- Music: Main menu theme, level background tracks

Use Bfxr or similar for procedural SFX generation.

## Building the Game

### Requirements

- Godot 4.3 or later
- Export templates installed for target platforms

### HTML5 Build

1. Open project in Godot
2. Project → Export
3. Select "HTML5" preset
4. Click "Export Project"
5. Choose output directory
6. Serve `index.html` via local web server

### Testing Locally

```bash
# Simple Python web server
cd builds/web
python -m http.server 8000
# Visit http://localhost:8000
```

## Store Assets (Prepared)

### Required Assets

1. **App Icon**: 1024×1024 PNG (currently placeholder icon.svg)
2. **Screenshots**: Capture 3-5 action shots from gameplay
3. **Short Description**: "Voice-powered retro platformer. Use sound to reshape the world and topple the machine."
4. **Long Description**: See game overview above
5. **Privacy Policy**: Minimal analytics, no personal data collection

### Metadata

- **Age Rating**: E for Everyone (mild fantasy violence)
- **Category**: Action, Arcade, Platformer
- **Keywords**: retro, platformer, action, voice, pixel art

## Future Enhancements

- Online leaderboards (post-MVP via Supabase)
- Additional levels and boss variants
- New collectible types and abilities
- Custom level editor
- Multiplayer co-op mode

## Credits

- Engine: Godot 4.x
- Concept: "Run for the Echo" original game design
- Code: Full GDScript implementation
- Art: Placeholder (ready for asset replacement)
- Audio: Placeholder (ready for audio assets)

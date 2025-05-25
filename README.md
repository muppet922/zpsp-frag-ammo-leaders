# ZPSP Frags/Packs Leaders Plugin

A Zombie Plague Special plugin that displays the top frags and ammo packs leaders on your server.

## Features

- **Top Frags Leaders**: Shows players with the highest kill count
- **Top Ammo Packs Leaders**: Shows players with the most ammo packs
- **Bot Exclusion**: Only displays human players in leaderboards
- **Customizable Display**: Multiple display modes and leader count options
- **Multi-language Support**: Uses dictionary files for translations

## Installation

1. Place `zpsp_frag_leaders.sma` in your `addons/amxmodx/scripting/` folder
2. Compile the plugin using AMX Mod X compiler
3. Move the compiled `.amx` file to `addons/amxmodx/plugins/`
4. Add the plugin to your `plugins.ini` file
5. Add the language dictionary file `zpnm_frags-packs_leaders.txt` to your `addons/amxmodx/data/lang/` folder

## Configuration

### CVars

- `zp_leaders_display_mode` (default: 3)
  - 0: Display off
  - 1: Display at round start
  - 2: Display as welcome message (2.2s delay)
  - 3: Display at round end

- `zp_leaders_count` (default: 2)
  - Number of top leaders to display (1-3)

### Example Output
```
[ZvH] Top Frags: Player1(15), Player2(12), Player3(8)
[ZvH] Top Packs: Player1(250), Player3(180), Player2(150)
```

## Requirements

- AMX Mod X 1.8.2+
- Zombie Plague Special mod
- Counter-Strike 1.6

## Version

**1.3.4** - Now excludes bots from leaderboards

## Author

D i 5 7 i n c T
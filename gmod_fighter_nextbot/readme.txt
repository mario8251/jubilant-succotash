Fighter Bot Nextbot
====================

A versatile Garry's Mod nextbot that can fight various NPC types including SNPCs, Nextbots, VJ Base, DRGBase, CPTBase NPCs, and Players.

Features
--------
- **Configurable Targeting**: Enable/disable targeting for different NPC types via checkboxes:
  - Players
  - SNPCs (Standard NPCs)
  - Nextbots
  - VJ Base NPCs
  - DRGBase NPCs
  - CPTBase NPCs

- **Custom Models**: Use any player model available on the server
- **Custom Weapons**: Equip the bot with any weapon from the server
- **Adjustable Stats**: Configure health and movement speed
- **Easy Configuration**: Use the spawnmenu panel or console commands

Installation
------------
1. Copy the `gmod_fighter_nextbot` folder to your Garry's Mod addons directory:
   - For servers: `garrysmod/addons/gmod_fighter_nextbot/`
   - For singleplayer: `garrysmod/addons/gmod_fighter_nextbot/`

2. Restart Garry's Mod or type `lua_reloadents` in console

Usage
-----

### Spawning
1. Open the spawn menu (Q by default)
2. Navigate to "Entities" -> "Fighter Bots"
3. Click on "Fighter Bot" to spawn

### Configuration Panel
1. Open spawn menu (Q)
2. Go to the "Fighter Bots" tab
3. Click "Open Configuration Panel"
4. Right-click on a spawned Fighter Bot to select it
5. Configure targeting options, model, and weapon

### Console Commands
```
-- Set bot model
fighterbot_setmodel <entity_index> <model_path>
Example: fighterbot_setmodel 123 models/player/combine_soldier.mdl

-- Set bot weapon
fighterbot_setweapon <entity_index> <weapon_class>
Example: fighterbot_setweapon 123 weapon_ar2

-- Toggle targeting
fighterbot_settarget <entity_index> <target_type> <0|1>
Target types: players, snpcs, nextbots, vjbase, drgbase, cptbase
Example: fighterbot_settarget 123 players 0  (Disable targeting players)
```

### Networked Variables (For Scripters)
```lua
-- Read configuration
local targetPlayers = bot:GetNWBool("TargetPlayers", true)
local customModel = bot:GetNWString("CustomModel", "")
local customWeapon = bot:GetNWString("CustomWeapon", "")
local health = bot:GetNWInt("Health", 100)
local damageMult = bot:GetNWFloat("DamageMultiplier", 1.0)
local moveSpeed = bot:GetNWFloat("MoveSpeed", 250)
```

Compatibility
-------------
This nextbot is designed to work with:
- Standard Garry's Mod NPCs
- SNPCs (any addon using snpc_ prefix)
- VJ Base NPCs (npc_vj_ prefix or VJ detection methods)
- DRGBase NPCs (drg_ prefix or DRG detection methods)
- CPTBase NPCs (cpt_ prefix or CPT detection methods)
- Other Nextbots
- Players

Technical Details
-----------------
- Uses GMod's base_nextbot system
- Pathfinding via GMod's built-in navigation mesh
- Coroutine-based behavior system
- Networked variables for client-server synchronization
- Detection through class name patterns and entity methods

Troubleshooting
---------------
1. Bot not spawning?
   - Check console for errors
   - Ensure you have permission to spawn NPCs
   - Verify the addon is loaded correctly

2. Bot not attacking?
   - Check if targeting is enabled for the target type
   - Ensure the bot has a valid weapon
   - Check if the target is within range (2000 units)

3. Bot stuck or not moving?
   - Ensure the map has a valid navmesh (generate one with `nav_generate` if needed)
   - Check for obstacles blocking the path

License
-------
Free to use and modify for personal and server use.
Please credit the original author if redistributing.

Support
-------
For issues or suggestions, please check the Garry's Mod forums or create an issue on the repository.

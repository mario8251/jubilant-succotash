-- Fighter Bot Nextbot - Auto-run file
-- This file ensures all necessary files are loaded

if SERVER then
    -- Add resource files for client download
    resource.AddFile("lua/entities/npc_fighter_bot/cl_init.lua")
    resource.AddFile("lua/entities/npc_fighter_bot/shared.lua")
    
    print("[Fighter Bot] Server initialization complete")
end

if CLIENT then
    include("spawnmenu/fighter_bot_config.lua")
    print("[Fighter Bot] Client initialization complete")
end

print("[Fighter Bot] Loaded successfully!")

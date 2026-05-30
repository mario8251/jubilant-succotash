-- Fighter Bot Nextbot
-- A versatile bot that can fight SNPCs, Nextbots, VJ Base, DRGBase, CPTBase NPCs, and Players

AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Spawnable = true
ENT.Category = "Fighter Bots"
ENT.PrintName = "Fighter Bot"
ENT.Author = "Bot Creator"
ENT.Instructions = "Spawn and configure via spawnmenu or console commands"

-- Networked variables for configuration
ENT.NetworkVars = {
    ["TargetPlayers"] = { type = "bool", default = true },
    ["TargetSNPCs"] = { type = "bool", default = true },
    ["TargetNextbots"] = { type = "bool", default = true },
    ["TargetVJBase"] = { type = "bool", default = true },
    ["TargetDRGBase"] = { type = "bool", default = true },
    ["TargetCPTBase"] = { type = "bool", default = true },
    ["CustomModel"] = { type = "string", default = "" },
    ["CustomWeapon"] = { type = "string", default = "" },
    ["Health"] = { type = "int", default = 100 },
    ["DamageMultiplier"] = { type = "float", default = 1.0 },
    ["MoveSpeed"] = { type = "float", default = 250 },
}

function ENT:Initialize()
    self:SetModel(self:GetModel() or "models/player/combine_soldier.mdl")
    self:SetHullSizeNormal()
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_STEP)
    
    -- Set health
    local hp = self:GetNWInt("Health", 100)
    self:SetHealth(hp)
    self:SetMaxHealth(hp)
    
    -- Set move speed
    local speed = self:GetNWFloat("MoveSpeed", 250)
    self:SetRunSpeed(speed)
    self:SetWalkSpeed(speed * 0.6)
    
    -- Setup collision
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    
    -- Initialize target tracking
    self.CurrentTarget = nil
    self.LastThinkTime = CurTime()
    self.SearchCooldown = 0
    self.AttackCooldown = 0
    self.ReloadCooldown = 0
    
    -- Give weapon after a short delay
    timer.Simple(0.5, function()
        if IsValid(self) then
            self:GiveWeapon()
        end
    end)
    
    -- Setup capabilities
    self:SetUseType(SIMPLE_USE)
end

function ENT:GiveWeapon()
    local weaponClass = self:GetNWString("CustomWeapon", "weapon_pistol")
    
    -- Remove existing weapons
    self:StripWeapons()
    
    -- Give the specified weapon
    local weapon = self:Give(weaponClass)
    if not IsValid(weapon) then
        -- Fallback to pistol if weapon not found
        weapon = self:Give("weapon_pistol")
    end
    
    -- Set damage multiplier if possible
    if IsValid(weapon) then
        self.CurrentWeapon = weapon
    end
end

function ENT:SetCustomModel(model)
    if model and model ~= "" then
        self:SetNWString("CustomModel", model)
        self:SetModel(model)
    end
end

function ENT:SetCustomWeapon(weaponClass)
    if weaponClass and weaponClass ~= "" then
        self:SetNWString("CustomWeapon", weaponClass)
        self:GiveWeapon()
    end
end

function ENT:SetTargetFlag(flagName, enabled)
    self:SetNWBool(flagName, enabled)
end

function ENT:ShouldTarget(ent)
    if not IsValid(ent) then return false end
    
    -- Don't target self or other fighter bots
    if ent == self or ent:GetClass() == self:GetClass() then
        return false
    end
    
    -- Check team (optional - can be modified for team-based gameplay)
    if ent:IsPlayer() and ent:Team() == self:Team() and self:Team() ~= TEAM_UNASSIGNED then
        return false
    end
    
    -- Check if it's a player
    if ent:IsPlayer() then
        return self:GetNWBool("TargetPlayers", true)
    end
    
    -- Check for SNPCs (various bases use different class patterns)
    local entClass = ent:GetClass()
    
    -- SNPC detection (general patterns)
    if string.StartWith(entClass, "snpc_") then
        return self:GetNWBool("TargetSNPCs", true)
    end
    
    -- Nextbot detection
    if ent:IsNextBot() or string.find(entClass, "nextbot") then
        return self:GetNWBool("TargetNextbots", true)
    end
    
    -- VJ Base detection
    if string.StartWith(entClass, "npc_vj_") or 
       (ent.IsVJBaseSNPC and ent:IsVJBaseSNPC()) or
       (ent.VJ_NPC_Class and ent.VJ_NPC_Class ~= "") then
        return self:GetNWBool("TargetVJBase", true)
    end
    
    -- DRGBase detection
    if string.StartWith(entClass, "drg_") or 
       (ent.DRGBase_NPC and ent:DRGBase_NPC()) or
       (ent.IsDRGBase and ent:IsDRGBase()) then
        return self:GetNWBool("TargetDRGBase", true)
    end
    
    -- CPTBase detection
    if string.StartWith(entClass, "cpt_") or 
       (ent.CPTBase_NPC and ent:CPTBase_NPC()) or
       (ent.IsCPTBase and ent:IsCPTBase()) then
        return self:GetNWBool("TargetCPTBase", true)
    end
    
    -- Generic NPC detection
    if ent:IsNPC() then
        return self:GetNWBool("TargetSNPCs", true)
    end
    
    return false
end

function ENT:FindNearestTarget()
    local bestTarget = nil
    local bestDistance = math.huge
    local searchRadius = 2000 -- Maximum search distance
    
    for _, ent in ipairs(ents.GetAll()) do
        if self:ShouldTarget(ent) then
            local dist = self:GetPos():Distance(ent:GetPos())
            if dist < searchRadius and dist < bestDistance then
                -- Check line of sight
                local trace = util.TraceLine({
                    start = self:GetPos() + Vector(0, 0, 64),
                    endpos = ent:GetPos() + Vector(0, 0, 64),
                    filter = self,
                    mask = MASK_SHOT
                })
                
                if trace.Hit and trace.Entity == ent then
                    bestTarget = ent
                    bestDistance = dist
                end
            end
        end
    end
    
    return bestTarget, bestDistance
end

function ENT:UpdateTarget()
    -- If current target is invalid or dead, clear it
    if not IsValid(self.CurrentTarget) or not self.CurrentTarget:Alive() then
        self.CurrentTarget = nil
    end
    
    -- Search for new target if needed
    if not self.CurrentTarget and CurTime() > self.SearchCooldown then
        self.CurrentTarget, _ = self:FindNearestTarget()
        self.SearchCooldown = CurTime() + 0.5 -- Search every 0.5 seconds
    end
    
    return self.CurrentTarget
end

function ENT:BehaveUpdate(fInterval)
    self.BehaveThread = coroutine.create(function()
        while IsValid(self) do
            self:UpdateTarget()
            
            if IsValid(self.CurrentTarget) then
                -- Move towards target
                local options = {
                    maxspeed = self:GetRunSpeed(),
                    tolerance = 50,
                    draw = true,
                }
                
                local path = Path("Follow")
                path:SetMinLookAheadDistance(100)
                path:SetGoalTolerance(50)
                path:Compute(self, self.CurrentTarget:GetPos())
                
                if path:IsValid() then
                    path:StartEngine(self, 0)
                    
                    while IsValid(self) and IsValid(self.CurrentTarget) do
                        local status = path:Update()
                        if status == PATH_COMPLETE then
                            break
                        end
                        
                        path:StartEngine(self, 0)
                        self:RunBehaviour()
                        
                        coroutine.yield()
                    end
                end
                
                -- Attack if in range
                self:TryAttack()
            else
                -- Wander or idle if no target
                self:IdleBehavior()
            end
            
            coroutine.yield()
        end
    end)
end

function ENT:RunBehaviour()
    -- Run the behave thread
    if self.BehaveThread and coroutine.status(self.BehaveThread) == "suspended" then
        local success, err = coroutine.resume(self.BehaveThread)
        if not success then
            print("Fighter Bot Behavior Error:", err)
        end
    end
end

function ENT:IdleBehavior()
    -- Simple idle behavior - look around
    local angles = self:GetAngles()
    angles.yaw = angles.yaw + math.sin(CurTime()) * 10
    self:SetAngles(angles)
end

function ENT:TryAttack()
    if not IsValid(self.CurrentTarget) or not IsValid(self.CurrentWeapon) then
        return
    end
    
    local dist = self:GetPos():Distance(self.CurrentTarget:GetPos())
    
    -- Check if in attack range
    if dist > 1000 then
        return
    end
    
    -- Check cooldowns
    if CurTime() < self.AttackCooldown then
        return
    end
    
    -- Face the target
    local aimAngle = (self.CurrentTarget:GetPos() - self:GetPos()):Angle()
    aimAngle.p = 0
    aimAngle.r = 0
    self:SetAngles(aimAngle)
    
    -- Fire weapon
    self.CurrentWeapon:PrimaryAttack()
    
    -- Set attack cooldown based on weapon fire rate
    self.AttackCooldown = CurTime() + 0.5
end

function ENT:HandleEvent(eventID, target)
    if eventID == EVENT_DEATH then
        self:OnDeath()
    elseif eventID == EVENT_HURT then
        self:OnHurt(target)
    end
end

function ENT:OnDeath()
    -- Drop weapon
    if IsValid(self.CurrentWeapon) then
        self.CurrentWeapon:Remove()
    end
    
    -- gib or ragdoll
    self:CreateRagdoll()
end

function ENT:OnHurt(attacker)
    -- Optional: Add custom hurt behavior
    if IsValid(attacker) then
        -- Could set attacker as priority target
        self.CurrentTarget = attacker
    end
end

function ENT:CreateRagdoll()
    local effectdata = EffectData()
    effectdata:SetEntity(self)
    effectdata:SetOrigin(self:GetPos())
    util.Effect("entity_remove", effectdata)
end

function ENT:Use(activator, caller, useType, value)
    -- Allow players to interact with the bot for configuration
    if activator:IsPlayer() then
        activator:PrintMessage(HUD_PRINTTALK, "Fighter Bot - Health: " .. self:Health())
        activator:PrintMessage(HUD_PRINTTALK, "Current Target: " .. (IsValid(self.CurrentTarget) and self.CurrentTarget:GetClass() or "None"))
    end
end

function ENT:OnTakeDamage(dmginfo)
    -- Apply damage multiplier
    local multiplier = self:GetNWFloat("DamageMultiplier", 1.0)
    dmginfo:ScaleDamage(1.0 / multiplier)
end

-- Console commands for configuration
concommand.Add("fighterbot_setmodel", function(ply, cmd, args)
    if #args < 2 then
        ply:ChatPrint("Usage: fighterbot_setmodel <bot_ent_index> <model_path>")
        return
    end
    
    local bot = Entity(tonumber(args[1]))
    if IsValid(bot) and bot:GetClass() == "npc_fighter_bot" then
        bot:SetCustomModel(args[2])
        ply:ChatPrint("Model set to: " .. args[2])
    end
end)

concommand.Add("fighterbot_setweapon", function(ply, cmd, args)
    if #args < 2 then
        ply:ChatPrint("Usage: fighterbot_setweapon <bot_ent_index> <weapon_class>")
        return
    end
    
    local bot = Entity(tonumber(args[1]))
    if IsValid(bot) and bot:GetClass() == "npc_fighter_bot" then
        bot:SetCustomWeapon(args[2])
        ply:ChatPrint("Weapon set to: " .. args[2])
    end
end)

concommand.Add("fighterbot_settarget", function(ply, cmd, args)
    if #args < 3 then
        ply:ChatPrint("Usage: fighterbot_settarget <bot_ent_index> <target_type> <0|1>")
        ply:ChatPrint("Target types: players, snpcs, nextbots, vjbase, drgbase, cptbase")
        return
    end
    
    local bot = Entity(tonumber(args[1]))
    local targetType = args[2]
    local enabled = tonumber(args[3]) == 1
    
    if IsValid(bot) and bot:GetClass() == "npc_fighter_bot" then
        local flagMap = {
            ["players"] = "TargetPlayers",
            ["snpcs"] = "TargetSNPCs",
            ["nextbots"] = "TargetNextbots",
            ["vjbase"] = "TargetVJBase",
            ["drgbase"] = "TargetDRGBase",
            ["cptbase"] = "TargetCPTBase",
        }
        
        local flag = flagMap[targetType:lower()]
        if flag then
            bot:SetTargetFlag(flag, enabled)
            ply:ChatPrint(targetType .. " targeting " .. (enabled and "enabled" or "disabled"))
        end
    end
end)

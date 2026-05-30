-- Fighter Bot Nextbot - Server Side
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel(self:GetModel() or "models/player/combine_soldier.mdl")
    self:SetHullSizeNormal()
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_STEP)
    
    -- Set health from networked var or default
    local hp = self:GetNWInt("Health", 100)
    if hp <= 0 then hp = 100 end
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
    
    -- Setup capabilities
    self:SetUseType(SIMPLE_USE)
    
    -- Give weapon after a short delay
    timer.Simple(0.5, function()
        if IsValid(self) then
            self:GiveWeapon()
        end
    end)
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

function ENT:BehaveUpdate(fInterval)
    self.BehaveThread = coroutine.create(function()
        while IsValid(self) do
            self:UpdateTarget()
            
            if IsValid(self.CurrentTarget) then
                -- Move towards target using nextbot pathfinding
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

function ENT:OnDeath()
    -- Drop weapon
    if IsValid(self.CurrentWeapon) then
        self.CurrentWeapon:Remove()
    end
    
    -- Create ragdoll effect
    local effectdata = EffectData()
    effectdata:SetEntity(self)
    effectdata:SetOrigin(self:GetPos())
    util.Effect("entity_remove", effectdata)
end

function ENT:OnHurt(attacker)
    -- Optional: Add custom hurt behavior
    if IsValid(attacker) then
        -- Could set attacker as priority target
        self.CurrentTarget = attacker
    end
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
    if multiplier and multiplier > 0 then
        dmginfo:ScaleDamage(1.0 / multiplier)
    end
end

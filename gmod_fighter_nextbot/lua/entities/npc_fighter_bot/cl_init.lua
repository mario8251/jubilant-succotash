-- Fighter Bot Nextbot - Client Side
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel(self:GetModel() or "models/player/combine_soldier.mdl")
    self:SetHullSizeNormal()
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_STEP)
    
    -- Setup collision
    self:SetCollisionGroup(COLLISION_GROUP_NPC)
    
    -- Initialize target tracking
    self.CurrentTarget = nil
end

function ENT:OnRemove()
    -- Cleanup on remove
end

function ENT:DoAnimationEvent(eventID, data)
    -- Handle animation events
    if eventID == ANIMEVENT_ATTACK_PRIMARY then
        -- Play attack animation
    elseif eventID == ANIMEVENT_ATTACK_SECONDARY then
        -- Play secondary attack animation
    end
    
    return ACT_INVALID
end

function ENT:CalcMainActivity(moveData)
    -- Calculate main activity based on movement
    local vel = self:GetVelocity()
    local speed = vel:Length2D()
    
    if speed > 10 then
        return ACT_RUN, moveData
    else
        return ACT_IDLE, moveData
    end
end

function ENT:UpdateAnimation()
    -- Update animation state
    local velocity = self:GetVelocity()
    local speed = velocity:Length2D()
    
    -- Set animation speed based on movement
    local playbackRate = math.Clamp(speed / 200, 0, 2)
    self:SetPlaybackRate(playbackRate)
    
    -- Face movement direction
    if speed > 10 then
        local angle = velocity:Angle()
        angle.p = 0
        angle.r = 0
        self:SetAngles(angle)
    end
end

---@class mordred_r : CDOTA_Ability_Lua
mordred_r = class({})

LinkLuaModifier("modifier_mordred_r_dash", "abilities/mordred/mordred_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_r_slash", "abilities/mordred/mordred_r", LUA_MODIFIER_MOTION_NONE)

function mordred_r:OnSpellStart()
    self.drained = 0
    self.pcf = ParticleManager:CreateParticle("particles/custom/mordred/sword_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(self.pcf, 1, self:GetCaster():GetRightVector() * 10)
end

function mordred_r:OnChannelThink(tick)
    local caster = self:GetCaster()
    local drain = self:GetSpecialValueFor("mana_cost") * tick
    if caster:GetMana() < drain then
        self:EndChannel(false)
        return
    end
    caster:SpendMana(drain, self)
    self.drained = self.drained + drain
end

function mordred_r:OnChannelFinish(interrupted)
    local caster = self:GetCaster()
    local channelTime = self:GetChannelTime()
    local channeled = GameRules:GetGameTime() - self:GetChannelStartTime()
    local maxDistance = self:GetSpecialValueFor("max_distance")
    local damageMin = self:GetSpecialValueFor("damage_min")
    local damageMax = self:GetSpecialValueFor("damage_max")
    local damageDiff = damageMax - damageMin

    local speed = 2400
    local distance = maxDistance * (channeled / channelTime)
    local damage = damageMin + damageDiff * (channeled / channelTime)
    local duration = distance / 2400

    caster:AddNewModifier(caster, self, "modifier_mordred_r_dash", {
        duration = duration,
        damage = damage,
        speed = speed,
        particle = self.pcf
    })
end

---@class modifier_mordred_r_dash : CDOTA_Modifier_Lua
modifier_mordred_r_dash = class({})

if IsServer() then
    function modifier_mordred_r_dash:OnCreated(args)
        self.pcf = args.particle
        self.damage = args.damage
        self.direction = self:GetParent():GetForwardVector() * args.speed
        self:StartIntervalThink(FrameTime())

    end

    function modifier_mordred_r_dash:OnIntervalThink()
        local parent = self:GetParent()
        local newPos = parent:GetAbsOrigin() + self.direction * FrameTime()
        parent:SetAbsOrigin(GetGroundPosition(newPos, parent))

        local attackPos = newPos + parent:GetRightVector() * self:GetAbility():GetSpecialValueFor("side_range")
        local targets = FindUnitsInLine(parent:GetTeam(), newPos, attackPos, nil, 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0)
        DebugDrawLine(newPos, attackPos, 255, 0, 0, false, 1)
    end

    function modifier_mordred_r_dash:OnDestroy()
        local parent = self:GetParent()
        parent:AddNewModifier(parent, self:GetAbility(), "modifier_mordred_r_slash", {duration = 0.3})
        ParticleManager:DestroyParticle(self.pcf, false)
        ParticleManager:ReleaseParticleIndex(self.pcf)
    end

    function modifier_mordred_r_dash:CheckState()
        return {
            [MODIFIER_STATE_STUNNED] = IsServer()
        }
    end
end

---@class modifier_mordred_r_slash : CDOTA_Modifier_Lua
modifier_mordred_r_slash = class({})

if IsServer() then
    function modifier_mordred_r_slash:OnCreated(args)
        local parent = self:GetParent()
        self.turnRate = (180 * FrameTime()) / 0.3
        self.turn = 0
        self.angles = parent:GetAngles()
        self.position = parent:GetAbsOrigin()
        self.rightVector = parent:GetRightVector()
        self.range = self:GetAbility():GetSpecialValueFor("side_range")
        self:StartIntervalThink(FrameTime())
    end

    function modifier_mordred_r_slash:OnIntervalThink()
        self.turn = self.turn + self.turnRate
        local angles = QAngle(self.angles.x, self.turn, self.angles.z)
        local endPos = self.position + RotatePosition(Vector(0,0,1), angles, self.rightVector) * self.range

        DebugDrawLine(self.position, endPos, 255, 0, 0, false, 1)
    end
end
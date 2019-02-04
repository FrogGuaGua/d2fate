---@class tamamo_foxs_wedding : CDOTA_Ability_Lua
tamamo_foxs_wedding = {}

function tamamo_foxs_wedding:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function tamamo_foxs_wedding:OnSpellStart()
    if IsValidEntity(self.thinker) then self.thinker:FindModifierByName("modifier_foxs_wedding_aura"):Destroy() end
    local caster = self:GetCaster()
    local team = caster:GetTeamNumber()
    local kv = { duration = self:GetSpecialValueFor("duration") }
    caster:EmitSound("Tamamo.Wedding.Cast")
    self.thinker = CreateModifierThinker(caster, self, "modifier_foxs_wedding_aura", kv, self:GetCursorPosition(), team, false)
end

LinkLuaModifier("modifier_foxs_wedding_aura", "abilities/tamamo/wedding", LUA_MODIFIER_MOTION_NONE)
---@class modifier_foxs_wedding_aura : CDOTA_Modifier_Lua
modifier_foxs_wedding_aura = {}

function modifier_foxs_wedding_aura:IsAura()
    return true
end

function modifier_foxs_wedding_aura:GetModifierAura()
    return "modifier_foxs_wedding"
end

function modifier_foxs_wedding_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_foxs_wedding_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_foxs_wedding_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_foxs_wedding_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

if IsServer() then
    function modifier_foxs_wedding_aura:OnCreated(args)
        self:GetParent():EmitSound("Tamamo.Wedding")
        self.pcf = ParticleManager:CreateParticle("particles/custom/tamamo/tamamo_wedding.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(self.pcf, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.pcf, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 0, 0))
    end

    function modifier_foxs_wedding_aura:OnDestroy()
        ParticleManager:DestroyParticle(self.pcf, false)
        ParticleManager:ReleaseParticleIndex(self.pcf)
        local parent = self:GetParent()
        parent:EmitSound("Tamamo.Wedding.End")
        self:GetParent():StopSound("Tamamo.Wedding")
        UTIL_Remove(self:GetParent())
    end
end

LinkLuaModifier("modifier_foxs_wedding", "abilities/tamamo/wedding", LUA_MODIFIER_MOTION_NONE)
---@class modifier_foxs_wedding : CDOTA_Modifier_Lua
modifier_foxs_wedding = {}
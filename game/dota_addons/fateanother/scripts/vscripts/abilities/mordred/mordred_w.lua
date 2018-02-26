---@class mordred_w : CDOTA_Ability_Lua
mordred_w = class({})

LinkLuaModifier("modifier_mordred_w", "abilities/mordred/modifier_mordred_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_w_dash", "abilities/mordred/mordred_w", LUA_MODIFIER_MOTION_NONE)

function mordred_w:OnSpellStart()
    local caster = self:GetCaster()
    local modifier = caster:FindModifierByName("modifier_mordred_w")
    modifier:UseStack()
    caster:AddNewModifier(caster, self, "modifier_mordred_w_dash", {duration = 0.25})
end

function mordred_w:OnUpgrade()
    local caster = self:GetCaster()
    ---@type modifier_mordred_w
    local modifier = caster:FindModifierByName("modifier_mordred_w")

    if not modifier then
        caster:AddNewModifier(caster, self, "modifier_mordred_w", {duration = -1})
    else
        modifier:RefreshStacks()
    end
end

if IsServer() then
    function mordred_w:CastFilterResult()
        if self:GetCaster():FindModifierByName("modifier_mordred_d"):GetMana() < self:GetManaCost(-1) then return UF_FAIL_CUSTOM end
        return UF_SUCCESS
    end

    function mordred_w:GetCustomCastError()
        return "#dota_hud_error_not_enough_mana"
    end
end

---@class modifier_mordred_w_dash : CDOTA_Modifier_Lua
modifier_mordred_w_dash = class({})

if IsServer() then
    function modifier_mordred_w_dash:OnCreated(args)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        self.direction = parent:GetForwardVector() * (ability:GetSpecialValueFor("range") / args.duration) * FrameTime()

        local dust = ParticleManager:CreateParticle("particles/dev/library/base_dust_hit.vpcf", PATTACH_ABSORIGIN, parent)
        ParticleManager:ReleaseParticleIndex(dust)
        self.pcf = ParticleManager:CreateParticle("particles/econ/items/storm_spirit/storm_spirit_orchid_hat/stormspirit_orchid_ball_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(self.pcf, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "", parent:GetAbsOrigin(), true)

        self:StartIntervalThink(FrameTime())
    end

    function modifier_mordred_w_dash:OnIntervalThink()
        local parent = self:GetParent()
        local to = GetGroundPosition(parent:GetAbsOrigin() + self.direction, parent)

        if not GridNav:IsTraversable(to) or GridNav:IsBlocked(to) then
            self:Destroy()
            return
        end

        parent:SetAbsOrigin(to)
    end

    function modifier_mordred_w_dash:OnDestroy()
        local parent = self:GetParent()
        FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
        ParticleManager:DestroyParticle(self.pcf, false)
        ParticleManager:ReleaseParticleIndex(self.pcf)
    end
end

function modifier_mordred_w_dash:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = IsServer()
    }
end

function modifier_mordred_w_dash:IsHidden()
    return true
end
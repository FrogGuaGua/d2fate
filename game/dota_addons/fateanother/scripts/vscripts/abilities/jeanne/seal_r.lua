---@class jeanne_seal_r : CDOTA_Ability_Lua
jeanne_seal_r = class({})
LinkLuaModifier("modifier_jeanne_force", "abilities/jeanne/seal_r", LUA_MODIFIER_MOTION_NONE)

function jeanne_seal_r:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    target:AddNewModifier(caster, self, "modifier_jeanne_force", {duration = 0.5})
    target:EmitSound("DOTA_Item.ForceStaff.Activate")
    local spellbook = caster:FindAbilityByName("jeanne_seal_spellbook")
    if spellbook then spellbook:OnSealCast() end
end

---@class modifier_jeanne_force : CDOTA_Modifier_Lua
modifier_jeanne_force = class({})

function modifier_jeanne_force:GetEffectName()
    return "particles/items_fx/force_staff.vpcf"
end

if IsServer() then
    function modifier_jeanne_force:CheckState()
        return { [MODIFIER_STATE_STUNNED] = true }
    end

    function modifier_jeanne_force:OnCreated(args)
        self.speed = self:GetAbility():GetSpecialValueFor("push_range") / self:GetDuration()
        self:StartIntervalThink(FrameTime())
    end

    function modifier_jeanne_force:OnIntervalThink()
        local parent = self:GetParent()
        local forward = parent:GetForwardVector()
        local nextPos = parent:GetAbsOrigin() + forward * self.speed * FrameTime()
        parent:SetAbsOrigin(GetGroundPosition(nextPos, parent))
    end

    function modifier_jeanne_force:OnDestroy()
        FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
    end
end
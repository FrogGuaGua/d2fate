---@class false_assassin_minds_eye : CDOTA_Ability_Lua
false_assassin_minds_eye = {}

function false_assassin_minds_eye:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    self.is_casting = true
    caster:PerformAttack(target, false, true, true, false, false, false, false)
    caster:EmitSound("fa_minds_eye_slash")
    self:SetActivated(false)
end

function false_assassin_minds_eye:GetCastRange(vLocation, hTarget)
    local caster = self:GetCaster()
    local range = caster:GetBaseAttackRange()
    local addrange = caster:GetAttackRangeBuffer()
    return range + addrange
end

function false_assassin_minds_eye:GetIntrinsicModifierName()
    return "modifier_fa_minds_eye"
end

LinkLuaModifier("modifier_fa_minds_eye", "abilities/fa/minds_eye", LUA_MODIFIER_MOTION_NONE)
---@class modifier_fa_minds_eye : CDOTA_Modifier_Lua
modifier_fa_minds_eye = {}

modifier_fa_minds_eye.IsHidden = function(self) return true end

function modifier_fa_minds_eye:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
    }
end

if IsServer() then
    function modifier_fa_minds_eye:OnCreated(args)
        self:GetAbility():SetActivated(false)
    end

    function modifier_fa_minds_eye:OnAbilityExecuted(args)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        if args.unit == parent and args.ability ~= ability then
            ability:SetActivated(true)
            parent:AddNewModifier(parent, ability, "modifier_fa_minds_eye_active", {duration = 3})
        end
    end

    function modifier_fa_minds_eye:GetModifierProcAttack_BonusDamage_Physical(args)
        local ability = self:GetAbility()
        local agi = self:GetCaster():GetAgility()
        if IsRevoked(args.target) then
            return ability:GetSpecialValueFor("agi_ratio_revoked") * agi
        else
            return ability:GetSpecialValueFor("agi_ratio") * agi
        end
    end
end

LinkLuaModifier("modifier_fa_minds_eye_active", "abilities/fa/minds_eye", LUA_MODIFIER_MOTION_NONE)
---@class modifier_fa_minds_eye_active : CDOTA_Modifier_Lua
modifier_fa_minds_eye_active = {}

function modifier_fa_minds_eye_active:DeclareFunctions()
    return { MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL }
end

if IsServer() then
    function modifier_fa_minds_eye_active:GetModifierProcAttack_BonusDamage_Physical()
        local ability = self:GetAbility()
        if ability.is_casting then
            return ability:GetSpecialValueFor("damage")
        else
            return 0
        end
    end

    function modifier_fa_minds_eye_active:OnDestroy()
        local ability = self:GetAbility()
        ability:SetActivated(false)
        ability.is_casting = false
    end
end
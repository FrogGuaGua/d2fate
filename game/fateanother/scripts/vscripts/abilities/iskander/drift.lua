---@class iskander_drift_toggle : CDOTA_Ability_Lua
iskander_drift_toggle = class({})

LinkLuaModifier("modifier_iskander_drift", "abilities/iskander/drift", LUA_MODIFIER_MOTION_NONE)

function iskander_drift_toggle:OnToggle()
end

function iskander_drift_toggle:GetIntrinsicModifierName()
    return "modifier_iskander_drift"
end

---@class modifier_iskander_drift : CDOTA_Modifier_Lua
modifier_iskander_drift = class({})
modifier_iskander_drift.IsHidden = function() return true end

if IsServer() then
    function modifier_iskander_drift:OnIntervalThink()
        local parent = self:GetParent()
        if self:GetAbility():GetToggleState() and not self:GetCaster():HasModifier("pause_sealdisabled") then
            local next = parent:GetAbsOrigin() + parent:GetForwardVector() * parent:GetIdealSpeed() * 0.03 
            FindClearSpaceForUnit(parent, next, true)
        end

        if not parent:HasModifier("modifier_gordius_wheel") then
            self:StartIntervalThink(-1)
        end
    end

    function modifier_iskander_drift:CheckState()
        return {
            [MODIFIER_STATE_ROOTED] = self:GetAbility():GetToggleState() and self:GetParent():HasModifier("modifier_gordius_wheel")
        }
    end

    function modifier_iskander_drift:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }
    end

    function modifier_iskander_drift:OnAbilityFullyCast(args)
        if args.ability == self:GetParent():FindAbilityByName("iskander_gordius_wheel") then
            self:StartIntervalThink(0.03)
        end
    end
end

LinkLuaModifier("modifier_sex_scroll_slow","items/modifiers/modifier_sex_scroll_slow", LUA_MODIFIER_MOTION_NONE)

---@class modifier_sex_scroll_root_delay : CDOTA_Modifier_Lua
modifier_sex_scroll_root_delay = class({})


if IsServer() then
    function modifier_sex_scroll_root_delay:OnDestroy()
        local ability = self:GetAbility()
        self:GetParent():AddNewModifier(self:GetCaster(), ability, "modifier_sex_scroll_root", {duration = ability:GetSpecialValueFor("lock_duration")})
    end
end

modifier_sex_scroll_root_delay.IsHidden = function() return true end


---@class modifier_sex_scroll_root : CDOTA_Modifier_Lua
modifier_sex_scroll_root = class({})

function modifier_sex_scroll_root:OnRefresh(args)
    self:IncrementStackCount()
    local duration = self:GetRemainingTime() + (self:GetAbility():GetSpecialValueFor("lock_duration") - (0.3 * self:GetStackCount()))
    duration = vlua.select(duration < 0.1, 0.1, duration)
    self:SetDuration(duration ,true)
end

function modifier_sex_scroll_root:GetEffectName()
    return "particles/generic_gameplay/generic_purge.vpcf"
end

function modifier_sex_scroll_root:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_sex_scroll_root:CheckState()   
    return {
        [MODIFIER_STATE_ROOTED] = true
    }
end

function modifier_sex_scroll_root:IsDebuff()
    return true
end
if IsServer() then
function modifier_sex_scroll_root:OnDestroy()
    local ability = self:GetAbility()
    self:GetParent():AddNewModifier(self:GetCaster(), ability, "modifier_sex_scroll_slow", {})
end

end


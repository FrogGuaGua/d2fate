---@class modifier_mordred_w : CDOTA_Modifier_Lua
modifier_mordred_w = class({})

function modifier_mordred_w:OnCreated(args)
    self.isRefreshable = true
    self:RefreshStacks()
end

function modifier_mordred_w:RefreshStacks()
    if self.isRefreshable then
        local ability = self:GetAbility()
        self:SetStackCount(ability:GetSpecialValueFor("dashes"))
    end
end


if IsServer() then
    function modifier_mordred_w:UseStack()
        local ability = self:GetAbility()
        if self:GetStackCount() == 1 then
            self:Destroy()
        else
            self:DecrementStackCount()
            self:SetDuration(5, true)
            ability:EndCooldown()
        end
    end

    function modifier_mordred_w:OnDestroy()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
        parent:AddNewModifier(parent, self:GetAbility(), "modifier_mordred_w", {duration = -1})
    end

    function modifier_mordred_w:DeclareFunctions()
        return {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        }
    end

    function modifier_mordred_w:GetModifierMoveSpeedBonus_Constant()
        return self:GetAbility():GetSpecialValueFor("movespeed")
    end

    function modifier_mordred_w:RemoveOnDeath()
        return false
    end
end
---@class modifier_mordred_q : CDOTA_Modifier_Lua
modifier_mordred_q = class({})

if IsServer() then
    function modifier_mordred_q:OnDestroy()
        local parent = self:GetParent()
        parent:SwapAbilities(parent:GetAbilityByIndex(0):GetAbilityName(), "mordred_q_1", false, true)
    end
end
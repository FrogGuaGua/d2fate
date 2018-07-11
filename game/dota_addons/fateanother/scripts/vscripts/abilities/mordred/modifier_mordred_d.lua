require('modifiers/modifier_custom_mana')

---@class modifier_mordred_d : modifier_custom_mana
modifier_mordred_d = class(modifier_custom_mana)

if IsServer() then
    function modifier_mordred_d:OnIntervalThink()
        if self:GetMana() == self:GetMaxMana() then return end
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local regen = 1
        local enemies = FindUnitsInRadius(parent:GetTeam(),
                                          parent:GetAbsOrigin(),
                                          nil,
                                          ability:GetSpecialValueFor("radius"),
                                          DOTA_UNIT_TARGET_TEAM_ENEMY,
                                          DOTA_UNIT_TARGET_HERO,
                                          0,
                                          FIND_ANY_ORDER,
                                          false)
        if not enemies[1] then regen = regen + ability:GetSpecialValueFor("regen_bonus") end
        if ability:IsChanneling() then regen = regen + ability:GetSpecialValueFor("active_regen") end
        --CustomNetTables:SetTableValue("sync", self.regenKey, {regen = regen});
        self:ModifyMana(self:GetMana() + regen * FrameTime())
    end
end
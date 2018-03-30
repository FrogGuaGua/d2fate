---@class jeanne_attribute_gods_resolution : CDOTA_Ability_Lua
jeanne_attribute_gods_resolution = class({})

function jeanne_attribute_gods_resolution:OnSpellStart()
    local caster = self:GetCaster()
    local hero = caster:GetPlayerOwner():GetAssignedHero()

    if not hero:HasAbility("jeanne_seal_spellbook") then
        hero:AddAbility("jeanne_seal_spellbook"):SetLevel(1)
        hero:UnHideAbilityToSlot("jeanne_seal_spellbook", "jeanne_magic_resistance_ex")
    end
end
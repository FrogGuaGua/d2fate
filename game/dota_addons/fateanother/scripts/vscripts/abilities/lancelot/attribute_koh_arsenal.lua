lancelot_attribute_improve_koh_arsenal = class({})

function lancelot_attribute_improve_koh_arsenal:OnSpellStart()
    local hCaster = self:GetCaster()
    local hHero = hCaster:GetPlayerOwner():GetAssignedHero()
    hHero.ArsenalAcquired = true

    local hMaster = hHero.MasterUnit
    hMaster:SetMana(hMaster:GetMana() - self:GetManaCost(1))

    if not hHero.ArsenalLevel then
        hHero.MasterUnit2:FindAbilityByName("lancelot_attribute_improve_knight_of_honor"):StartCooldown(9999)
        hHero:AddAbility("lancelot_knight_of_honor_arsenal"):SetLevel(hHero:FindAbilityByName("lancelot_knight_of_honor"):GetLevel())
        hHero:AddAbility("lancelot_knight_of_honor_arsenal_close"):SetLevel(1)
        hHero.ArsenalLevel = 1
        self:EndCooldown()
    else
        hHero.ArsenalLevel = 2
    end
end
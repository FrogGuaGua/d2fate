item_mana_essence = class({})
LinkLuaModifier("modifier_mana_essence", "items/modifier_mana_essence", LUA_MODIFIER_MOTION_NONE)

function item_mana_essence:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget() or hCaster
	local iCurrentCharges = self:GetCurrentCharges()
	
	local fDuration = self:GetSpecialValueFor("duration")
	local fHealthRegen = self:GetSpecialValueFor("health") / fDuration
	local fManaRegen = self:GetSpecialValueFor("mana") / fDuration
	
	hTarget:AddNewModifier(hCaster, self, "modifier_mana_essence", { Duration = fDuration, fHealthRegen = fHealthRegen, fManaRegen = fManaRegen })
	
	if iCurrentCharges == 1 then hCaster:RemoveItem(self) else self:SetCurrentCharges(iCurrentCharges - 1) end
end
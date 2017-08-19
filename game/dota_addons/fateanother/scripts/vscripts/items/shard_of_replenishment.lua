item_shard_of_replenishment = class({})
LinkLuaModifier("modifier_replenishment_heal", "items/modifier_replenishment_heal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_replenishment_armor", "items/modifier_replenishment_armor", LUA_MODIFIER_MOTION_NONE)

function item_shard_of_replenishment:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = hCaster
	local iCurrentCharges = self:GetCurrentCharges()
	
	local fDuration = self:GetSpecialValueFor("healduration")
	local fArmorDuration = self:GetSpecialValueFor("armorduration")

	hTarget:EmitSound("DOTA_Item.HealingSalve.Activate")
	hTarget:AddNewModifier(hCaster, self, "modifier_replenishment_armor", { Duration = fArmorDuration })
	hTarget:AddNewModifier(hCaster, self, "modifier_replenishment_heal", { Duration = fDuration })

	if iCurrentCharges == 1 then hCaster:TakeItem(self) else self:SetCurrentCharges(iCurrentCharges - 1) end
end
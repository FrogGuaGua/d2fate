item_blink_scroll = class({})

function item_blink_scroll:OnSpellStart()
	AbilityBlink(self:GetCaster(), self:GetCursorPosition(), self:GetSpecialValueFor("distance"))
end

function item_blink_scroll:IsResettable()
	return true
end

function item_blink_scroll:CastFilterResultLocation( vLocation )
	local hCaster = self:GetCaster()
	if IsClient() then require('libraries/util') end
	
	if IsLocked(hCaster) or hCaster:HasModifier("jump_pause_nosilence") or hCaster:HasModifier("modifier_story_for_someones_sake") then
		return UF_FAIL_CUSTOM
	end
	
	if hCaster:HasModifier("modifier_aestus_domus_aurea_lock") then
		local target = 0
		local targets = FindUnitsInRadius(hCaster:GetTeam(), hCaster:GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		for i=1, #targets do
			target = targets[i]
			if target:GetName() == "npc_dota_hero_lina" then
				break
			end
		end
		if not IsFacingUnit(hCaster, target, 90) then
			return UF_FAIL_CUSTOM
		end
	end
	
	return UF_SUCCESS
end

function item_blink_scroll:GetCustomCastErrorLocation( vLocation )
	return "#Cannot_Blink"
end
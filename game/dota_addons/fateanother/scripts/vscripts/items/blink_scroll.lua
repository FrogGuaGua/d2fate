item_blink_scroll = class({})

function item_blink_scroll:OnSpellStart()
	local hCaster = self:GetCaster()
	local vCursor = self:GetCursorPosition()
	local vDifference = vCursor - hCaster:GetAbsOrigin()
	local fMaxDistance = self:GetSpecialValueFor("distance")
	
	local vDirection = vDifference:Normalized()
	local fDistance = vDifference:Length()
	if fDistance >= fMaxDistance then fDistance = fMaxDistance end
	local vBlinkPos = hCaster:GetAbsOrigin() + (vDirection * fDistance)
	
	local i = 0
	local iStep = 10
	local iSteps = math.ceil(fDistance / iStep)
	
	while GridNav:IsTraversable( vBlinkPos ) ~= true do
		i = i + 1
		vBlinkPos = hCaster:GetAbsOrigin() + (vDirection * (fDistance - i * iStep))
		if i >= iSteps then break end
	end
	
	local pcBlinkStart = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pcBlinkStart, 0, hCaster:GetAbsOrigin())
	hCaster:EmitSound("Hero_Antimage.Blink_out")
	
	ProjectileManager:ProjectileDodge(hCaster)
	FindClearSpaceForUnit(hCaster, vBlinkPos, true)
	
	local pcBlinkEnd = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pcBlinkEnd, 0, hCaster:GetAbsOrigin())
	hCaster:EmitSound("Hero_Antimage.Blink_in")
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
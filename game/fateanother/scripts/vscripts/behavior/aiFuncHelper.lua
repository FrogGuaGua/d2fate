require "bit"
require('behavior/aiData')
local abilityData = GameRules.abilityData
local aiFuncHelper = {}
function _G.getAbilityData(unit)
	local hero_name = unit:GetName()
	return abilityData[hero_name]
end

function _G.getAbilityByVar(unit,var)
	print('getAbilityByVar',var)
	if tonumber(var) then
		var = tonumber(var)
	end

	if type(var) == 'number' then
		return unit:GetAbilityByIndex(var)
	else
		if var == nil then
			print('var == nil',debug.traceback())
			return
		end

		local ability = unit:FindAbilityByName(var)
		if ability == nil then
			local item = nil
			for i=0,5 do
				item = unit:GetItemInSlot(i)
				-- if item then
				-- 	print('getAbilityByVar ',i,item:GetName() ,'var', var)
				-- end
				if item and item:GetName() == var then
					ability = item
					break
				end
			end
		end

		return ability
	end
end

function _G.isAbilityValid(unit,ability)
	if ability == nil then return false end

	if ability:GetCooldownTime() > 0 then
		return false
	end

	if ability:GetManaCost(ability:GetLevel()) > unit:GetMana() then
		return false
	end

	return true
end

function _G.aiCastAbility(unit,target,ability)
	
	local behavior = ability:GetBehavior()
	local targetPos = target:GetAbsOrigin()
	
	if bit.band(behavior,DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
		local selfPos = unit:GetAbsOrigin()
		local vec = targetPos - selfPos
		local castRange = ability:GetCastRange(target:GetAbsOrigin(),target)
		if #vec > castRange then
			vec = vec:Normalized()
			targetPos = selfPos + vec * castRange
		end

		print('cast ',ability:GetName())
		unit:CastAbilityOnPosition(targetPos, ability, -1)
	elseif bit.band(behavior,DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
		print('cast ',ability:GetName(),'target ',target)
		unit:CastAbilityOnTarget(target, ability, -1)
	--hero:CastAbilityOnTarget(target, getAbilityByVar(hero,'item_s_scroll_ai'), -1)

	else
		ability:CastAbility()
		--print('no cast ',ability:GetName())
	end
	local delay = getAbilityDelay(unit,targetPos,ability)
	unit.nextskill = Time() + delay
	return false
end

function _G.getAbilityDelay(unit,targetPos,ability)
	local behavior = ability:GetBehavior()
	local castPoint = ability:GetCastPoint()
	local rate = 720
	local selfPos = unit:GetAbsOrigin()
	local forward = unit:GetForwardVector()
	local vec = (targetPos-selfPos):Normalized()
	local fDiff = VectorToAngles(vec)[2] - VectorToAngles(forward)[2]
	fDiff = math.abs(fDiff)
	print('fDiff',fDiff)
	local rateTime = fDiff/rate
	if rateTime < 0.1 then
		rateTime = 0.1
	end
	print('rateTime ',rateTime)
	if bit.band(behavior,DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
		return castPoint + rateTime + 0.2
	elseif bit.band(behavior,DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
		print('cast ',ability:GetName())
	--hero:CastAbilityOnTarget(target, getAbilityByVar(hero,'item_s_scroll_ai'), -1)
		return castPoint + rateTime + 0.2
	else
		ability:CastAbility()
		return castPoint + 0.2
		--print('no cast ',ability:GetName())
	end
end

function _G.isValidCastAbility(unit)
	if unit:IsPhased() then return false end
	for id=0,12 do
		local ability = unit:GetAbilityByIndex(id)
		if ability and ability:IsChanneling() then
			print(id,ability:GetName(),'ischanneling')
			return false
		end
	end

	for id=0,5 do
		local ability = unit:GetItemInSlot(id)
		if ability and ability:IsChanneling() then
			print(id,ability:GetName(),'ischanneling')
			return false
		end
	end

	return true
end
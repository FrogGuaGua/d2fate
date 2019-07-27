require "bit"
require('behavior/aiData')
local abilityData = GameRules.abilityData
local aiFuncHelper = {}
function _G.getAbilityData(unit)
	local hero_name = unit:GetName()
	return abilityData[hero_name]
end

function _G.getAbilityByVar(unit,var)
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
				if item then
					print('getAbilityByVar ',i,item:GetName() ,'var', var)
				end
				if item and item:GetName() == var then
					ability = item
					break
				end
			end
		end

		return ability
	end
end

function _G.getComboByIdx(unit,idx)
	local data = getAbilityData(unit)
	local Combos = data.Combos
	return Combos[idx]
end

function _G.isComboValid(unit,idx)
	local data = getAbilityData(unit)
	local Combos = data.Combos
	local ComboAbilitys = Combos[idx].abilitys
	for _ , ability_name in ipairs(ComboAbilitys) do
		local ability = getAbilityByVar(unit,ability_name)
		if ability == nil or ability:GetCooldownTime() > 0 then
			return false
		end
	end

	return true
end

function _G.getComboRangeByIdx(unit,idx)
	local abilityData = getAbilityData(unit)
	if abilityData == nil then return 0 end
	local Combos = abilityData.Combos
	
	local ComboRangeData = Combos[idx].range
	local dist = 0
	for ability_name , data in pairs(ComboRangeData) do
		local ability = getAbilityByVar(unit,ability_name)
		if ability ~= nil then
			print('getComboRangeByIdx ',ability_name)
			dist = dist + ability:GetCastRange()*data.rate
		end
	end
	return dist
end

function _G.getDashRange(unit)
	local abilityData = getAbilityData(unit)
	if abilityData == nil then return 0 end
	local dashAbilitys = abilityData.DashAbilitys

end

function _G.getValidComboByRange(unit,range)
	local abilityData = getAbilityData(unit)
	if abilityData == nil then return 0 end

	local Combos = abilityData.Combos
	for comboID , combo_data in ipairs(Combos) do
		local isvalid = isComboValid(unit,comboID)
		print('isvalid ',isvalid)
		if isvalid then
			local comboRange = getComboRangeByIdx(unit,comboID) 
			print('comboRange ',comboRange , 'range ',range)
			if comboRange > range then
				return comboID
			end


		end
	end
	return -1 
end

function _G.getValidFightAbilityByRange(unit,range)
	local abilityData = getAbilityData(unit)
	if abilityData == nil then return end

	local fightAbilitys = abilityData.FightAbilitys
	for _ , var in ipairs(fightAbilitys) do
		local ability = getAbilityByVar(unit,var)
		if ability and ability:GetCooldownTime() <= 0 then
			if ability:GetCastRange() > range then
				print('ability',ability:GetName() , ability:GetCastRange())
				return ability
			end
		end
	end	

	return
end

function _G.aiCastAbility(unit,target,ability)
	
	local behavior = ability:GetBehavior()
	if bit.band(behavior,DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
		print('cast ',ability:GetName())
		unit:CastAbilityOnPosition(target:GetAbsOrigin(), ability, -1)
	elseif bit.band(behavior,DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
		print('cast ',ability:GetName(),'target ',target)
		unit:CastAbilityOnTarget(target, ability, -1)
	--hero:CastAbilityOnTarget(target, getAbilityByVar(hero,'item_s_scroll_ai'), -1)

	else
		ability:CastAbility()
		--print('no cast ',ability:GetName())
	end

	local delay = getAbilityDelay(ability)
	unit.nextskill = Time() + delay
	return false
end

function _G.getAbilityDelay(ability)
	local behavior = ability:GetBehavior()
	local castPoint = ability:GetCastPoint()
	if bit.band(behavior,DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
		return castPoint + 0.5
	elseif bit.band(behavior,DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
		print('cast ',ability:GetName(),'target ',target)
	--hero:CastAbilityOnTarget(target, getAbilityByVar(hero,'item_s_scroll_ai'), -1)
		return castPoint + 0.5
	else
		ability:CastAbility()
		return castPoint + 0.1
		--print('no cast ',ability:GetName())
	end
end
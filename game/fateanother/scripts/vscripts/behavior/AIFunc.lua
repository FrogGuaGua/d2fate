require('behavior/aiFuncHelper')
local AIFunc = {}

AIFunc.IsDead = function(unit,target_type)
	local target = unit
	if target_type == '1' then
		target = unit:GetAggroTarget()
	end
	print('--ISDead')
	if target then
		return not target:IsAlive()
	end

	return false
end

AIFunc.MoveTo = function(unit,args)
	if not isValidCastAbility(unit) then return false end
	local target = AIFunc.GetTarget(unit,args[1])
	print(string.format('unit %s MoveTo %s %s',unit:GetName(),args[1],target))
	if target ==nil then return false end
	local selfTeam = unit:GetTeam()
	local targetTeam = target:GetTeam()

	if selfTeam ~= targetTeam then
		unit:MoveToTargetToAttack(target)
	else
		unit:MoveToNPC(target)
	end
end

AIFunc.Distance = function(unit,args)
	local target = AIFunc.GetTarget(unit,args[1])
	if target == nil then return false end
	print('Distance ',args[1],args[2],target)
	local selfPos = unit:GetAbsOrigin()
	local targetPos = target:GetAbsOrigin()
	return #(selfPos - targetPos) < tonumber(args[2]) 
end

local function getNearestTeamMatePlayer(unit)
	local heroList = HeroList:GetAllHeroes()
	local selfTeam = unit:GetTeam()
	local nearestHero = nil
	local minDist = 100000
	local selfPos = unit:GetAbsOrigin()

	for _ , hero in pairs(heroList) do
        if hero:GetTeam() == selfTeam then
        	if hero:GetPlayerID() >= 0 then
        		local targetPos = hero:GetAbsOrigin()
        		local dist = #(targetPos-selfPos) 
        		if dist < minDist then
        			minDist = dist
        			nearestHero = hero
        		end
        	end
        end
	end

	return nearestHero
end

AIFunc.GetTarget = function(unit,targetType)
	if targetType == 'combo' then
		if unit.ComboData == nil then return nil end
		return unit.ComboData.target
	elseif targetType == 'move' then
		return unit.moveTarget
	elseif targetType == 'near_player' then
		return getNearestTeamMatePlayer(unit)
	end
	return nil
end
AIFunc.HasTarget = function(unit,args)
	local target = AIFunc.GetTarget(unit,args[1])
	if target == nil or not target:IsAlive() then return false end

	if args[2] and tonumber(args[2]) then
		local dist = tonumber(args[2]) 
		local targetPos = target:GetAbsOrigin()
		local selfPos = unit:GetAbsOrigin()
		return #(targetPos-selfPos) < dist
	end
	return true
end

AIFunc.Combo = function(unit)
	if not isValidCastAbility(unit) then return true end
	if not unit.ComboData or unit.nextskill > Time() then return true end

	local ComboData = unit.ComboData
	if ComboData == nil then return false end
	local target = ComboData.target
	local step = ComboData.step
	local abilityVars = ComboData.abilityVars
	print('target ',target,'unit',unit)
	print('step ',step , abilityVars[step])
	if abilityVars[step] == nil then
		unit.ComboData = nil
	else
		aiCastAbility(unit,target,getAbilityByVar(unit,abilityVars[step]))
	end

    ComboData.step = step + 1
    if abilityVars[ComboData.step] == nil then
    	unit.ComboData = nil
    end
	return true
end

AIFunc.ClearAllData= function(unit)
	unit.moveTarget =nil
	unit.ComboData = nil
	unit.castTarget = nil
	unit.nextskill = 0
end

AIFunc.onEntityDead = function(unit,target)
	if unit.ComboData then
		print('unit.ComboData.target ',unit.ComboData.target)
		print('target ',target)
		if unit.ComboData.target == target then
			print('---ComboData=nil')
			unit.ComboData = nil
		end
	end
	if unit.moveTarget == target then
		print('---moveTarget=nil')
		unit.moveTarget =nil
	end
end

local function getComboTargetData(unit,args)
	local ComboDatas = {}
	local range = 0
	local abilityVars = {}
	for _ , arg in ipairs(args) do
		if #arg ~= 0 then
			local data = string.split(arg,'*')
			if #data == 2 then 
				data[2] = tonumber(data[2]) 
			end
			local ability = getAbilityByVar(unit,data[1])

			local valid = isAbilityValid(unit,ability)

			if not valid and data[3] ~= 'i' then
				return ComboDatas
			end

			if valid then
				table.insert(abilityVars,data[1])
				if ability and data[2] then
					local ability_range = ability:GetCastRange(unit:GetAbsOrigin() ,unit)
					print(data[1],'ability_range ',ability_range)
					range = range + ability_range * data[2]
				end
			end
		end
	end
	print('getComboTargetData->>')
	for _ , var in ipairs(abilityVars) do
		print(_,var)
	end
	print('getComboTargetData-<<')

	local selfPos = unit:GetAbsOrigin()
	local selfTeam = unit:GetTeam()

	local heroList = HeroList:GetAllHeroes()
	for _ , hero in pairs(heroList) do
        if hero:GetTeam() ~= selfTeam then
        	local targetPos = hero:GetAbsOrigin()
        	local dist = #(targetPos - selfPos)
        	if dist < range then
        		table.insert(ComboDatas,{target = hero,step=1,abilityVars = abilityVars})
        	end
        end
	end

	return ComboDatas
end
AIFunc.SetComboTarget = function(unit,args)
	local ComboDatas = getComboTargetData(unit,args)
	if #ComboDatas > 0 then
		local minHPData = ComboDatas[1]
		local minHP = minHPData.target:GetHealth()
		for _ , data in ipairs(ComboDatas) do
			local hp = data.target:GetHealth()
			if minHP > hp then
				minHPData = data
				minHP = hp
			end
		end

		unit.ComboData = minHPData
		return true
	end
	return false
end

AIFunc.CheckComboRange = function(unit,args)
	local ComboDatas = getComboTargetData(unit,args)
	return #ComboDatas > 0
end

AIFunc.ClearData = function(unit,args)
	local dType = args[1]
	if dType == 'combo' then
		unit.ComboData = nil
	end
end

AIFunc.CastAbility = function(unit,args)
	--print('CastAbility',args[1])
	local ability = getAbilityByVar(unit,args[1])
	if ability == nil then
		return false
	end
	ability:CastAbility()
	return true
end

AIFunc.HpCmp = function(unit,args)
	local minHp = tonumber(args[1])/100
	local maxHp = tonumber(args[2])/100
	local selfHp = unit:GetHealth() / unit:GetMaxHealth()

	return selfHp>minHp and selfHp < maxHp
end

AIFunc.ManaCmp = function(unit,args)
	local minMana = tonumber(args[1])/100
	local maxMana = tonumber(args[2])/100
	local selfMana = unit:GetMana()/ unit:GetMaxMana()

	return minMana < selfMana and maxMana > selfMana
end

AIFunc.HasModifier = function(unit,args)
	local modName = args[1]
	for _ ,modName in ipairs(args) do
		if #modName > 0 then
			local mod = unit:FindModifierByName(modName)
			if mod == nil then
				return false
			end
		end
	end

	return true
end

GameRules.AIFunc = AIFunc
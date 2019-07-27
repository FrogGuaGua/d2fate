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
	if unit:IsPhased() then return false end
	local target = AIFunc.GetTarget(unit,args[1])
	print(string.format('MoveTo %s %s',args[1],target))
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

	local selfPos = unit:GetAbsOrigin()
	local targetPos = target:GetAbsOrigin()
	return #(selfPos - targetPos) < tonumber(args[2]) 
end

AIFunc.SetComboTarget = function(unit)
	print('SetComboTarget')

	local comboTargets = {}

	local selfTeam = unit:GetTeam();
	local selfPos = unit:GetAbsOrigin()
	print('selfTeam ',selfTeam)

	local heroList = HeroList:GetAllHeroes()
	for _ , hero in pairs(heroList) do
		print('hero:GetTeam() ',hero:GetTeam())
        if hero:GetTeam() ~= selfTeam then
        	local targetPos = hero:GetAbsOrigin()
        	local dist = #(targetPos - selfPos)
        	local comboID = getValidComboByRange(unit,dist)
        	print('getValidComboByRange ',comboID ,dist)
        	if comboID > 0 then
        		table.insert(comboTargets,{target = hero , comboID = comboID , step = 1})
        	end
        end
	end

	if #comboTargets == 0 then 
	 	unit.ComboData = nil
	 	return false 
	end

	local r = math.random(1,#comboTargets)
	unit.ComboData = comboTargets[r]
	return true
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
		return unit.ComboData
	elseif targetType == 'move' then
		return unit.moveTarget
	elseif targetType == 'near_player' then
		return getNearestTeamMatePlayer(unit)
	end
	return nil
end
AIFunc.HasTarget = function(unit,args)
	local rst = AIFunc.GetTarget(unit,args[1]) ~= nil
	print('AIFunc.HasTarget ',args[1],rst)
	return rst
end

AIFunc.Combo = function(unit)
	if unit:IsPhased() then return true end
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

    ComboData.step = ComboData.step + 1
    if abilityVars[ComboData.step] == nil then
    	unit.ComboData = nil
    end
	return true
end

AIFunc.ClearAllData= function(unit)
	unit.moveTarget =nil
	unit.ComboData = nil
	unit.castTarget = nil
	unit.waitcastskill = false
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
	if unit.castTarget == target then
		print('---castTarget=nil')
		unit.castTarget = nil
		unit.waitcastskill = false
	end
end
AIFunc.CheckComboValid = function(unit,args)
	local mana = 0
	for _ , arg in ipairs(args) do
		local ability = getAbilityByVar(unit,arg)
		if ability == nil or ability:GetCooldownTime() > 0 then
			return false
		end
		if ability then
			mana = mana + ability:GetManaCost(ability:GetLevel())
		end
	end

	return unit:GetMana() > mana
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
			table.insert(abilityVars,data[1])
			local ability = getAbilityByVar(unit,data[1])
			if ability and data[2] then
				range = range + ability:GetCastRange() * data[2]
			end
		end
	end
	if not AIFunc.CheckComboValid(unit,abilityVars) then
		return ComboDatas
	end

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
		local r = math.random(1,#ComboDatas)
		unit.ComboData = ComboDatas[r]
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
	local ability = getAbilityByVar(args[1])
	if ability == nil then
		return false
	end

	ability:CastAbility()
	return true
end

GameRules.AIFunc = AIFunc
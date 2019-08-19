require "bit"
LogOpen.BaseAIClass_Combo = false
local function dp(...)
	if LogOpen.BaseAIClass_Combo then
		print(string.format(...))
	end
end

function BaseAIClass:isValidCastAbility()
	local unit = self.unit
	local nextskill = self.nextskill
	if unit:IsPhased() then return false end
	if nextskill > Time() then return false end

	for id=0,12 do
		local ability = unit:GetAbilityByIndex(id)
		if ability and ability:IsChanneling() then
			dp('isValidCastAbility | %s %s ischanneling',id,ability:GetName())
			return false
		end
	end

	for id=0,5 do
		local ability = unit:GetItemInSlot(id)
		if ability and ability:IsChanneling() then
			dp('isValidCastAbility | %s %s ischanneling',id,ability:GetName())
			return false
		end
	end

	return true
end

function BaseAIClass:getAbilityByName(name)
	local unit = self.unit
	local ability = unit:FindAbilityByName(name)
	if ability == nil then
		local item = nil
		for i=0,5 do
			item = unit:GetItemInSlot(i)
			if item and item:GetName() == name then
				ability = item
				break
			end
		end
	end

	return ability
end

function BaseAIClass:isAbilityValid(ability,combo)
	local unit = self.unit

	if ability == nil then 
		dp('isAbilityValid | ability == nil')
		return false
	end
	if ability:GetCooldownTime() > 0 then
		dp('isAbilityValid | CD %s %s',ability:GetName(),ability:GetCooldownTime())
		return false
	end

	if ability:GetManaCost(ability:GetLevel()) > unit:GetMana() then
		dp('isAbilityValid | MANA %s %s',ability:GetName(),ability:GetCooldownTime())
		return false
	end

	local abilityName = ability:GetName()

	-- if not self:IsHideAbility(ability) and ability:IsHidden() then
	-- 	return false
	-- end

	if  ability:IsHidden() then
		dp('isAbilityValid | IsHidden %s %s',ability:GetName(),ability:GetCooldownTime())
		return false
	end

	if not ability:IsActivated() then
		dp('isAbilityValid | IsActivated %s %s',ability:GetName(),ability:GetCooldownTime())
		return false
	end
	local special_ability_condition = self.special_ability_condition
	local conditionFunc = special_ability_condition[abilityName]
	if conditionFunc and not conditionFunc(self) then
		return false
	end

	if combo then
		local name = ability:GetName()
		local combo_data = self.combo_abilitys[name]
		if combo_data then
			local ability_queue = self.ability_queue

			local abilitys = combo_data.abilitys
			local combo_time = combo_data.time

			if #ability_queue >= #abilitys then
				local idx = 1
				for i=#abilitys , 1 , -1 do
					local ability_name = abilitys[i]
					dp('isAbilityValid | %s %s',ability_name,ability_queue[idx].name)
					if ability_name ~= ability_queue[idx].name then
						return false
					end
					idx = idx + 1
				end
				local interval = Time() - ability_queue[#abilitys].time
				dp('isAbilityValid | interval %s',interval)
				if interval > combo_time then
					return false
				end
			else
				return false
			end

		end
	end

	dp('isAbilityValid | true %s',ability:GetName())
	return true
end

function BaseAIClass:aiCastAbilityByName(target,ability_name)
	local unit = self.unit
	local ability = unit:FindAbilityByName(ability_name)
	self:aiCastAbility(target,ability)
end

local PointFlag = 0
PointFlag = bit.bor(PointFlag,DOTA_ABILITY_BEHAVIOR_POINT)
PointFlag = bit.bor(PointFlag,DOTA_ABILITY_BEHAVIOR_AOE)
PointFlag = bit.bor(PointFlag,DOTA_ABILITY_BEHAVIOR_DIRECTIONAL)

function BaseAIClass:getAbilityBehavior(abilityName)
	return self.abilitys_behavior[abilityName] or self.items_behavior[abilityName]
end

function BaseAIClass:aiCastAbility(target,ability,castPos)
	if ability == nil then return end

	if not self:isValidCastAbility() then
		return false
	end

	if self.refreshCD == nil then
		self.refreshCD = self.secondRefreshCD
		self.nextRefreshTime = Time() + self.firstRefreshCD
	end
	local abilityName = ability:GetName()
	local unit = self.unit
	local behavior = self:getAbilityBehavior(abilityName)
	if target == nil then target = unit end
	local targetPos = target:GetAbsOrigin()
	dp("aiCastAbility | %s %s",abilityName,behavior)

	if behavior == 'target' then
		dp('aiCastAbility | target %s %s',ability:GetName(),target:GetName())
		unit:CastAbilityOnTarget(target, ability, -1)
	elseif behavior == 'pos' then
		local selfPos = unit:GetAbsOrigin()
		if castPos == nil then
			local vec = targetPos - selfPos
			local castRange = ability:GetCastRange(target:GetAbsOrigin(),target)*0.95
			if #vec > castRange then
				vec = vec:Normalized()
				targetPos = selfPos + vec * castRange
			end
			dp('aiCastAbility | pos %s %s',ability:GetName(),castRange)
		else
			targetPos = castPos
		end
		
		unit:CastAbilityOnPosition(targetPos, ability, -1)
	elseif behavior == 'back_pos' then
		local selfPos = unit:GetAbsOrigin()
		if castPos == nil then
			local vec = targetPos - selfPos
			local castRange = ability:GetCastRange(target:GetAbsOrigin(),target)*0.95
			if #vec < 10 then
				vec = Vector(1,0,0)
			else
				vec = -vec:Normalized()
			end
			targetPos = selfPos+vec*castRange
			dp('aiCastAbility | back_pos %s %s',ability:GetName(),castRange)
		else
			targetPos = castPos
		end
		
		unit:CastAbilityOnPosition(targetPos, ability, -1)
	elseif behavior == 'toggle' then
		ability:ToggleAbility()
		dp('ToggleAbility | toggle %s',ability:GetName())
	else
		unit:CastAbilityNoTarget(ability,-1)
		--print('no cast ',ability:GetName())
	end
	local delay = self:getAbilityDelay(targetPos,ability)
	self.nextskill = Time() + delay
	dp('aiCastAbility | %s %s %s',abilityName,Time(),delay)
	if #self.ability_queue == 10 then
		table.remove(self.ability_queue,10)
	end
	table.insert(self.ability_queue,1,{time = Time() , name = ability:GetName()})
	return false
end

function BaseAIClass:getAbilityDelay(targetPos,ability)
	local unit = self.unit
	local behavior = ability:GetBehavior()
	local castPoint = ability:GetCastPoint()
	local rate = 720
	local selfPos = unit:GetAbsOrigin()
	local forward = unit:GetForwardVector()
	local vec = (targetPos-selfPos):Normalized()
	local fDiff = VectorToAngles(vec)[2] - VectorToAngles(forward)[2]
	fDiff = math.abs(fDiff)
	local rateTime = fDiff/rate
	if rateTime < 0.1 then
		rateTime = 0.1
	end
	local behavior = self:getAbilityBehavior(ability:GetName())

	if behavior == 'target' then
		return castPoint + rateTime+0.1
	elseif behavior == 'pos'then
		return castPoint + rateTime+0.1
	else
		return castPoint + 0.1
	end
end

--最近的友放玩家
function BaseAIClass:FindNearestPlayer()
	local heroList = HeroList:GetAllHeroes()
	local unit = self.unit
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

--最近的敌人
function BaseAIClass:FindNearestEnemy(needSee)
	local unit = self.unit
	local selfTeam = unit:GetTeam()
	local selfPos = unit:GetAbsOrigin()
	local range = self:GetSearchRange()
	local target = nil
	local minDist = 1000000
	local tb =FindUnitsInRadius(selfTeam,selfPos,nil,range,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,0,false)
	for _ , _target in ipairs(tb) do
		if self:ValidTarget(_target) then
			if not needSee or unit:CanEntityBeSeenByMyTeam(_target) then
				local targetPos = _target:GetAbsOrigin()
	        	local dist = #(targetPos - selfPos)
	        	if dist < range and dist < minDist then
	        		target = _target
	        		minDist = dist
	        	end
			end
		end
	end

	return target
end

function BaseAIClass:IsHideAbility(ability)
	local name = ability:GetName()
	local hide_ability_names = self.hide_ability_names

	for _ , hname in ipairs(hide_hide_ability_namesabilitys) do
		if hname == name then
			return true
		end
	end

	return false
end
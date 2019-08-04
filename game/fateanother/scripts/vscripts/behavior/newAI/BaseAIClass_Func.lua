require "bit"

function BaseAIClass:isValidCastAbility()
	local unit = self.unit
	local nextskill = self.nextskill
	if unit:IsPhased() then return false end
	if nextskill > Time() then return false end

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

	if ability == nil then return false end
	print("CD isAbilityValid ",ability:GetName(),ability:GetCooldownTime())
	if ability:GetCooldownTime() > 0 then
		return false
	end

	if ability:GetManaCost(ability:GetLevel()) > unit:GetMana() then
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
					print('isAbilityValid ',ability_name,ability_queue[idx].name)
					if ability_name ~= ability_queue[idx].name then
						return false
					end
					idx = idx + 1
				end
				local interval = Time() - ability_queue[#abilitys].time
				print('isAbilityValid interval ',interval)
				if interval > combo_time then
					return false
				end
			else
				return false
			end

		end
	end
	print("CD isAbilityValid true",ability:GetName(),ability:GetCooldownTime())
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

function BaseAIClass:aiCastAbility(target,ability)
	if ability == nil then return end

	if not self:isValidCastAbility() then
		return false
	end
	print("aiCastAbility",ability:GetName())
	local unit = self.unit
	local behavior = ability:GetBehavior()
	local targetPos = target:GetAbsOrigin()
	if bit.band(behavior,DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
		print('cast ',ability:GetName(),'target ',target)
		unit:CastAbilityOnTarget(target, ability, -1)
	elseif bit.band(behavior,PointFlag) ~= 0 then
		local selfPos = unit:GetAbsOrigin()
		local vec = targetPos - selfPos
		local castRange = ability:GetCastRange(target:GetAbsOrigin(),target)*0.95
		if #vec > castRange then
			vec = vec:Normalized()
			targetPos = selfPos + vec * castRange
		end
		print('cast ',ability:GetName(),'castRange',castRange)
		unit:CastAbilityOnPosition(targetPos, ability, -1)
	elseif ability:IsToggle() then
		ability:ToggleAbility()
		print('ToggleAbility',ability:GetName())
	else
		ability:CastAbility()
		--print('no cast ',ability:GetName())
	end
	print('behavior ',behavior)
	local delay = self:getAbilityDelay(targetPos,ability)
	self.nextskill = Time() + delay

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
	print('fDiff',fDiff)
	local rateTime = fDiff/rate
	if rateTime < 0.1 then
		rateTime = 0.1
	end
	print('rateTime ',rateTime)
	if bit.band(behavior,DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
		print('cast ',ability:GetName())
		return castPoint + rateTime+0.2
	elseif bit.band(behavior,PointFlag) ~= 0 then
		return castPoint + rateTime+0.2
	else
		return castPoint + 0.2
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
function BaseAIClass:FindNearestEnemy()
	local unit = self.unit
	local selfTeam = unit:GetTeam()
	local selfPos = unit:GetAbsOrigin()
	local target = nil
	local minDist = 1000000

	local heroList = HeroList:GetAllHeroes()
	for _ , hero in pairs(heroList) do
        if hero:GetTeam() ~= selfTeam then
        	local targetPos = hero:GetAbsOrigin()
        	local dist = #(targetPos - selfPos)
        	print("dist",dist,'self.searchRange',self.searchRange)
        	if dist < self.searchRange and dist < minDist then
        		target = hero
        		minDist = dist
        	end
        end
	end

	return target
end
--是否解锁隐藏技能
function BaseAIClass:is_hide_unlock()
	local unit = self.unit
	local hide_condition = self.hide_condition
	for atb_name , min in pairs(hide_condition) do
		local atb = nil
		if atb_name == 'agiltity' then
			atb = unit:GetAgility()
		elseif atb_name == 'strength' then
			atb = unit:GetStrength()
		elseif atb_name == 'intellect' then
			atb = unit:GetIntellect()
		end
		if atb < min then
			return false
		end
	end

	return true
end

--是否可以使用隐藏技能
function BaseAIClass:can_use_hide()
	--有隐藏状态说明可以使用隐藏技能
	local unit = self.unit
	local hide_modifier = self.hide_modifier
	return unit:FindModifierByName(hide_modifier) ~= nil
end

--检查combo是否可用
function BaseAIClass:check_combo_valid(hide,index)
	local unit = self.unit
	local combos = hide and self.hide_combos or self.combos
	local combo = combos[index]
	for idx , data in ipairs(combo) do
		local ability_name = data[1]
		local ability = self:getAbilityByName(ability_name)
		print('ability_name',ability_name,'ability',ability)
		if not self:isAbilityValid(ability) then
			return false
		end
	end
	return true
end

function BaseAIClass:get_ability_range(ability_name)
	local unit =  self.unit
	local ability = unit:FindAbilityByName(ability_name)
	if ability then
		return  ability:GetCastRange(unit:GetAbsOrigin() ,unit)
	end
	return 0
end

--检查combo范围是否合适
function BaseAIClass:get_combo_range(hide,index)
	local unit =  self.unit
	local combos = hide and self.hide_combos or self.combos
	local combo = combos[index]
	local dist = 0
	for idx , data in ipairs(combo) do
		if #data > 1 then
			local ability_name = data[1]
			if data[2] < 1.001 then
				local range = self:get_ability_range(ability_name)
				local rate = data[2]
				dist = dist + rate*range
			else
				dist = dist + data[2]
			end
		end
	end

	return dist
end

--获取适合combo的目标
function BaseAIClass:get_best_combo_targets(hide,index)
	local targets = {}
	local combo = hide and self.hide_combos or self.combos
	if not self:check_combo_valid(hide,index) then
		return targets
	end

	local range = self:get_combo_range(hide,index)
	local unit = self.unit
	local selfPos = unit:GetAbsOrigin()
	local selfTeam = unit:GetTeam()

	local heroList = HeroList:GetAllHeroes()
	for _ , hero in pairs(heroList) do
        if hero:GetTeam() ~= selfTeam and self:IsValidComboTarget(hero) then
        	local targetPos = hero:GetAbsOrigin()
        	local dist = #(targetPos - selfPos)
        	if dist < range then
        		table.insert(targets,hero)
        	end
        end
	end
	return targets
end

--选择一个combo和combo目标
function BaseAIClass:SelectComboAndTarget()
	local unit = self.unit
	local hide_combos = self.hide_combos
	local combos = self.combos
	local targets = {}
	local combo = nil

	repeat
		if self:is_hide_unlock() then
			for i=1 , #hide_combos do
				targets = self:get_best_combo_targets(true,i)
				if #targets > 0 then
					combo = hide_combos[i]
					print('SelectComboAndTarget hide_combos',i)
					break
				end
			end
		end

		if combo then break end

		for i=1 , #combos do
			targets = self:get_best_combo_targets(false,i)
			if #targets > 0 then
				combo = combos[i]
				print('SelectComboAndTarget combos',i)
				break
			end
		end
	until (true)
	
	if #targets == 0 then
		return false
	end

	local minHPTarget = targets[1]
	local minHP = targets[1]:GetHealth()
	for _ , target in ipairs(targets) do
		local hp = target:GetHealth()
		if minHP > hp then
			minHPTarget = target
			minHP = hp
		end
	end
	self.curCombo = {target = minHPTarget , combo = combo , step = 1}

	return true
end

function BaseAIClass:NextCurCombo()
	local curCombo = self.curCombo
	local combo = curCombo.combo
	curCombo.step = curCombo.step + 1
	if combo[curCombo.step] == nil then
		self:ClearCurCombo()
		return false
	end
	return true
end

function BaseAIClass:ClearCurCombo()
	self.curCombo = {target = nil , combo = nil , step = 0}
end

function BaseAIClass:HasComboTarget()
	return self.curCombo.target ~= nil
end

function BaseAIClass:GetComboTarget()
	return self.curCombo.target
end

function BaseAIClass:IsValidComboTarget(target)
	if target == nil or not target:IsAlive() then
		return false
	end

	return true
end

function BaseAIClass:DoCombo()
	if not self:HasComboTarget() then
		return false
	end

	local unit = self.unit

	if not self:isValidCastAbility() then
		return false 
	end

	local curCombo = self.curCombo
	local target = curCombo.target
	local combo = curCombo.combo
	local step = curCombo.step

	if not self:IsValidComboTarget(target) then
		self:ClearCurCombo()
		return false
	end
	
	local ability_name = combo[step][1]
	local check = combo[step][3]
	print('DoCombo ',step,ability_name)

	if check then
		local range = self:get_ability_range(ability_name)
		local selfPos = self.unit:GetAbsOrigin()
		local targetPos = target:GetAbsOrigin()
    	local dist = #(targetPos - selfPos)
    	if dist > range then
    		self:ClearCurCombo()
    		return false
    	end
	end
	local ability = self:getAbilityByName(ability_name)
	if not self:isAbilityValid(ability,true) then
    	self:ClearCurCombo()
		return false
	end

	self:aiCastAbility(target,ability)
	return self:NextCurCombo()
end


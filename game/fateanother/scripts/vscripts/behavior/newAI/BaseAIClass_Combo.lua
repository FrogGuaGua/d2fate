LogOpen.BaseAIClass_Combo = false
local function dp(...)
	if LogOpen.BaseAIClass_Combo then
		print(string.format(...))
	end
end

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

--隐藏技能是否可用
function BaseAIClass:can_use_hide()
	local unit = self.unit
	local hide_ability_names = self.hide_ability_names
	for _ , hide_ability_name in ipairs(hide_ability_names) do
		local ability = unit:FindAbilityByName(hide_ability_name) 
		if ability == nil then return false end
		if ability:GetCooldownTime() > 0 then
			dp('can_use_hide | CD %s %s',ability:GetName(),ability:GetCooldownTime())
			return false
		end

		if ability:GetManaCost(ability:GetLevel()) > unit:GetMana() then
			dp('can_use_hide | MANA %s %s',ability:GetName(),ability:GetCooldownTime())
			return false
		end
	end
	return self.canUseHide
end

--检查combo是否可用
function BaseAIClass:check_combo_valid(hide,index)
	local unit = self.unit
	local combos = hide and self.hide_combos or self.combos
	local combo = combos[index]
	local filterFunc = self.combo_filters[combo]
	if filterFunc and not filterFunc(self) then
		dp('check_combo_valid | filterFunc %s %s %s',hide , index , false)
		return false
	end

	for idx , data in ipairs(combo) do
		local ability_name = data[1]
		if type(ability_name) == 'string' then
			local ability = self:getAbilityByName(ability_name)
			dp('check_combo_valid | %s',ability_name)
			if not self:isAbilityValid(ability) then
				dp('check_combo_valid | %s %s',ability_name,false)
				return false
			end
		end
	end
	dp('check_combo_valid | %s %s %s',hide , index , true)
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
			if data[2] < 1.001 and type(ability_name) ~= 'function' then
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
function BaseAIClass:get_best_combo_targets(hide,index,target)
	local targets = {}
	local combo = hide and self.hide_combos or self.combos
	if not self:check_combo_valid(hide,index) then
		return targets
	end
	local range = self:get_combo_range(hide,index)
	local unit = self.unit
	local selfPos = unit:GetAbsOrigin()
	local selfTeam = unit:GetTeam()
	dp('---get_best_combo_targets %s %s %s %s',hide,index,range,target)

	local tb =FindUnitsInRadius(selfTeam,unit:GetAbsOrigin(),nil,3000,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,0,false)

	if target then
		local targetPos = target:GetAbsOrigin()
    	local dist = #(targetPos - selfPos)
    	if dist < range then
    		table.insert(targets,target)
    	end
		return targets
	end
	

	for _ , target in ipairs(tb) do
		local name = target:GetUnitName()
		if target:IsHero() or self.summonUnits[name] then
			if unit:CanEntityBeSeenByMyTeam(target) and self:ValidTarget(target) then
				local targetPos = target:GetAbsOrigin()
		    	local dist = #(targetPos - selfPos)
		    	if dist < range then
		    		table.insert(targets,target)
		    	end
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
		local lastComboTarget = self:getLastComboTarget()
		if lastComboTarget then
			if self:is_hide_unlock() and self:can_use_hide() then
				for i=1 , #hide_combos do
					targets = self:get_best_combo_targets(true,i,lastComboTarget)
					if #targets > 0 then
						combo = hide_combos[i]
						dp('SelectComboAndTarget hide_combos %s %s',i,combo[1][1])
						break
					end
				end
			end

			if combo then break end

			for i=1 , #combos do
				targets = self:get_best_combo_targets(false,i,lastComboTarget)
				if #targets > 0 then
					combo = combos[i]
					dp('SelectComboAndTarget combos %s %s',i,combo[1][1])
					break
				end
			end

			break
		end

		if combo then break end

		if self:is_hide_unlock() and self:can_use_hide() then
			for i=1 , #hide_combos do
				targets = self:get_best_combo_targets(true,i)
				if #targets > 0 then
					combo = hide_combos[i]
					dp('SelectComboAndTarget hide_combos %s %s',i,combo[1][1])
					break
				end
			end
		end

		if combo then break end

		for i=1 , #combos do
			targets = self:get_best_combo_targets(false,i)
			if #targets > 0 then
				combo = combos[i]
				dp('SelectComboAndTarget combos %s %s',i,combo[1][1])
				break
			end
		end
	until (true)
	
	if #targets == 0 then
		return false
	end
	local selectTarget = targets[1]
	if self.comboSelectType == 'hp' then
		local minHP = selectTarget:GetHealth()
		for _ , target in ipairs(targets) do
		local hp = target:GetHealth()
			if minHP > hp then
				selectTarget = target
				minHP = hp
			end
		end
	elseif self.comboSelectType == 'dist' then
		local selfPos = unit:GetAbsOrigin()
		local targetPos = selectTarget:GetAbsOrigin()
		local minDist = #(targetPos-selfPos)
		for _ , target in ipairs(targets) do
			targetPos = selectTarget:GetAbsOrigin()
			local dist = #(targetPos-selfPos)
			if minDist > dist then
				selectTarget = target
				minDist = dist
			end
		end
	end
	
	self.curCombo = {target = selectTarget , combo = combo , step = 1}

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
	self.lastComboData = {target =self.curCombo.target , time = Time() + self.lastComboTimeLimit}
	self.curCombo = {target = nil , combo = nil , step = 0}
end

function BaseAIClass:HasComboTarget()
	local target = self.curCombo.target
	return self:ValidTarget(target)
end

function BaseAIClass:GetComboTarget()
	return self.curCombo.target
end

function BaseAIClass:DoCombo()
	if not self:HasComboTarget() then
		return false
	end

	local curCombo = self.curCombo
	local target = curCombo.target
	local combo = curCombo.combo
	local step = curCombo.step

	local unit = self.unit
	--unit:SetForceAttackTarget(nil)
	dp('DOCombo | target %s',target:GetName())

	if not self:isValidCastAbility() then
		return false 
	end

	if not self:ValidTarget(target) then
		self:ClearCurCombo()
		return false
	end
	
	local ability_name = combo[step][1]
	local check = combo[step][3]
	dp('DoCombo %s',step,ability_name)

	if type(ability_name) == 'function' then
		ability_name(self)
	else
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
	end

	return self:NextCurCombo()
end


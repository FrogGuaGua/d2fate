_G.BaseAIClass = GameRules.BTreeCMN.Class('BaseAIClass')
function BaseAIClass:ctor(unit)
	--战斗前置技能 [1] ability_name [2] enemy_dist
	self.prefight = {}

	-- [1] ability_name [2]range [3]check range when DoCombo
	self.combos = {}
	self.hide_combos = {}

	--self.hide_modifier_name = ""
	self.hide_ability_names = {}
	self.hide_condition = {agiltity=20,intellect=20,strength=20}
	self.unit = unit
	self.curCombo = {target = nil, combo = nil , step = 0}
	
	self.nearEnemy = nil
	self.searchRange = 2000
	self.lastMoveTime = 0
	self.moveCD = 0.5
	self.refreshCD = 30
	self.lastRefreshCDTime = 0
	self.nextskill = 0
	
	--次级战斗逻辑
	self.secFightAbility = {}
	self.nextSecFightTime = 0
	self.secFightCD = 1

	--连招技能，需要特定顺序的技能才能使用
	self.combo_abilitys = {}
	--已经释放的技能队列
	self.ability_queue = {}
end

function BaseAIClass:HasNearEnemy()
	return self.nearEnemy ~= nil
end

--跑
function BaseAIClass:MoveTo(_type)
	local lastMoveTime = self.lastMoveTime
	local moveCD = self.moveCD
	if lastMoveTime + moveCD > Time() then
		return
	end
	self.lastMoveTime = Time()
	local target = nil
	if _type == 'near_player' then
		target = self:FindNearestPlayer()
	elseif _type == 'enemy' then
		target = self.nearEnemy
	end

	if target then
		self.unit:MoveToTargetToAttack(target)
	end
end

--重置CD
function BaseAIClass:RefreshCD()
	if self.lastRefreshTime + self.refreshCD > Time() then
		return false
	end

	self.lastRefreshCDTime = self.lastRefreshTime + self.refreshCD
	local unit = self.unit
	local name = unit:GetName()
	local hide_ability_names = self.hide_ability_names
	for index=0 , 16 do
		local ability = unit:GetAbilityByIndex(index)
		if ability and hide_ability_names[ability:GetName()] then
			ability:EndCooldown()
		end
	end
	for index=0 , 5 do
		local ability = unit:GetItemInSlot(index)
		if ability then
			ability:EndCooldown()
		end
	end

	unit:SetMana(unit:GetMaxMana())
	return true
end

function BaseAIClass:Clear()
	self:ClearCurCombo()
	self.nearEnemy = nil
	self.lastMoveTime = 0
	self.lastRefreshCDTime = 0
	self.ability_queue = {}
end

function BaseAIClass:GetEnemey()
	if self.curCombo.target then
		return self.curCombo.target
	end

	return self.nearEnemy
end

function BaseAIClass:SecFight()
	local unit = self.unit
	local target = self:GetEnemey()
	if not self:IsValidComboTarget(target) then
		return
	end

	local selfPos = unit:GetAbsOrigin()
	local targetPos = target:GetAbsOrigin()
	local dist = #(targetPos-selfPos)
	local secFightAbility = self.secFightAbility
	for _ , data in ipairs(secFightAbility) do
		local name = data[1]
		local range = data[2]
		if dist < range then
			local ability = self:getAbilityByName(name)
			if self:isAbilityValid(ability,true) then
				if self.nextSecFightTime < Time() then
					if self:aiCastAbility(target,ability) then
						self.nextSecFightTime = Time() + self.secFightCD
					end
				end
			end
		end
	end
end

function BaseAIClass:PreTick()
	return false
end

function BaseAIClass:Tick()
	self.nearEnemy = self:FindNearestEnemy()
	print('self.nearEnemy',self.nearEnemy)
	if self:PreTick() then
		return
	end

	print('-HasComboTarget')

	if self:HasComboTarget() then
		self:DoCombo()
		return
	end

	if self:SelectComboAndTarget() then
		return
	end

	if self:LateTick() then
		return
	end

	print('self:HasNearEnemy()',self:HasNearEnemy())
	if self:HasNearEnemy() then
		self:SecFight()
		self:MoveTo('enemy')
		return
	end

	self:MoveTo("near_player")
	return
end

function BaseAIClass:LateTick()
	return false
end

function BaseAIClass:Enter()
	self:Clear()
	self.unit:SetContextThink("ai", function()
		self:Tick()
		return 0.2
	end , 0.2)
end

function BaseAIClass:Exit()
	self.unit:SetContextThink("ai", function()
		self:Clear()
		return
	end , 0.1)
end

function BaseAIClass:OnUnitDead(unit)
	if self.curCombo.target == unit then
		self:ClearCurCombo()
	end
end

_G.AttachAI = function(unit)
	local name = unit:GetName()
	for key , v in pairs(AIClass) do
		if 'npc_dota_hero_bloodseeker' == name then
			print('true',AIClass[key])
		else
			print('false')
		end
		print(key,v)
	end

	local aiClass = AIClass[name]
	print('AttachAI ',name , aiClass)
	if aiClass then
		unit.aiClass = aiClass.new(unit)
		unit.aiClass:Enter()
	end
end

_G.RemoveAI = function(unit)
	if unit.aiClass then
		unit.aiClass:Exit()
	end
end
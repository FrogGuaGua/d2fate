require("bit")
_G.LogOpen = {}
LogOpen.BaseAIClass = false
local function dp( ... )
	if LogOpen.BaseAIClass then
		print(string.format(...))
	end
end

_G.BaseAIClass = GameRules.BTreeCMN.Class('BaseAIClass')
function BaseAIClass:ctor(unit,lvl)
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
	self.lastComboData = { target = nil , time = 0}
	self.lastComboTimeLimit = 3
	self.comboSelectType = 'dist' --距离优先

	self.nearEnemy = nil
	self.searchRange = {
		begin = 1000,
		wait = 3000,
		guard = 3000,
		fight = 30000,
	}
	self.lastMoveTime = 0
	self.moveCD = 10
	self.lastPos = Vector(0,0,0)
	self.moveToTarget = nil
	self.firstRefreshCD = 11
	self.secondRefreshCD = 30
	self.refreshCD = nil
	self.nextRefreshTime = Time()
	self.canUseHide = false
	self.nextskill = 0
	
	--次级战斗逻辑
	self.secFightAbility = {}
	self.nextSecFightTime = 0
	self.secFightCD = 1

	--连招技能，需要特定顺序的技能才能使用
	self.combo_abilitys = {}
	--已经释放的技能队列
	self.ability_queue = {}

	--需要攻击召唤物
	self.summonUnits = {
		gille_gigantic_horror = true,
		caster_5th_territory = true,
	}

	self.curStep = "begin"

	--回合开始后时间
	self.steps = {
		wait = {0,20}, --挂机
		guard = {20,60}, --巡逻
		fight = {61,1800}, --主动出击
		--fight = {0,10000}, --主动出击

		--wait = {0,5}, --挂机
		--guard = {5,20}, --巡逻
		--fight = {0,1800}, --主动出击
	}

	--3980,1298,284
	self.guardCenterLeft = Vector(-2057,1690,256) --左边巡逻中心
	self.guardCenterRight = Vector(3780,1690,284) --右边巡逻中心
	self.guardCenter = self.guardCenterLeft
	self.guardW = 800 --巡逻范围 宽
	self.guardH = 3000 --巡逻范围 长
	self.guardCD =10
	self.guardNextTime = 0
	self.lastpos = unit:GetAbsOrigin()

	self.nextUpgradeAbilityTime = Time()
	self.UpgradeAbilityCD = 10

	self.master2 = {0,1,2,3,4}

	--技能释放方式
	self.abilitys_behavior = {}

	--道具释放方式
	self.items_behavior = {
		item_s_scroll_ai = 'target',
		item_c_scroll_ai = 'target',
		item_a_scroll_ai = 'self',
		item_b_scroll_ai = 'self',
		item_blink_scroll = 'pos',
		item_healing_scroll = 'self',
	}

	--技能特殊条件
	self.special_ability_condition = {}

	self.combo_filters = {}

	self.wushimoming = false

	print('lvl',lvl)
	self:InitAILevel(lvl)
end

function BaseAIClass:InitAILevel(lvl)
	if lvl == nil then lvl = 1 end
	print('InitAILevel',lvl)
	local data = AILevel[lvl]
	self.firstRefreshCD = data.firstRefreshCD
	self.secondRefreshCD = data.secondRefreshCD
	for _ , item_name in ipairs(data.items) do
		local ok = true
		for slot=0,5 do
			local item = self.unit:GetItemInSlot(slot)
			if item and item:GetName() == item_name then
				ok = false
				break
			end
		end
		if ok then
			self.unit:AddItemByName(item_name)
		end
	end

end

function BaseAIClass:HasNearEnemy()
	return self.nearEnemy ~= nil
end

function BaseAIClass:getLastComboTarget()
	local data = self.lastComboData
	--dp('getLastComboTarget | %s %s %s',data.target and data.target:GetName() or 'nil',data.time,Time())
	if data.target and self:ValidTarget(data.target) and data.time > Time() then
		return data.target
	end

	return nil
end

--跑
function BaseAIClass:MoveTo(_type)
	local target = nil
	if _type == 'near_player' then
		target = self:FindNearestPlayer()
	elseif _type == 'enemy' then
		target = self:GetEnemy()
	end
	local curpos = self.unit:GetAbsOrigin()
	local lastpos = self.lastpos
	if target ~= self.moveToTarget or curpos == lastpos then
		self.unit:MoveToTargetToAttack(target)
		self.moveToTarget = target
	end
	self.lastpos = curpos
end

function BaseAIClass:OnRefreshCD()
	return false
end

--重置CD
function BaseAIClass:RefreshCD()
	if self.refreshCD == nil then
		return
	end
	if self.nextRefreshTime > Time() then
		return false
	end

	print("Refresh !!!")
	self.refreshCD = self.secondRefreshCD
	self:ClearCurCombo()
	self.canUseHide = true
	self.nextRefreshTime = Time() + self.refreshCD
	local MasterUnit = self.unit.MasterUnit
	local cmd_seal_2 = MasterUnit:FindAbilityByName("cmd_seal_2")
	MasterUnit:CastAbilityNoTarget(cmd_seal_2,-1)
	cmd_seal_2:EndCooldown()


	-- local unit = self.unit
	-- local name = unit:GetName()
	-- local hide_ability_names = self.hide_ability_names
	-- for index=0 , 16 do
	-- 	local ability = unit:GetAbilityByIndex(index)
	-- 	if ability and hide_ability_names[ability:GetName()] then
	-- 		ability:EndCooldown()
	-- 		dp('RefreshCD | %s %s',ability:GetName(),ability:GetCooldownTime())
	-- 	end
	-- end
	-- for index=0 , 5 do
	-- 	local ability = unit:GetItemInSlot(index)
	-- 	if ability then
	-- 		ability:EndCooldown()
	-- 	end
	-- end
	-- local particle = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
	-- ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
	-- unit:EmitSound("DOTA_Item.Refresher.Activate")
	self:OnRefreshCD()
	return true
end

function BaseAIClass:Clear()
	self:ClearCurCombo()
	self.nearEnemy = nil
	self.lastMoveTime = 0
	self.refreshCD = nil
	self.nextRefreshTime = 0
	self.ability_queue = {}
	self.guardNextTime = 0
	self.nextUpgradeAbilityTime = 0
	self.canUseHide = false
	self.lastComboData = {target = nil , time = 0}
	self.moveToTarget = nil
	self.curStep = "begin"
end

function BaseAIClass:GetSearchRange()
	local curStep = self.curStep
	return self.searchRange[curStep]
end

function BaseAIClass:ValidTarget(unit)
	if unit and IsValidEntity(unit) and unit:IsAlive() then
		if not self.wushimoming then
			local mod = self.unit:FindModifierByName("modifier_magic_immunity")
			if mod then
				dp('ValidTarget | 1')
				return false
			end
		end
		dp('ValidTarget | 2')
		return true
	end
	dp('ValidTarget | 3')
	return false
end

function BaseAIClass:GetEnemy()
	local target = self.curCombo.target
	if self:ValidTarget(target) then
		return target
	end

	target = self:getLastComboTarget()
	if self:ValidTarget(target) then
		return target
	end
	target = self.nearEnemy
	if self:ValidTarget(target)  then
		return target
	end

	return nil
end

function BaseAIClass:SecFight()
	local unit = self.unit
	local target = self:GetEnemy()
	if not self:ValidTarget(target) then
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
	local unit = self.unit
	local hp = unit:GetHealth() / unit:GetMaxHealth()
	if hp < 0.7 then
		local ability = self:getAbilityByName("item_healing_scroll")
		if self:isAbilityValid(ability,true) then
			return self:aiCastAbility(unit,ability)
		end
	end
	return false
end

function BaseAIClass:UpgradeAbility()
	if self.nextUpgradeAbilityTime < Time() then
		self.nextUpgradeAbilityTime = Time() + self.UpgradeAbilityCD
		local unit = self.unit
		for idx=0 , 14 do
			local ability = unit:GetAbilityByIndex(idx)
			if ability then
				for i=1 , 10 do
					unit:UpgradeAbility(ability)
				end
			end
		end
	end
end

function BaseAIClass:Tick()
    local pauseMod =  self.unit:FindModifierByName("round_pause")
    if pauseMod or not self.unit:IsAlive() then
    	return
    end

	self.unit:SetMana(self.unit:GetMaxMana())
	self.nearEnemy = self:FindNearestEnemy()
	if self:RefreshCD() then
		return
	end

	self:UpgradeAbility()

	if self:PreTick() then
		return
	end
	dp('self:HasComboTarget()', self:HasComboTarget())
	if self:HasComboTarget() then
		self:DoCombo()
		return
	end
	dp('self:SelectComboAndTarget()')
	if self:SelectComboAndTarget() then
		return
	end
	dp('self:LateTick()')

	if self:LateTick() then
		return
	end
	dp('self:LateTick()-->')
	local duration =Time()-RoundStartTime
	local steps = self.steps
	local step = 'fight'
	for s , range in pairs(steps) do
		if range[1] < duration and range[2] > duration then
			step = s
			break
		end
	end
	
	if self.curStep ~= step then
		print('enter step',step)
		self.curStep = step
	end
	if self:GetEnemy() then
		if self.lastpos == self.unit:GetAbsOrigin() then
			self.unit:MoveToTargetToAttack(self:GetEnemy())
		else
			self.lastpos = self.unit:GetAbsOrigin()
		end
	else
		if step == 'wait' then
			
		elseif step == 'guard' then
			if self.lastpos == self.unit:GetAbsOrigin() then
				self.guardNextTime = Time() + self.guardCD
				self.unit:MoveToPosition(self:GetGuardVec())
			else
				self.lastpos = self.unit:GetAbsOrigin()
			end
		elseif step == 'fight' then
		end
	end
	--self:MoveTo("near_player")
	return
end

function BaseAIClass:GetGuardVec()
	local unit = self.unit
	local team = unit:GetTeam()
	local nCurrentRound = GameRules.AddonTemplate.nCurrentRound
	local c 
	if team == 2 then
		if math.mod(nCurrentRound,2) == 0 then
			c = self.guardCenterRight
		else
			c = self.guardCenterLeft
		end
	else
		if math.mod(nCurrentRound,2) == 0 then
			c = self.guardCenterLeft
		else
			c = self.guardCenterRight
		end
	end 

	local x = math.random(-self.guardW,self.guardW) 
	local y = math.random(-self.guardH,self.guardH) 
	x = c.x + x
	y = c.y + y
	return Vector(x,y,c.z)
end

function BaseAIClass:LateTick()
	return false
end

function BaseAIClass:Enter()
	self:Clear()
	self.unit:SetContextThink("ai", function()
		self:Tick()
		return 0.05
	end , 0.05)
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
		self.lastComboData = {target = nil , time = 0}
	end
end

function BaseAIClass:MaxMasterUnit2Abilitys()
	local unit = self.unit
	local master2 = unit.MasterUnit2
	if master2 then
		master2:SetMaxMana(1000)
		master2:SetMana(1000)
		for _,idx in ipairs(self.master2) do
			local ability = master2:GetAbilityByIndex(idx)
			if ability then
				ability:CastAbility()
			end
		end
	end
end

_G.AttachAI = function(unit,lvl)
	local name = unit:GetName()

	local aiClass = AIClass[name]
	if aiClass then
		print('--aiClass AttachAI',lvl)
		unit.aiClass = aiClass.new(unit,lvl)
		unit.aiClass:MaxMasterUnit2Abilitys()
		unit.aiClass:Enter()
	end
end

_G.RemoveAI = function(unit)
	if unit.aiClass then
		unit.aiClass:Exit()
	end
end
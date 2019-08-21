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
	self.lastComboTimeLimit = 1
	self.comboSelectType = 'dist' --距离优先

	self.nearEnemy = nil
	self.searchRange = {
		begin = 1000,
		wait = 30000,
		guard = 30000,
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
		wait = {0,1}, --挂机
		guard = {1,60}, --巡逻
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
	self.guardW = 1300 --巡逻范围 宽
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
		item_blink_scroll_ai = 'pos',
		item_mana_essence_ai = 'self',
	}

	--技能特殊条件
	self.special_ability_condition = {}

	self.combo_filters = {}

	self.wushimoming = false
	self.wushiwuming = false

	self:InitAILevel(lvl)

	self.MasterTimeInterval = 180 --御主技能升级间隔时间
	self.NextMasterTime = Time() + self.MasterTimeInterval
	self.MasterAbilityIndex = 0

	self.nextAddManaTime = Time() 
	self.addManaCD = 1
	self.addMana = 50


	self.ignoreUnit = {
		scout_familiar = true , --鸟
	}

	--过滤mod
	self.filterMod = {
		modifier_avalon = true , -- 无敌
		modifier_magic_immunity = true, -- 魔免
	}

	self.firstTickTime = nil
	if self.unit:GetName() == "npc_dota_hero_drow_ranger" then 
		self.unit:SetAbilityPoints(4)
	else
		self.unit:SetAbilityPoints(0) --初始0个技能点
	end
	self.unit.MasterUnit:SetAbsOrigin(Vector(-10000,-10000,-1000))
	self.unit.MasterUnit2:SetAbsOrigin(Vector(-10000,-10000,-1000))
	--SetRenderingEnabled(self.unit.MasterUnit:GetEntityHandle(),false)
	--SetRenderingEnabled(self.unit.MasterUnit2:GetEntityHandle(),false)
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
			print('--additem ',item_name)
			self.unit:AddItemByName(item_name)
		end
	end

end

--初始属性
function BaseAIClass:InitBaseAtb(atb)
	print('InitBaseAtb')
	local unit = self.unit
	unit:SetBaseStrength(atb.strength)  --力量
	unit:SetBaseAgility(atb.agiltity)  --力量
	unit:SetBaseIntellect(atb.intellect)  --力量
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

	local unit = self.unit
	local name = unit:GetName()
	local hide_ability_names = self.hide_ability_names
	for index=0 , 16 do
		local ability = unit:GetAbilityByIndex(index)
		if ability and not hide_ability_names[ability:GetName()] then
			ability:EndCooldown()
			dp('RefreshCD | %s %s',ability:GetName(),ability:GetCooldownTime(),ability:IsCooldownReady())
		end
	end
	for index=0 , 5 do
		local ability = unit:GetItemInSlot(index)
		if ability then
			ability:EndCooldown()
		end
	end
	local particle = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
	ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
	unit:EmitSound("DOTA_Item.Refresher.Activate")
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
	self.firstTickTime = nil
end

function BaseAIClass:GetSearchRange()
	local curStep = self.curStep
	return self.searchRange[curStep]
end

function BaseAIClass:IgnoreUnit(unit)
	local name = unit:GetUnitName()
	return self.ignoreUnit[name] ~= nil
end

function BaseAIClass:TargetFilterMod(unit)
	local filterMod = self.filterMod
	for name in pairs(filterMod) do
		local mod = unit:FindModifierByName(name)
		if mod then
			return true
		end
	end

	return false
end

function BaseAIClass:ValidTarget(unit)
	if unit and IsValidEntity(unit) and unit:IsAlive() and not self:IgnoreUnit(unit) then
		if self:TargetFilterMod(unit) then
			dp('TargetFilterMod | 1')
			return false
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

function BaseAIClass:AddMana()
	if self.nextAddManaTime > Time() then
		return
	end

	self.nextAddManaTime = Time() + self.addManaCD
	local addMana = self.addMana
	local unit = self.unit
	local mana = unit:GetMana()
	unit:SetMana(mana + addMana)
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
	--local hp = unit:GetHealth() / unit:GetMaxHealth()
	local mana = unit:GetManaPercent()
	local hp = unit:GetHealthPercent()
	if hp < 80 or mana < 70 then
		local ability = self:getAbilityByName("item_condensed_mana_essence_ai")
		if self:isAbilityValid(ability,true) then
			print('PreTick',ability:GetName())
			return self:aiCastAbility(unit,ability)
		end
	end
	if hp < 70 then
		local ability = self:getAbilityByName("item_healing_scroll_ai")
		if self:isAbilityValid(ability,true) then
			print('PreTick',ability:GetName())
			return self:aiCastAbility(unit,ability)
		end
	end
	return false
end

function BaseAIClass:UpgradeAbility()
	if self.nextUpgradeAbilityTime < Time() then
		self.nextUpgradeAbilityTime = Time() + self.UpgradeAbilityCD
		local ability_upgrade = self.ability_upgrade
		local unit = self.unit

		for idx , data in ipairs(ability_upgrade) do
			for abilityName , needPoint in pairs(data) do
				local ability = unit:FindAbilityByName(abilityName)
				if ability and needPoint > 0 then
					for i=1 , needPoint do
						if unit:GetAbilityPoints() > 0 then
							unit:UpgradeAbility(ability)
							data[abilityName] = data[abilityName] -1
						end
					end
				end
			end
		end
	end
end

--C鸟
function BaseAIClass:TickCBird()
	local unit = self.unit
	local selfTeam = unit:GetTeam()
	local selfPos = unit:GetAbsOrigin()
	local range = 800
	local tb =FindUnitsInRadius(selfTeam,selfPos,nil,range,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,0,false)
	for _ , _target in ipairs(tb) do
			print('_target:GetUnitName()',_target:GetUnitName())
		--if self:ValidTarget(_target) then
			--if  unit:CanEntityBeSeenByMyTeam(_target) then
				if _target:GetUnitName() == "scout_familiar" then --鸟
					local ability = self:getAbilityByName("item_c_scroll_ai")
					unit:CastAbilityOnTarget(_target, ability, -1)
					break
				end
			--end
		--end
	end
end

function BaseAIClass:Tick()
    self:UpgradeAbilityMasterUnit2()
    self:AddMana()
    local pauseMod =  self.unit:FindModifierByName("round_pause")
    if pauseMod or not self.unit:IsAlive() then
    	return
    end

    if self.firstTickTime == nil then
    	self.firstTickTime = GameRules:GetGameTime()
    	return
    end
    
    if self.firstTickTime + 10 > GameRules:GetGameTime() then
    	return
    end

	self.nearEnemy = self:FindNearestEnemy(self.curStep ~= 'fight')
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
	local duration =GameRules:GetGameTime()-RoundStartTime
	--print('RoundStartTime',RoundStartTime,GameRules:GetGameTime())
	local steps = self.steps
	local step = 'begin'
	for s , range in pairs(steps) do
		if range[1] < duration and range[2] > duration then
			step = s
			break
		end
	end
	if GameRules:GetGameTime() < 85 then
		return
	end

	if self.curStep ~= step then
		self.curStep = step
	end

	local enemy = self:GetEnemy()
	if enemy then
		if self.lastpos == self.unit:GetAbsOrigin()
			or enemy ~= self.lastenemy then
			self.unit:MoveToTargetToAttack(self:GetEnemy())
		end
	else
		if step == 'wait' then
			
		elseif step == 'guard' then
			if self.lastpos == self.unit:GetAbsOrigin() or enemy ~= self.lastenemy then
				self.guardNextTime = Time() + self.guardCD
				self.unit:MoveToPosition(self:GetGuardVec())
			else
				self.lastpos = self.unit:GetAbsOrigin()
			end
		elseif step == 'fight' then
		end
	end
	self:TickCBird()
	self.lastpos = self.unit:GetAbsOrigin()
	self.lastenemy = enemy
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

function BaseAIClass:UpgradeAbilityMasterUnit2()
	if self.NextMasterTime > Time() then
		return
	end

	if self.MasterAbilityIndex > 6 then
		return
	end

	self.NextMasterTime = Time() + self.MasterTimeInterval

	local unit = self.unit
	local master2 = unit.MasterUnit2
	if master2 then
		master2:SetMaxMana(1000)
		master2:SetMana(1000)
		local idx = self.MasterAbilityIndex
		local ability = master2:GetAbilityByIndex(idx)
		if ability then
			ability:CastAbility()
		end
		self.MasterAbilityIndex = idx + 1
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
		unit.aiClass = aiClass.new(unit,lvl)
		--unit.aiClass:MaxMasterUnit2Abilitys()
		unit.aiClass:Enter()
	end
end

_G.RemoveAI = function(unit)
	if unit.aiClass then
		unit.aiClass:Exit()
	end
end
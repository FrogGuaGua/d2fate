_G.DrowRangerAIClass = GameRules.BTreeCMN.Class('DrowRangerAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll_ai'

--技能
local Q = "atalanta_celestial_arrow"
local W = "atalanta_calydonian_hunt"
local W1= "atalanta_cobweb_shot"    --蜘蛛网
local HW= "atalanta_phoebus_catastrophe_snipe"
local E = "atalanta_traps"
local E1= "atalanta_entangling_trap"       --陷阱
local HE = ""
local D = "atalanta_crossing_arcadia"
local F = "atalanta_traps_close"
local F1 = "atalanta_phoebus_catastrophe_barrage"   --箭雨
local R = "atalanta_tauropolos_new"
local R1 = "atalanta_golden_apple"        --金苹果

local ATT = 'attribute_bonus_custom'
--升级技能表
local ability_upgrade =
{
	{[Q] = 4}, {[W] = 4},{[R] = 4} ,{[ATT] = 7},{[E] = 4} , 
}

--初始属性
local base_atb = {
	agiltity=5,	--敏捷
	intellect=10,--智力
	strength=12  --力量
}

local abilitys_behavior = {
	[Q] = "pos",
	[W] = "self",
	[W1] = "pos",
	[HW] = 'target',
	[E1] = "pos",
	[D] = "pos", 
	[R] = "pos", 
	[F1] = "pos", 
	[R1] = "pos", 
}

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = {}

--隐藏技能
local hide_ability_names = {[HW]=true,[F1]=true,[R1]=true}


local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	
}

--隐藏技能组合
local hide_combos =
{	
	[1] = {{HW,3000}},
	[2] = {{W,3000}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	[1] ={{A,1800}},
	[2] ={{B,3000}},
	[3] ={{D,400}},
	[4] ={{F1,2000}},
	[5] ={{W,5000}},
	[6] ={{E1,2000}},
	[7]={{C,900},},
	[8] ={{R,2000}},
	[9] ={{R1,2000}},
	[10] ={{S,900},},
	[11] ={{Q,900}},
	
	
}

local function IsHWValid(self)
	local hw = self:getAbilityByName(HW)
	return hw:IsCooldownReady()
end

local function IsWValid(self)
	local enemy = self:GetEnemy() 
	local modName = 'modifier_calydonian_hunt'
	if self:ValidTarget(enemy) and enemy:HasModifier(modName) then
		local mod = enemy:FindModifierByName(modName)
		if mod and mod:GetStackCount() > 3 then
			return true
		end
	end

	return false
end

local combo_filters =
{
	[hide_combos[2]] = IsHWValid,
	[combos[5]] = IsWValid,
}


function DrowRangerAIClass:PreTick()
	local W1Ablity = self:getAbilityByName(W1)
	local E1Ability = self:getAbilityByName(E1)
	local unit = self.unit

	if W1Ablity:IsHidden() and E1Ability:IsHidden() then
		unit:SwapAbilities(E, W1, false, true)
		unit:SwapAbilities(E, E1, false, true)
		unit:SwapAbilities(E, R1, false, true)
	end
	local modName = "modifier_priestess_of_the_hunt"

	local mod = unit:FindModifierByName(modName)
	if mod then
		mod:SetStackCount(10)
	end

	return self.super.PreTick(self)
end

function DrowRangerAIClass:LateTick()
	return false
end

function DrowRangerAIClass:ctor(unit,lvl)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit,lvl)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
	self.abilitys_behavior = abilitys_behavior
	self.combo_filters = combo_filters
	self:InitBaseAtb(base_atb)
	self.ability_upgrade = ability_upgrade
end

print('load drowRanger ai',DrowRangerAIClass)
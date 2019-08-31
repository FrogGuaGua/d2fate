_G.DoomAIClass = GameRules.BTreeCMN.Class('DoomAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll_ai'

--技能
local Q = "berserker_5th_fissure_strike"
local W = "berserker_5th_courage"
local HW= "berserker_5th_madmans_roar"
local E = "berserker_5th_berserk"
local HE = ""
local D = ""
local F = ""
local R = "berserker_5th_nine_lives"

local ATT = 'attribute_bonus_custom'
--升级技能表
local ability_upgrade =
{
	 {[R] = 4}, {[W] = 4},{[ATT] = 7} ,{[E] = 4},{[Q] = 4}, 
}

--初始属性
local base_atb = {
	agiltity=10,	--敏捷
	intellect=13,--智力
	strength=4  --力量
}

--技能释放方式
local abilitys_behavior = {
	[Q] = "pos",
	[HW] = "self",
	[W] = "self",
	[E] = "self",
	[R] = "pos", 
}


----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	-- [HW] = 
	-- { 
	-- 	time=4,
	-- 	abilitys = {Q,E},
	-- }
}

--隐藏技能
local hide_ability_names = {[HW]=true}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
}

--隐藏技能组合
local hide_combos =
{	
	[1] = {{HW,500}},
	[2] = {{Blink,900},{HW,1500}},
	[3] = {{Q,500},{E}},
	[4] = {{Q,500},{E},{Blink,900}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	[1] = {{A,1800}},
	[2] = {{B,3000}},
	[3] = {{W,2000}},
	[4] = {{E,800}},
	[5] = {{C,500},{R}},
	[6] = {{Blink,900},{C,500},{R}},
	[7] = {{Q,700},},
	[8] = {{S,800},},
	[9] = {{C,800},},
	[10] = {{R,700},},
}

local function IsHWValid(self)
	local unit = self.unit
	local HWAbility = unit:FindAbilityByName(HW)
	print('IsHWValid ',HWAbility:IsCooldownReady())
	return HWAbility:IsCooldownReady()
end

local function IsEValid(self)
	local unit = self.unit
	local hp = unit:GetHealth() / unit:GetMaxHealth()
	return hp < 0.8
end

local combo_filters =
{
	[hide_combos[3]] = IsHWValid,
	[hide_combos[4]] = IsHWValid,
	[combos[4]] = IsEValid,
}

function DoomAIClass:PreTick()
	
	return self.super.PreTick(self)
end

function DoomAIClass:LateTick()
	return false
end

function DoomAIClass:ctor(unit,lvl)
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

print('load tempclass ai',AITempClass)
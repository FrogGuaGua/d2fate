_G.WindRunnerAIClass = GameRules.BTreeCMN.Class('WindRunnerAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll_ai'
local HS = 'item_healing_scroll' --群补

--技能
local Q = 'nursery_rhyme_white_queens_enigma'
local W = 'nursery_rhyme_the_plains_of_water'
local E = 'nursery_rhyme_doppelganger'
local D = 'nursery_rhyme_shapeshift'
local F = 'nursery_rhyme_nameless_forest'
local R = 'nursery_rhyme_queens_glass_game'

--初始属性
local base_atb = {
	agiltity=5,	--敏捷
	intellect=5,--智力
	strength=5  --力量
}

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = {}

local hide_ability_names = {}

--技能释放方式
local abilitys_behavior = {
	[Q] = "pos",
	[W] = "target",
	[E] = "target",
	[D] = "pos",
	[R] = "self", 
}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{	
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	[ 1]={{R,800}},
	[ 2]={{A,1800}},
	[ 3]={{B,3000}},
	[ 4]={{D,800}},
	[ 5]={{E,800}},
	[ 6]={{Q,800}},
	[ 7]={{W,800}},
	[ 8]={{S,800},},
	[ 9]={{C,800},},
}

local function IsR(self)
	local unit = self.unit
	local hp = unit:GetHealthPercent()
	if hp < 60 then
		return true
	end
end

local combo_filters =
{
	[combos[1]] = IsR,
}

function WindRunnerAIClass:PreTick()
	local rModName = 'modifier_queens_glass_game'
	local unit = self.unit
	local rMod = unit:FindModifierByName(rModName)
	if rMod then
		local abilityR = unit:FindAbilityByName(R)
		abilityR:EndChannel(true)
	end
end

function WindRunnerAIClass:ctor(unit,lvl)
	print('unit',unit,unit:GetName())
	print('WindRunnerAIClass self ',self)
	self.super.ctor(self,unit,lvl)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
	self.abilitys_behavior = abilitys_behavior
	self.combo_filters = combo_filters
	self:InitBaseAtb(base_atb)
end

print('load windrunner ai',WindRunnerAIClass)
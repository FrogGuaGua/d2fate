_G.AITempClass = GameRules.BTreeCMN.Class('AITempClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = ""
local W = ""
local E = ""
local HE = ""
local D = ""
local F = ""
local R = ""



local abilitys_behavior = {
	
}

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	-- [HE] = 
	-- { 
	-- 	time=6,
	-- 	abilitys = {R,},
	-- }
}

--隐藏技能
local hide_ability_names = 
{
}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	{A,1800},{B,3000},
}

--隐藏技能组合
local hide_combos =
{	
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{S,800},},
	{{C,800},},
}

function BaseAIClass:PreTick()
	return false
end

function AITempClass:LateTick()
	return false
end

function AITempClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
	self.abilitys_behavior = abilitys_behavior
end

print('load tempclass ai',AITempClass)
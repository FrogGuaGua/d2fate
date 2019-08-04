_G.WindRunnerAIClass = GameRules.BTreeCMN.Class('WindRunnerAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = 'nursery_rhyme_white_queens_enigma'
local W = 'nursery_rhyme_the_plains_of_water'
local E = 'nursery_rhyme_doppelganger'
local D = 'nursery_rhyme_shapeshift'
local F = 'nursery_rhyme_nameless_forest'
local R = 'lishuwen_no_second_strike'

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = {}

--隐藏技能
local hide_ability_names = 
{
}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	{A,2500},{B,3000},
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
	{{D,800}},
	{{E,800}},
	{{Q,800}},
	{{W,800}},
	{{S,800},},
	{{C,800},},
	{{R,800}},
}


function WindRunnerAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
end

print('load windrunner ai',WindRunnerAIClass)
_G.LCAIClass = GameRules.BTreeCMN.Class('LCAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = "saber_invisible_air"
local W = "saber_caliburn"
local E = "saber_excalibur"
local HE = "saber_max_excalibur"
local D = "saber_strike_air"
local F = "saber_improved_instinct"
local R = "saber_avalon"

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	[HE] = 
	{ 
		time=6,
		abilitys = {R},
	}
}

--隐藏技能
local hide_ability_names = 
{
	HE,
}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	{A,2500},{B,3000},
}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{
	{{R},{HE,2000}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{W,100}},
	{{Blink,1000},{W,100}},
	{{Q,100}},
	{{W,100}},
	{{W,100}},
	{{S,900},{D,}},
	{{C,900},{D,}},
	{{D,800}},
	{{S},{E,900}},
	{{C},{E,900}},
	{{S,800},},
	{{C,800},},
	{{E,1000}},
}


function LCAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
end

print('load LCAIClass ai',LCAIClass)
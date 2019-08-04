_G.CMAIClass = GameRules.BTreeCMN.Class('CMAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = "caster_5th_argos"
local Q1 = "caster_5th_wall_of_flame"
local W1= "caster_5th_silence"
local E = "caster_5th_rule_breaker"
local E1 = "caster_5th_divine_words"
local HE = ""
local D = "caster_5th_territory_creation"
local F = ""
local R = "caster_5th_hecatic_graea"
local HR = "caster_5th_hecatic_graea_powered"

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	[HR] = 
	{ 
		time=5,
		abilitys = {E,},
	}
}

--隐藏技能
local hide_ability_names = 
{
	HR,
}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	{A,2500},{B,3000},{Q,2500}
}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{
	{{E,100},{HR}},
	{{Blink,1000},{E,100},{HR}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{E,100},{R}},
	{{Blink,1000},{E,100},{R}},
	{{Q1,300}},
	{{W1,600}},
	{{E1,600}},
	{{E,100},{R}},
	{{S,800},},
	{{C,800},},
}


function CMAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
end

print('load cm ai',CMAIClass)
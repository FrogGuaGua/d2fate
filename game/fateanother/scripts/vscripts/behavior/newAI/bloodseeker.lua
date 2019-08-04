_G.BloodAIClass = GameRules.BTreeCMN.Class('BloodAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = 'lishuwen_concealment'
local W = 'lishuwen_cosmic_orbit'
local E = 'lishuwen_fierce_tiger_strike'
local E1 = 'lishuwen_fierce_tiger_strike_2'
local E2 = 'lishuwen_fierce_tiger_strike_3'
local HE = 'lishuwen_raging_dragon_strike'
local HE1 = 'lishuwen_raging_dragon_strike_2'
local HE2 = 'lishuwen_raging_dragon_strike_3'
local D = 'lishuwen_martial_arts'
local R = 'lishuwen_no_second_strike'

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = {
	[E1] = 
	{ 	
		time = 6,
		abilitys = {E,},
	},
	[E2] = 
	{ 	
		time = 3,
		abilitys = {E1,},
	},
	[HE] = 
	{ 	
		time = 6,
		abilitys = {W,},
	},
	[HE1] = 
	{ 	
		time = 3,
		abilitys = {HE,},
	},
	[HE2] = 
	{ 	
		time = 3,
		abilitys = {HE1,},
	},
}

--隐藏技能
local hide_ability_names = 
{
	lishuwen_raging_dragon_strike=true,
	lishuwen_raging_dragon_strike_2=true,
	lishuwen_raging_dragon_strike_3=true,
}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	{A,2500},{B,3000},
}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{	
	{HE,400},{HE1},{HE2},
	{{W},{HE,400},{HE1},{HE2}},
	{{Blink,1000},{W},{HE,400},{HE1},{HE2}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{E,400},{E1},{E2}},
	{{Blink,1000},{E,400},{E1},{E2}},
	{{R,100}},
	{{Blink,1000},{R,100}},
	{{W,1500}},
	{{D,400}},
	{{S,800},},
	{{C,800},},
}


function BloodAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
end

print('load blooadseeker ai',BloodAIClass)
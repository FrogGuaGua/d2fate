_G.TaAIClass = GameRules.BTreeCMN.Class('TaAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = 'rider_5th_nail_swing'
local W = 'rider_5th_breaker_gorgon'
local E = 'rider_5th_bloodfort_andromeda'
local E1 = 'rider_5th_bellerophon_2'
local R = 'rider_5th_bellerophon'

--隐藏技能
local hide_ability_names = {}

local secFightAbility = 
{
	{A,2500},{B,3000},
}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{
	{{Q},{W},{E1,2000}},
	{{Q},{W},{Blink,1000},{E1,2000}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{S,1000},{R}},
	{{C,900},{R}},
	{{Q,450},{W},{E}},
	{{Blink,1000},{Q,450},{W},{E}},
	{{S,300},{E}},
	{{C,300},{E}},
	{{S,800},},
	{{C,800},},
	{{R,1300},},
	{{Q,400},},
	{{W,200},},
	{{E,100},},
}


function TaAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('TaAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.hide_ability_names = hide_ability_names
end

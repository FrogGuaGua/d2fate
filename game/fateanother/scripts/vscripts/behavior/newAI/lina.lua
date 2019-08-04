_G.LinaAIClass = GameRules.BTreeCMN.Class('LinaAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = "nero_rosa_ichthys"
local Q1 = "nero_acquire_divinity"
local W = "nero_gladiusanus_blauserum"
local E = "nero_blade_dance"
local HE = "nero_fiery_finale"
local HE = ""
local D = ""
local F = ""
local R = "nero_aestus_domus_aurea"

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	[HE] = 
	{ 
		time=0.5,
		abilitys = {R,},
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
	{A,2500},{B,3000},{Q1,800}
}

--隐藏技能组合
local hide_combos =
{	
	{{R,1000},{E}},
	{{Blink,1000},{R,1000},{E}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{R,1000}},
	{{Blink,1000},{R,1000}},
	{{Q,600}},
	{{E,300}},
	{{S,800},},
	{{C,800},},
	{{W,800}},
}

function LinaAIClass:LateTick()
	return false
end

function LinaAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
end

print('load lina ai',LinaAIClass)
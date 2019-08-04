_G.SkyWrathAIClass = GameRules.BTreeCMN.Class('SkyWrathAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = "gilgamesh_enkidu"
local W = "gilgamesh_gram"
local E = "gilgamesh_gate_of_babylon"
local HE = ""
local D = ""
local F = "gilgamesh_sword_barrage"
local R = "gilgamesh_enuma_elish"
local HR = "gilgamesh_max_enuma_elish"


----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	[HR] = 
	{ 
		time=4,
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
	{A,2500},{B,3000},
}

--隐藏技能组合
local hide_combos =
{	
	{{S},{E,900},{HR}},
	{{C},{E,900},{HR}},
	{{Blink,1000},{E,1000},{HR}},
	{{E,1000},{HR}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{E,800}},
	{{Blink,1000},{E,800}},
	{{S,800},{R}},
	{{C,800},{R}},
	{{R,1000}},
	{{Q,600}},
	{{W,800}},
	{{F,800}},
	{{S,800},},
	{{C,800},},
}

function SkyWrathAIClass:LateTick()
	return false
end

function SkyWrathAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
end

print('load skywrath ai',SkyWrathAIClass)
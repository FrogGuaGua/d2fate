_G.DrowRangerAIClass = GameRules.BTreeCMN.Class('DrowRangerAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = "atalanta_celestial_arrow"
local Q1= "atalanta_sting_shot"
local W = "atalanta_calydonian_hunt"
local W1= "atalanta_cobweb_shot"
local HW= "atalanta_phoebus_catastrophe_snipe"
local E = "atalanta_traps"
local E1= "atalanta_entangling_trap"
local HE = ""
local D = "atalanta_crossing_arcadia"
local F = "atalanta_traps_close"
local R = "atalanta_tauropolos_new"

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	[HW] = 
	{ 
		time=2,
		abilitys = {W,},
	}
}

--隐藏技能
local hide_ability_names = 
{
	HW,
}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	{A,2500},{B,3000},
}

--隐藏技能组合
local hide_combos =
{	
	{{W,},{HW,3000}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{E},{Q1,2000},{F}},
	{{E},{W1,2000},{F}},
	{{E},{E1,2000},{F}},
	{{Q,800}},
	{{R,2000}},
	{{E},{E1,1000},{F},},
	{{S,900},},
	{{C,900},},
	{{W,2000}},
}

function DrowRangerAIClass:PreTick()
	return false
end

function DrowRangerAIClass:LateTick()
	return false
end

function DrowRangerAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
end

print('load drowRanger ai',DrowRangerAIClass)
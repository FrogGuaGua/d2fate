_G.HaskarAIClass = GameRules.BTreeCMN.Class('HaskarAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = "diarmuid_warriors_charge"
local W = "diarmuid_double_spearsmanship"
local HW = "diarmuid_rampant_warrior"
local E = "diarmuid_gae_buidhe"
local D = "diarmuid_love_spot"
local F = ""
local R = "diarmuid_gae_dearg"

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	[HW] = 
	{ 
		time=3,
		abilitys = {D,},
	}
}

--隐藏技能
local hide_ability_names = 
{
	HW
}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	{A,2500},{B,3000},
}

--隐藏技能组合
local hide_combos =
{	
	{{C,200},{D,200},{HW}},
	{{S,200},{D,200},{HW}},
	{{D,200},{HW}},
	{{D},{Blink,1000,true},{S},{HW}},
	{{D},{Blink,1000,true},{C},{HW}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{D,500},
	{W,200},
	{R,400},
	{{B,1000},{S,300},{R}},
	{{B,1000},{C,300},{R}},
	{{Blink,1000},{Q,500},{E}},
	{{Blink,1000},{Q,500},{S},{E}},
	{{Blink,1000},{Q,500},{C},{E}},
	{{Q,500},{E}},
	{{Q,500},{S},{E}},
	{{Q,500},{C},{E}},
	{{Q,500}},
	{{D,300}},
	{{S,800},},
	{{C,800},},
}

function HaskarAIClass:PreTick()
	return false
end

function HaskarAIClass:LateTick()
	return false
end

function HaskarAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
end

print('load huskar ai',HaskarAIClass)
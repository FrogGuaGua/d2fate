_G.DoomAIClass = GameRules.BTreeCMN.Class('DoomAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = "berserker_5th_fissure_strike"
local W = "berserker_5th_courage"
local HW= "berserker_5th_madmans_roar"
local E = "berserker_5th_berserk"
local HE = ""
local D = ""
local F = ""
local R = "berserker_5th_nine_lives"

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	[HW] = 
	{ 
		time=4,
		abilitys = {Q,E},
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
	{A,2500},{B,3000},{W,2000},
}

--隐藏技能组合
local hide_combos =
{	
	{{Q},{E},{HW,1500}},
	{{Blink,1000},{Q},{E},{HW,1500}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{C,800},{R}},
	{{S,800},{R}},
	{{Blink,1000},{S,800},{R}},
	{{Blink,1000},{C,800},{R}},
	{{Q,700},},
	{{S,800},},
	{{C,800},},
}

function DoomAIClass:PreTick()
	local unit = self.unit
	local hp = unit:GetHealthPercent()
	if hp < 30 then
		self:aiCastAbilityByName(self:GetEnemey(),E)
	end
	return false
end

function DoomAIClass:LateTick()
	return false
end

function DoomAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
end

print('load tempclass ai',AITempClass)
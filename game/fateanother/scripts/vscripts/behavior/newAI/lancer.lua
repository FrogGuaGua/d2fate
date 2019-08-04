_G.LancerAIClass = GameRules.BTreeCMN.Class('LancerAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q1 = "lancer_5th_rune_of_disengage"
local W = "lancer_5th_relentless_spear"
local W1 = "lancer_5th_rune_of_replenishment"
local E = "lancer_5th_rune_of_trap"
local HE = "lancer_5th_wesen_gae_bolg"
local D = ""
local F = ""
local R = "lancer_5th_gae_bolg_jump"
local R1 = "lancer_5th_rune_of_conversion"

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	[HE] = 
	{ 
		time=3,
		abilitys = {W,},
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

--隐藏技能组合
local hide_combos =
{	
	{{W,},{HE,200}},
	{{Blink,1000},{W,},{HE,200}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{W,200}},
	-- {{E,200}},
	-- {{Blink,1000},{E,200}},
	{{C,900},{R}},
	{{S,900},{R}},
	{{R,900}},
	{{S,800},},
	{{C,800},},
}

function LancerAIClass:PreTick()
	return false
end

function LancerAIClass:LateTick()
	local unit = self.unit
	local hp = unit:GetHealthPercent()
	if hp < 30 then
		self:aiCastAbilityByName(W1)
		return true
	end

	local MP = unit:GetMana();
	local maxMP = unit:GetMaxMana()
	local MPPrecent = MP / maxMP * 100
	if hp > 60 and MPPrecent < 50 then
		self:aiCastAbilityByName(self:GetEnemey(),R1)
		return true
	end

	print("LateTick false")
	return false
end

function LancerAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
end

print('load lancer ai',LancerAIClass)
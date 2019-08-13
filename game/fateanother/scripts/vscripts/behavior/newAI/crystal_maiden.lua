_G.CMAIClass = GameRules.BTreeCMN.Class('CMAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'
local HS = 'item_healing_scroll' --群补

--技能
local Q = "caster_5th_argos"
local Q1 = "caster_5th_wall_of_flame"
local W= "caster_5th_ancient_magic"
local W1= "caster_5th_silence"
local E = "caster_5th_rule_breaker"
local E1 = "caster_5th_divine_words"
local HE = ""
local D = "caster_5th_territory_creation"
local F = ""
local R = "caster_5th_hecatic_graea"
local HR = "caster_5th_hecatic_graea_powered"

local abilitys_behavior = {
	[Q] = "self",
	[W1] = "pos",
	[E] = "target",
	[E1] = "pos",
	[D] = "pos", 
	[R] = "pos", 
	[HR] = "pos", 
}
----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = {}

--隐藏技能
local hide_ability_names = {[HR]=true,}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{	
	
	{{C,100},{E,200}},
	{{Blink,900},{C,100},{E,200}},
	{{HR,800}},
	{{Blink,900},{HR,800}},
	
	
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{A,1800}},
	{{B,3000}},
	{{Blink,900},{C,100},{E,150},},
	{{E1,600}},
	{{W1,600}},
	{{Q,2000}},
	{{S,800},},
	{{R,900}},
	{{C,800},},
}

function CMAIClass:PreTick()
	local W1Ablity = self:getAbilityByName(W1)
	local E1Ability = self:getAbilityByName(E1)
	local unit = self.unit

	if W1Ablity:IsHidden() and E1Ability:IsHidden() then
		print('swap')
		unit:SwapAbilities(W, W1, false, true)
		unit:SwapAbilities(W, E1, false, true)
	end

	
	return false
end


function CMAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
	self.abilitys_behavior = abilitys_behavior
end

print('load cm ai',CMAIClass)
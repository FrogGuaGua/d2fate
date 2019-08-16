_G.DrowRangerAIClass = GameRules.BTreeCMN.Class('DrowRangerAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = "atalanta_celestial_arrow"
local W = "atalanta_calydonian_hunt"
local W1= "atalanta_cobweb_shot"
local HW= "atalanta_phoebus_catastrophe_snipe"
local E = "atalanta_traps"
local E1= "atalanta_entangling_trap"
local HE = ""
local D = "atalanta_crossing_arcadia"
local F = "atalanta_traps_close"
local R = "atalanta_tauropolos_new"

local abilitys_behavior = {
	[Q] = "pos",
	[W] = "self",
	[W1] = "pos",
	[HW] = 'target',
	[E1] = "self",
	[D] = "pos", 
	[R] = "pos", 
}

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = {}

--隐藏技能
local hide_ability_names = 
{
	HW,
}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	
}

--隐藏技能组合
local hide_combos =
{	
	[1] = {{HW,3000}},
	[2] = {{W,3000}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	[1] ={{A,1800}},
	[2] ={{B,3000}},
	[3] ={{D,600}},
	[5] ={{W1,2000},},
	[6] ={{E1,2000}},
	[7] ={{R,2000}},
	[8] ={{Q,800}},
	[9] ={{S,900},},
	[10]={{C,900},},
	[4] ={{W,800}},
}

local function IsHWValid(self)
	local hw = self:getAbilityByName(HW)
	return hw:IsCooldownReady()
end

local function IsWValid(self)
	local enemy = self:GetEnemey() 
	local modName = 'modifier_calydonian_hunt'
	if enemy and enemy:HasModifier(modName) then
		local mod = enemy:FindModifierByName(modName)
		if mod and mod:GetModifierStackCount() > 3 then
			print('IsWValid')
			return true
		end
	end

	return false
end

local combo_filters =
{
	[hide_combos[2]] = IsHWValid,
	[combos[4]] = IsWValid,
}


function DrowRangerAIClass:PreTick()
	local W1Ablity = self:getAbilityByName(W1)
	local E1Ability = self:getAbilityByName(E1)
	local unit = self.unit

	if W1Ablity:IsHidden() and E1Ability:IsHidden() then
		print('swap')
		unit:SwapAbilities(E, W1, false, true)
		unit:SwapAbilities(E, E1, false, true)
	end

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
	self.abilitys_behavior = abilitys_behavior
end

print('load drowRanger ai',DrowRangerAIClass)
_G.THAIClass = GameRules.BTreeCMN.Class('THAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = "vlad_rebellious_intent"
local W = "vlad_ceremonial_purge"
local HW = "vlad_combo"
local E = "vlad_cursed_lance"
local D = "vlad_transfusion"
local F = ""
local R = "vlad_kazikli_bey"

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	[HW] = 
	{ 
		time=6,
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
	{A,2500},{B,3000},
}

--隐藏技能combo
local hide_combos =
{
	{{Q},{E},{HW,800}},
	{{Blink,1000},{Q},{E},{HW,800}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{S,600},{R}},
	{{C,600},{R}},
	{{Blink,1000},{S,600},{R}},
	{{Blink,1000},{C,600},{R}},
	{{D,800}},
	{{E,400}},
	{{W,300}},
	{{R,300}},
	{{S,800},},
	{{C,800},},
}

function THAIClass:LateTick()
	print('THAIClass:LateTick')
	local unit = self.unit
	local enemy = self:GetEnemey()
	local selfPos = unit:GetAbsOrigin()
	local enemyPos = enemy:GetAbsOrigin()
	local diff = #(selfPos - enemyPos)
	local ability = unit:FindAbilityByName(Q)
	if self:isAbilityValid(ability) and self:isValidCastAbility() then
		local state = ability:GetToggleState()
		if diff < 800 then
			if state == false then
				ability:ToggleAbility()
				return true
			end
		elseif diff > 2000 then
			if state == true then
				ability:ToggleAbility()
				return true
			end
		end
	end
end

function THAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
end

print('load thClass ai',THAIClass)
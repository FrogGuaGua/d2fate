_G.THAIClass = GameRules.BTreeCMN.Class('THAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'
local HS = 'item_healing_scroll' --群补

--技能
local Q = "vlad_rebellious_intent"
local W = "vlad_ceremonial_purge"
local HW = "vlad_combo"
local E = "vlad_cursed_lance"
local D = "vlad_transfusion"
local D1 = "vlad_impale"
local R = "vlad_kazikli_bey"

local abilitys_behavior = {
	[Q] = "toggle",
	[W] = "self",
	[HW] = "self",
	[E] = "self",
	[D] = "self", 
	[D1] = "pos", 
	[R] = "self", 
}

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = {}

--隐藏技能
local hide_ability_names = {[HW]=true,[D1]=true}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	
}

--隐藏技能combo
local hide_combos =
{
	[1]={{HW,300}},
	[2]={{Q,300},{E}},
	[3]={{Q,300},{E},{Blink,900},},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	[1]	={{A,1800}},
	[2]	={{B,3000}},
	[3]	={{C,200},{R,50}},
	[4]	={{Blink,900},{C,200},{R,50}},
	[5]	={{E,800}},
	[6]	={{W,300},{S,100}},
	[7]	={{R,300}},
	[8]	={{D,800}},
	[9]	={{D1,400}},
	[10]={{S,800},},
	[11]={{C,800},},
}

local function IsRCD(self)
	local ability = self.unit:FindAbilityByName(R)
	return not ability:IsCooldownReady()
end

local function IsHWValid(self)
	local ability = self.unit:FindAbilityByName(HW)
	if ability:IsCooldownReady() then
		return true
	end
	return false
end

local combo_filters =
{
	[hide_combos[2]] = IsHWValid,
	[hide_combos[3]] = IsHWValid,
	[combos[8]] = IsRCD,
}

function THAIClass:LateTick()
	local unit = self.unit
	local enemy = self:GetEnemy()
	local ability = unit:FindAbilityByName(Q)
	
	if self:isAbilityValid(ability) and self:isValidCastAbility() then
		local state = ability:GetToggleState()
		if enemy == nil  then
			if state == true then
				ability:ToggleAbility()
				return true
			end
			return false
		end
		local selfPos = unit:GetAbsOrigin()
		local enemyPos = enemy:GetAbsOrigin()
		local diff = #(selfPos - enemyPos)
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
	self.abilitys_behavior = abilitys_behavior
	self.combo_filters = combo_filters
end

print('load thClass ai',THAIClass)
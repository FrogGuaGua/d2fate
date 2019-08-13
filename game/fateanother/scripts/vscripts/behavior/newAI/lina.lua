_G.LinaAIClass = GameRules.BTreeCMN.Class('LinaAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'
local HS = 'item_healing_scroll' --群补

--技能
local Q = "nero_rosa_ichthys"
local Q1 = "nero_acquire_divinity"
local W = "nero_gladiusanus_blauserum"
local E = "nero_blade_dance"
local HE = "nero_fiery_finale"
local D = ""
local F = "nero_imperial_privilege"
local F1 = "nero_acquire_martial_arts"
local F2 = "nero_close_spellbook"
local R = "nero_aestus_domus_aurea"
local R1 = "nero_acquire_clairvoyance"
--技能释放方式
local abilitys_behavior = {
	[Q] = "target",
	[Q1] = "self",
	[W] = "pos",
	[E] = "target",
	[HE] = "self",
	[R] = "target", 
}

local function isRValid(self)
	if self.unit:HasModifier("modifier_aestus_domus_aurea") then 
		return false 
	end

	return true
end

local function isHEValid(self)
	local unit = self.unit
	if unit.Focus then
		for id=1, #self.ability_queue do
			local data = self.ability_queue[id]
			if data.name == R and data.time + 2 > Time() then
				return true
			end
		end
		return false
	end

	return false
end


local special_ability_condition = 
{
	[R] = isRValid,
	[HE] = isHEValid,
}

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	-- [HE] = 
	-- { 
	-- 	time=0.5,
	-- 	abilitys = {R,},
	-- }
}

--隐藏技能
local hide_ability_names = {[HE]=true}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
}

--隐藏技能组合
local hide_combos =
{	
	{{HE,1000}},
	{{R,1000}},
	{{Blink,900},{R,1000}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{A,1800}},
	{{B,3000}},
	{{Q1,800}},
	{{F1,800}},
	{{R1,800}},
	{{R,1000}},
	{{Blink,900},{R,1000}},
	{{Q,600}},
	{{E,300}},
	{{S,800},},
	{{C,800},},
	{{W,800}},
}

function LinaAIClass:PreTick()
	local unit = self.unit
	local FAbility = unit:FindAbilityByName(F)
	self.FAbilityNames = {Q1,F1,R1}
	self.FAbilityIdx = self.FAbilityIdx == nil and 1 or self.FAbilityIdx
	local ability_name = self.FAbilityNames[self.FAbilityIdx]

	local ability = unit:FindAbilityByName(ability_name)
	if ability:IsHidden() or not ability:IsActivated() then
		if FAbility:IsCooldownReady() then
			print('SwapAbilities',FAbility:GetCooldownTime())
			if self.FAbilityFirst == false then
				self.FAbilityIdx = self.FAbilityIdx + 1
				if self.FAbilityIdx > #self.FAbilityNames then
					self.FAbilityIdx = 1
				end
				ability_name = self.FAbilityNames[self.FAbilityIdx]
			end
			unit:SwapAbilities(F,ability_name, false, true)
			
			self.FAbilityFirst = false
		end
	end

	local HEAbility = unit:FindAbilityByName(HE)
	if HEAbility:IsHidden() then
		unit:SwapAbilities(HE,E, true, true)
	end
	return false
end

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
	self.abilitys_behavior = abilitys_behavior
	--
	self.special_ability_condition = special_ability_condition
end

print('load lina ai',LinaAIClass)
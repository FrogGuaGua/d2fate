_G.LancerAIClass = GameRules.BTreeCMN.Class('LancerAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll_ai'

--技能
local Q1 = "lancer_5th_rune_of_disengage"
local W = "lancer_5th_relentless_spear"
local W1 = "lancer_5th_rune_of_replenishment"
local E = "lancer_5th_gae_bolg"
local E1 = "lancer_5th_rune_of_trap"
local HE = "lancer_5th_wesen_gae_bolg"
local D = "lancer_5th_soaring_spear"
local F = ""
local R = "lancer_5th_gae_bolg_jump"
local R1 = "lancer_5th_rune_of_conversion"

--初始属性
local base_atb = {
	agiltity=5,	--敏捷
	intellect=5,--智力
	strength=5  --力量
}

--技能释放方式
local abilitys_behavior = {
	[Q1] = 'target',
	[W] = 'self',
	[W1] = 'self',
	[E] = 'target',
	[E1] = 'pos',
	[HE] = 'target',
	[D] = 'target',
	[R] = 'pos',
	[R1] = 'self',
}

--连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	-- [HE] = 
	-- { 
	-- 	time=3,
	-- 	abilitys = {W,},
	-- }
}

--隐藏技能
local hide_ability_names = 
{
	HE,
}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	--{A,1800},{B,3000},
}

--隐藏技能组合
local hide_combos =
{	
	{{W,300}},
	{{Blink,900},{W,300}},
	{{HE,300}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{A,2000},},
	{{B,2500},},
	{{D,940},},
	{{C,300},{E},},
	{{S,900},{R},},
	{{R,900},},
	{{Blink,900},{C,300},{E},},
	{{Blink,900},{R,900},},
	{{E,400}},
	{{E1,1000},},
	{{W,280},},
	{{S,800},},
	{{C,800},},
}

function LancerAIClass:PreTick()
	return false
end

function LancerAIClass:LateTick()
	local unit = self.unit
	local hp = unit:GetHealthPercent()
	if hp < 80 then
		self:aiCastAbilityByName(W1)
		return true
	end

	local MP = unit:GetMana();
	local maxMP = unit:GetMaxMana()
	local MPPrecent = MP / maxMP * 100
	if hp > 60 and MPPrecent < 50 then
		self:aiCastAbilityByName(self:GetEnemy(),R1)
		return true
	end

	return false
end

local function SwapAbilitys(unit)
	unit:SwapAbilities(Q, W1, true, true)
	unit:SwapAbilities(Q, E1, true, true)
end

function LancerAIClass:ctor(unit,lvl)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit,lvl)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
	self.abilitys_behavior = abilitys_behavior
	SwapAbilitys(unit)
	self:InitBaseAtb(base_atb)
end

print('load lancer ai',LancerAIClass)
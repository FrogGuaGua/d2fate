_G.SpectreAIClass = GameRules.BTreeCMN.Class('SpectreAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll_ai'

--技能
local Q = 'saber_alter_derange'
local W = 'saber_alter_mana_burst'
local HW = 'saber_alter_max_mana_burst'
local E = 'saber_alter_vortigern'
local F = 'saber_alter_unleashed_ferocity'
local R = 'saber_alter_excalibur'

local ATT = 'attribute_bonus_custom'
--升级技能表
local ability_upgrade =
{
	{[Q] = 4}, {[W] = 4}, {[E] = 4}, {[R] = 4}, {[ATT] = 7},
}

--初始属性
local base_atb = {
	agiltity=10,	--敏捷
	intellect=10,--智力
	strength=5  --力量
}

--技能释放方式
local abilitys_behavior = {
	[Q] = "self",
	[W] = "self",
	[HW] = "self",
	[E] = "pos",
	[F] = "self", 
	[R] = "pos", 
}

--隐藏技能,AI刷新无法刷新
local hide_ability_names = {[HW]=true}
local combo_abilitys = {}

local secFightAbility = 
{
	
}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{
	[1]={{HW,200},},
	[2]={{Q,200},{F},},
	[3]={{Q,200},{F},{Blink,900}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{A,1800}},
	{{B,3000}},
	{{F,400}},
	{{F,300},{Blink,900},},
	{{E,500}},
	{{Blink,900},{E,400}},
	{{C,500},{W,200}},
	{{W,200}},
	{{Q,8000}},
	{{S,800},},
	{{R,1100}},
	{{C,800},},
}

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
}

function SpectreAIClass:ctor(unit,lvl)
	print('unit',unit,unit:GetName())
	print('SpectreAIClass self ',self)
	self.super.ctor(self,unit,lvl)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.hide_ability_names = hide_ability_names
	self.combo_abilitys = combo_abilitys
	self.combo_filters = combo_filters
	self.abilitys_behavior = abilitys_behavior
	self:InitBaseAtb(base_atb)
	self.ability_upgrade = ability_upgrade
end

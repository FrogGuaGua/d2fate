_G.HaskarAIClass = GameRules.BTreeCMN.Class('HaskarAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll_ai'

--技能
local Q = "diarmuid_warriors_charge"
local W = "diarmuid_double_spearsmanship"
local HW = "diarmuid_rampant_warrior"
local E = "diarmuid_gae_buidhe"
local D = "diarmuid_love_spot"
local F = ""
local R = "diarmuid_gae_dearg"

local ATT = 'attribute_bonus_custom'
--升级技能表
local ability_upgrade =
{
	{[E] = 4},{[R] = 4}, {[W] = 4}, {[ATT] = 7},{[Q] = 4}, 
}

--初始属性
local base_atb = {
	agiltity=10,	--敏捷
	intellect=10,--智力
	strength=10  --力量
}

--技能释放方式
local abilitys_behavior = {
	[Q] = "target",
	[W] = "self",
	[HW] = "self",
	[E] = "target",
	[D] = "self", 
	[R] = "target", 
}

local combo_abilitys = {}

--隐藏技能
local hide_ability_names = {[HW]=true,[D]=true}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	
}

--隐藏技能组合
local hide_combos =
{	
	{{HW,300}},
	{{D,300},},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{A,1800}},
	{{B,3000}},
	{{D,800},},
	{{C,500},{R,500}},
	{{E,300},},
	{{R,400}},
	{{Blink,900},{C,500},{R}},
	{{S,800},},
	{{Q,500},},
	{{W,350},},
	{{C,800},},
}

function HaskarAIClass:PreTick()
	return self.super.PreTick(self)
end

function HaskarAIClass:LateTick()
	return false
end

function HaskarAIClass:ctor(unit,lvl)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit,lvl)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
	self.abilitys_behavior = abilitys_behavior
	self.lvl = lvl
	self:InitBaseAtb(base_atb)
	--过滤mod
	self.filterMod = {
		modifier_avalon = true , -- 无敌
	}
	self.ability_upgrade = ability_upgrade
end

print('load huskar ai',HaskarAIClass)
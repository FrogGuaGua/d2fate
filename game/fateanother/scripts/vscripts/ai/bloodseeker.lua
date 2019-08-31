_G.BloodAIClass = GameRules.BTreeCMN.Class('BloodAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll_ai'

--技能
local Q = 'lishuwen_concealment'
local W = 'lishuwen_cosmic_orbit'
local E = 'lishuwen_fierce_tiger_strike'
local E1 = 'lishuwen_fierce_tiger_strike_2'
local E2 = 'lishuwen_fierce_tiger_strike_3'
local HE = 'lishuwen_raging_dragon_strike'
local HE1 = 'lishuwen_raging_dragon_strike_2'
local HE2 = 'lishuwen_raging_dragon_strike_3'
local D = 'lishuwen_martial_arts'
local F = 'lishuwen_berserk'
local R = 'lishuwen_no_second_strike'

local ATT = 'attribute_bonus_custom'
--升级技能表
local ability_upgrade =
{
	 {[E] = 4}, {[R] = 4},  {[ATT] = 7},{[W] = 4},{[Q] = 4},
}

--初始属性
local base_atb = {
	agiltity=4,	--敏捷
	intellect=12,--智力
	strength=12  --力量
}

--技能释放方式
local abilitys_behavior = {
	[Q] = 'self',
	[W] = 'self',
	[E] = 'target',
	[E1] = 'target',
	[E2] = 'self',
	[HE] = 'target',
	[HE1] = 'target',
	[HE2] = 'self',
	[D] = 'target',
	[R] = 'target',
}

--隐藏技能,AI刷新无法刷新
local hide_ability_names = {[HE]=true,[HE1]=true,[HE2]=true,}

local combo_abilitys = {
}

--隐藏技能
local hide_ability_names = 
{
	lishuwen_raging_dragon_strike=true,
	lishuwen_raging_dragon_strike_2=true,
	lishuwen_raging_dragon_strike_3=true,
}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = {}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{	
	{{W,600}},
	{{Blink,900},{W,600}},
	{{HE,600}},
	{{HE1,600}},
	{{HE2,600}},
	{{Blink,900},{HE,600}},
	{{Blink,900},{HE1,600}},
	{{Blink,900},{HE2,600}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{	
	{{A,1800}},
	{{B,2500}},
	{{C,150},{R,200}},
	{{Blink,900},{C,200},{R,200}},
	{{E,400}},
	{{E1,400}},
	{{E2,3000}},
	{{C,800},},
	{{F,600}},
	{{D,600}},
	{{W,1200}},
	{{S,800},},
}



function BloodAIClass:ctor(unit,lvl)
	self.super.ctor(self,unit,lvl)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
	self.abilitys_behavior = abilitys_behavior
	self:InitBaseAtb(base_atb)
	self.ability_upgrade = ability_upgrade
end

print('load blooadseeker ai',BloodAIClass)
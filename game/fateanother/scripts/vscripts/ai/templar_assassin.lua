_G.TaAIClass = GameRules.BTreeCMN.Class('TaAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll_ai'

--技能
local Q = 'rider_5th_nail_swing'
local W = 'rider_5th_breaker_gorgon'
local E = 'rider_5th_bloodfort_andromeda'
local HE = 'rider_5th_bellerophon_2'
local R = 'rider_5th_bellerophon'

--初始属性
local base_atb = {
	agiltity=5,	--敏捷
	intellect=5,--智力
	strength=5  --力量
}

--技能释放方式
local abilitys_behavior = {
	[Q] = 'self',
	[W] = 'pos',
	[E] = 'self',
	[HE] = 'pos',
	[R] = 'pos',
}

--隐藏技能
local hide_ability_names = {[HE]=true}

local secFightAbility = 
{
	
}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{
	{{Q,2000},{W},},
	{{Q,2000},{W},{Blink,900}},
	{{HE,2000}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{A,1800},},
	{{B,3000},},
	{{S,600},},
	{{R,1200},},
	{{Blink,900},{R,1200},},
	{{Q,400},},
	{{W,400},},
	{{C,800},{E},},
	{{E,500},},
	{{S,800},},
}


function TaAIClass:ctor(unit,lvl)
	print('unit',unit,unit:GetName())
	print('TaAIClass self ',self)
	self.super.ctor(self,unit,lvl)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.hide_ability_names = hide_ability_names
	self.abilitys_behavior = abilitys_behavior
	self:InitBaseAtb(base_atb)
end

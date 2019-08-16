_G.JuggAIClass = GameRules.BTreeCMN.Class('JuggAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll_ai'

--技能
local Q = 'false_assassin_gate_keeper'
local Q1 = 'false_assassin_quickdraw'
local W = 'false_assassin_heart_of_harmony'
local HW = 'false_assassin_tsubame_mai'
local E = 'false_assassin_windblade'
local D = 'false_assassin_minds_eye'
local R = 'false_assassin_tsubame_gaeshi'

local master2 = {0,1,2,4,5}

--初始属性
local base_atb = {
	agiltity=5,	--敏捷
	intellect=5,--智力
	strength=5  --力量
}

--技能释放方式
local abilitys_behavior = {
	[Q] = "self",
	[Q1] = "pos",
	[W] = "self",
	[HW] = "self",
	[E] = "self",
	[D] = "target",
	[R] = "target", 
}

--技能释放方式
local abilitys_moming = {
	[Q] = "self",
	[Q1] = "pos",
	[W] = "self",
	[HW] = "self",
	[E] = "self",
	[D] = "target",
	[R] = "target", 
}


--隐藏技能
local hide_ability_names = {[HW]=true,[Q1]=true}


----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = {}

local hide_condition ={agiltity=25,strength=25}

local secFightAbility = 
{
	--{A,1800},{B,3000},
}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{
	{{HW,500},},
	{{Q,300},},
	{{Q,300},{Blink,900},},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{A,1800}},
	{{B,2500}},
	{{W,600}},
	{{Q,600}},
	{{E,400}},
	{{Blink,900},{E,400}},
	{{C,240},{R,300,}},
	{{R,300}},
	{{Q1,600}},
	{{Q1,600},{Blink,900},},
	{{D,200}},
	{{S,800},},
}

function JuggAIClass:PreTick()
	--这个英雄有个未知BUG，某些逻辑会触发bot 导致W的CD变成40秒。
	--变成40秒，直接刷新
	local unit = self.unit
	local abilityW = unit:FindAbilityByName(W)
	if abilityW:GetCooldownTime() > 30 then
		abilityW:EndCooldown()
	end

end


function JuggAIClass:ctor(unit,lvl)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit,lvl)
	self.firstRefreshCD = 5
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.hide_ability_names = hide_ability_names
	self.combo_abilitys = combo_abilitys
	self.abilitys_behavior = abilitys_behavior
	self.master2 = master2
	self.comboSelectType = 'hp'
	self.wushimoming = true
	self.hide_condition = hide_condition
	self:InitBaseAtb(base_atb)
	--过滤mod
	self.filterMod = {
		modifier_avalon = true , -- 无敌
	}
end

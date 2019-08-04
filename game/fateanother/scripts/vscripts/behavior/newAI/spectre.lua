_G.SpectreAIClass = GameRules.BTreeCMN.Class('SpectreAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = 'saber_alter_derange'
local W = 'saber_alter_mana_burst'
local W1 = 'saber_alter_max_mana_burst'
local E = 'saber_alter_vortigern'
local F = 'saber_alter_unleashed_ferocity'
local R = 'saber_alter_excalibur'

--隐藏技能,AI刷新无法刷新
local hide_ability_names = {saber_alter_max_mana_burst=true}

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = {
	[W1] = 
	{
		time = 5,
		abilitys = {Q,F},
	},
}

local secFightAbility = 
{
	{A,2500},{B,3000},{Q,1000},
}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{
	{{Q,1700},{F},},
	{{W1,750},},
	{{Blink,1000},{W1,750},},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{E,400}},
	{{R,600}},
	{{S,800},{R}},
	{{C,800},{R}},
	{{Blink,1000},{S,800},{R}},
	{{Blink,1000},{C,800},{R}},
	{{Blink,1000},{E,500}},
	{{F},{Blink,1100}},
	{{W,200}},
	{{Blink,1000},{W,100}},
	{{S,800},},
	{{C,800},},
}


function SpectreAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('SpectreAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.hide_ability_names = hide_ability_names
	self.combo_abilitys = combo_abilitys
end

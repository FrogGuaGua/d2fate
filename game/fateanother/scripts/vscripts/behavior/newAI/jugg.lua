_G.JuggAIClass = GameRules.BTreeCMN.Class('JuggAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'

--技能
local Q = 'false_assassin_gate_keeper'
local W = 'false_assassin_heart_of_harmony'
local W1 = 'false_assassin_tsubame_mai'
local E = 'false_assassin_windblade'
local D = 'false_assassin_minds_eye'
local R = 'false_assassin_tsubame_gaeshi'



--隐藏技能
local hide_ability_names = {false_assassin_tsubame_mai=true}

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = {
	[W1] = 
	{
		time = 4,
		abilitys = {Q},
	}
}

local hide_condition ={agiltity=25,strength=25}

local secFightAbility = 
{
	{A,2500},{B,3000},
}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{
	{{Q,200},{W1},},
	{{Q,200},{W1},{Blink,900},},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{Q,600}},
	{{W,600}},
	{{E,400}},
	{{Blink,1000},{E,400}},
	{{R,100}},
	{{D,1000}},
	{{S,800},},
	{{C,800},},
}


function JuggAIClass:ctor(unit)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.hide_ability_names = hide_ability_names
	self.combo_abilitys = combo_abilitys
end

_G.LCAIClass = GameRules.BTreeCMN.Class('LCAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll_ai'

--技能
local Q = "saber_invisible_air"
local W = "saber_caliburn"
local E = "saber_excalibur"
local HE = "saber_max_excalibur"
local D = "saber_strike_air"
local F = "saber_improved_instinct"
local R = "saber_avalon"

local ATT = 'attribute_bonus_custom'
--升级技能表
local ability_upgrade =
{
	{[Q] = 4}, {[W] = 4}, {[E] = 4}, {[R] = 4}, {[ATT] = 7},
}

--初始属性
local base_atb = {
	agiltity=5,	--敏捷
	intellect=5,--智力
	strength=5  --力量
}

--技能释放方式
local abilitys_behavior = {
	[Q] = "target",
	[W] = "target",
	[E] = "pos",
	[HE] = "pos",
	[D] = "pos",
	[F] = "self", 
	[R] = "self", 
}

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
	-- [HE] = 
	-- { 
	-- 	time=6,
	-- 	abilitys = {R},
	-- }
}

--隐藏技能
local hide_ability_names = {[HE]=true,[D]=true}


local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	
}

--隐藏技能需要满足隐藏条件才会考虑
local hide_combos =
{
	[ 1] = {{Blink,100},{R,400}},
	[ 2] = {{R,1800}},
	[ 3] = {{HE,1800}},
}


--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{A,1800},},
	{{B,3000},},
	{{F,450},},
	{{Blink,900},{W,200},{S,50},},
	{{Q,200}},
	{{W,200}},
	{{E,1000}},
	{{S,900},{D,}},
	{{C,900},{D,}},
	{{D,800}},
	{{R,900}},
	{{S},{E,900}},
	{{C},{E,900}},
	{{S,800},},
	{{C,800},},
}

function LCAIClass:getAbilityBehavior(abilityName)
	if abilityName == Blink then
		if self.curCombo.combo == hide_combos[1] then
			--如果是隐藏1combo blink的方式改为后跳
			return 'back_pos' 
		end
	end
	return self.super.getAbilityBehavior(self,abilityName)
end
function LCAIClass:OnRefreshCD()
	local unit= self.unit
	local enemy = self:GetEnemy()
	if self:ValidTarget(enemy) then
		local selfPos = unit:GetAbsOrigin()
		local enemyPos = unit:GetAbsOrigin()
		local diff = selfPos - enemyPos
		if #(diff) < 500 then
			if #diff < 10 then
				diff = Vector(1,0,0)
			else 
				diff = diff:Normalized()
			end
			local pos = diff * 900 + selfPos
			local blink = self:getAbilityByName(Blink)
			print('OnRefreshCD',selfPos,enemyPos,pos)
			self:aiCastAbility(unit,blink,pos)
		end
	end
end

function LCAIClass:ctor(unit,lvl)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
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

print('load LCAIClass ai',LCAIClass)
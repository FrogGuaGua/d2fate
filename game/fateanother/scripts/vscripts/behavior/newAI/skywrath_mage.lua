_G.SkyWrathAIClass = GameRules.BTreeCMN.Class('SkyWrathAIClass',BaseAIClass)
local S = 'item_s_scroll_ai'
local C = 'item_c_scroll_ai'
local A = 'item_a_scroll_ai'
local B = 'item_b_scroll_ai'
local Blink = 'item_blink_scroll'
local HS = 'item_healing_scroll' --群补

--技能
local Q = "gilgamesh_enkidu"
local W = "gilgamesh_gram"
local E = "gilgamesh_gate_of_babylon"
local HE = ""
local D = "gilgamesh_gram"
local F = "gilgamesh_sword_barrage_improved"
local R = "gilgamesh_enuma_elish"
local HR = "gilgamesh_max_enuma_elish"

local abilitys_behavior = {
	[Q] = "target",
	[W] = "target",
	[E] = "pos",
	[D] = "toggle",
	[F] = "pos", 
	[D] = "pos", 
	[R] = "pos", 
	[HR] = "pos", 
}

----连招技能，需要特定顺序的技能才能使用
local combo_abilitys = 
{
}

--隐藏技能
local hide_ability_names = {[HR]=true}

local hide_condition ={agiltity=20,intellect=20,strength=20}

local secFightAbility = 
{
	
}

local function AwayBlink(self)
	local unit= self.unit
	local enemy = self:GetEnemy()
	if enemy then
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

--隐藏技能组合
local hide_combos =
{	
	{{AwayBlink},{HR,1500}},
	{{E,1000}},
}

--技能组合
--优先级从上到下
--元素 {技能名字,施法距离比例}
local combos = 
{
	{{A,1800}},
	{{B,3000}},
	{{E,800}},
	{{Blink,900},{C,200},{E,300}},
	{{Q,600}},
	{{C,800},},
	{{W,800}},
	{{F,600}},
	{{S,800},},
	{{C,800},},
	{{R,1000}},
}

function SkyWrathAIClass:OnRefreshCD()
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


function SkyWrathAIClass:LateTick()
	return false
end

function SkyWrathAIClass:ctor(unit,lvl)
	print('unit',unit,unit:GetName())
	print('JuggAIClass self ',self)
	self.super.ctor(self,unit,lvl)
	self.secFightAbility = secFightAbility
	self.combos = combos
	self.hide_combos = hide_combos
	self.combo_abilitys = combo_abilitys
	self.hide_ability_names = hide_ability_names
	self.abilitys_behavior = abilitys_behavior
end

print('load skywrath ai',SkyWrathAIClass)
local BTreeCMN = GameRules.BTreeCMN
local AIHelper = {}
GameRules.AIHelper = AIHelper

local TimerMgr = BTreeCMN.Class('TimerMgr')
function TimerMgr:ctor()
	self.timers = {}
end

function TimerMgr:AddTimer(name,duration,loop)
	local timer = self.timers[name]
	if timer then
		local cur_stamp = Time()
		if timer.stamp < cur_stamp or not loop then
			return
		end
	end
	--------BTreeCMN.Print(('----timer %s',name)
	timer = { stamp = Time()+duration , loop = loop }
	self.timers[name] = timer

	if name == 'dead'then
		BTreeCMN.Print(' dead add stamp %s Time() %s',timer.stamp , Time())
	end
end

function TimerMgr:DelTimer(name)
	self.timers[name] = nil
end

function TimerMgr:IsEnd(name)
	local timer = self.timers[name]
	--------BTreeCMN.Print(('TimerMgr:IsEnd(name)')
	if timer then
		local stamp = timer.stamp
		local cur_stamp = Time()
		
		if stamp < cur_stamp then
			return 'True'
		end

		if name == 'dead'then
			BTreeCMN.Print('dead stamp %s cur_stamp %s',stamp , cur_stamp)
		end
		return 'False'
	end
	--------BTreeCMN.Print(('------BNOEXIST %s ',name)
	return 'NoExist'
end

local IntVarMgr = BTreeCMN.Class("IntVarMgr")

function IntVarMgr:ctor()
	self.vars = {}
end

function IntVarMgr:AddIntVar(name,val)
	self.vars[name] = val
end

function IntVarMgr:DelIntVar(name)
	self.vars[name] = nil
end

function IntVarMgr:CmpIntVar(name,val,cmp)
	local var = self.vars[name]
	if var == nil then
		return false
	end

	if cmp == IntVarCmpType.Less then
		return var < val
	elseif cmp == IntVarCmpType.LessOrEqual then
		return var <= val
	elseif cmp == IntVarCmpType.Equal then
		return var == val
	elseif cmp == IntVarCmpType.Greater then
		return var > val
	elseif cmp == IntVarCmpType.GreaterOrEqual then
		return var >= val
	end

	return true
end

local function stateprint(entity)
	print('GetCooldownTimeRemaining',entity:GetAbilityByIndex(5):GetCooldownTimeRemaining() )
end

function AIHelper.InitEntityAI(entity,btf)
	local AIMgr = {}
	AIMgr.timerMgr = TimerMgr.new()
	AIMgr.intVarMgr = IntVarMgr.new()

	entity.AIMgr = AIMgr
	local root = GameRules.G_BehaviorTreeMgr:GetBtf(btf)
	entity:SetContextThink( "AIThink",function(entity) 
			root:process(entity)
			return 0.25
		end
		, 0.25 )
end

function AIHelper.RemoveAI(entity)
	entity.AIMgr = nil
	entity:SetContextThink("AIThink", function() return 0 end, 0.25)
	GameRules.AIFunc.ClearAllData(entity)
end
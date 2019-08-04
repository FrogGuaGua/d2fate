print('ActionNode load ..')
local BTreeCMN = GameRules.BTreeCMN
local BaseNode = GameRules.BaseNode
do 

  local AIFuncAction = BTreeCMN.Class('AIFuncAction',BaseNode)
  BTreeCMN.NodeClassList['AIFuncAction'] = AIFuncAction

  function AIFuncAction:ctor()
    self.super.ctor(self)

    self.func = nil
    self.name = ""
    self.args = {}
    self.argCnt = 8 --参数个数
    for i=1 ,self.argCnt do
      table.insert(self.args,"")
    end
  end

  function AIFuncAction:passParam(_jsonData)
    self.super.passParam(self,_jsonData)
    
    for i , data in ipairs(_jsonData) do
      local key,val = self:passParamData(data)
      if key == 'name' then
      	self.name = val
        local func_name_tb = string.split(val,'.')
        local search_space = { GameRules.AIFunc , GameRules , _G }
        local func = nil
        for _ , space in ipairs(search_space) do
          func = space
          local curId = nil
          for id , name in ipairs(func_name_tb) do
            if func == nil then
              break
            end
            func = func[name]
            curId = id
          end
          if type(func) == 'function' and curId == #func_name_tb then
            self.func = func
            break
          end
        end
      else
      	if string.find(key,'arg') then
      		local idx = string.sub(key,4)
      		self.args[tonumber(idx)] = val
      	end
      end
    end
  end

  function AIFuncAction:process(entity)
    self.super.process(self,entity)
    print('AIFuncAction',self.name)
    if self.func then
      return self.func(entity,self.args )
    end
    return false
  end

end

do 
	local SetPosActionNode = BTreeCMN.Class('SetPosActionNode',BaseNode)
	BTreeCMN.NodeClassList['SetPosActionNode'] = SetPosActionNode

	local refer_type_enum = { player = 1, }

	function SetPosActionNode:ctor()
		self.super.ctor(self)

		self.refer_type = refer_type_enum.player
		self.dis = 0
	end

	function SetPosActionNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)
		
		for i , data in ipairs(_jsonData) do
			local k = data['key']
			local var = data['value']
			if k == 'refer_type' then
				self.refer_type = tonumber(var)
			elseif k == 'dis' then
				self.dis = tonumber(var)
			end
		end
	end

	function SetPosActionNode:process(entity)
		self.super.process(self,entity)
		
		local pos = nil
		if self.refer_type == refer_type_enum.player then
			pos = GetPlayerVector()
		end
		
		if pos then
			local vec = GetRandCircleVec(pos,self.dis)
			entity:SetAbsOrigin(vec)
			return true
		end
		return false
	end
end

do 
	local CastAbilityActionNode = BTreeCMN.Class('CastAbilityActionNode',BaseNode)
	BTreeCMN.NodeClassList['CastAbilityActionNode'] = CastAbilityActionNode
	function CastAbilityActionNode:ctor()
		self.super.ctor(self)

		self.target_type = 1
		self.pos_type = 1
		self.ability_name = ""
		self.ability_type = AbilityType.Self
		self.ability_idx = 0
	end

	function CastAbilityActionNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)
		
		for i , data in ipairs(_jsonData) do
			local key = data['key']
			local var = data['value']
			if key == 'target_type' then
				self.target_type = tonumber(var) 
			elseif key == 'pos_type' then
				self.pos_type = tonumber(var)
			elseif key == 'ability_type' then
				self.ability_type = tonumber(var)
			elseif key == 'ability_idx' then
				self.ability_idx = tonumber(var)
			end
		end
	end

	function CastAbilityActionNode:process(entity)
		self.super.process(self,entity)
		
		local target_pos = nil
		if self.target_type == 1 then
			target_pos = GetPlayerVector()
		end
		
		local ability = nil
		if self.ability_type == AbilityType.Self then
			ability = entity:GetAbilityByIndex(self.ability_idx)
			--BTreeCMN.Print(('ability~~ %s',ability)
		elseif self.ability_type == AbilityType.Item then
			ability = entity:GetItemInSlot(self.ability_idx)
		end

		if ability == nil then
			return false
		end

		if target_pos then
			if self.pos_type == 0 then
				local hero = GetPlayerHero()
				CastAbilityToPlayer(entity,ability)
				return true
			elseif self.pos_type == 1 then
				local pos = GetBestCastAbilityPoint(ability,entity:GetAbsOrigin() ,target_pos)
				entity:CastAbilityOnPosition(pos,ability,0) 
				--BTreeCMN.Print(('target_pos %s pos %s',target_pos,pos)
				return true
			elseif self.pos_type == 2 then
				--print(string.format('vsvsvs---!!!!23',hero))
				entity:CastAbilityOnTarget(entity,ability,-1)
				return true
			
			end
		end
		return false
	end
end

do 
	local CastAbility1ActionNode = BTreeCMN.Class('CastAbility1ActionNode',BaseNode)
	BTreeCMN.NodeClassList['CastAbility1ActionNode'] = CastAbility1ActionNode
	function CastAbility1ActionNode:ctor()
		self.super.ctor(self)

		self.target_type = "player"
		self.pos_type = "best"
		self.ability_type = AbilityType.Self
		self.ability_idx = 0
		self.func = 1
		self.add_dis = {0,0}
	end

	function CastAbility1ActionNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)
		
		for i , data in ipairs(_jsonData) do
			local key = data['key']
			local var = data['value']
			if key == 'target_type' then
				self.target_type = var
			elseif key == 'pos_type' then
				self.pos_type = var
			elseif key == 'ability_type' then
				self.ability_type = tonumber(var)
			elseif key == 'ability_idx' then
				self.ability_idx = tonumber(var)
			elseif key == 'func' then
				self.func = tonumber(var)
			elseif key == 'add_dis' then
				self.add_dis = SplitStrToNumArr(var)
			end
		end
	end

	function CastAbility1ActionNode:process(entity)
		self.super.process(self,entity)
		
		local target = nil
		local target_type = self.target_type

		if target_type == 'self' then
			target = entity
		elseif target_type == 'player' then
			target = GetPlayerHero()
		else
      		target = Entities:FindAllByName(target_type)
		end
		if target == nil then
			return false
		end

		local ability = nil
		if self.ability_type == AbilityType.Self then
			ability = entity:GetAbilityByIndex(self.ability_idx)
			--BTreeCMN.Print(('ability~~ %s',ability)
		elseif self.ability_type == AbilityType.Item then
			ability = entity:GetItemInSlot(self.ability_idx)
		end

		if ability == nil then
			return false
		end

		BTreeCMN.Print('CastAbility1ActionNode %s',ability:GetAbilityName())
		local self_pos = entity:GetAbsOrigin()
		local target_pos = nil
		local pos_type = self.pos_type
		if pos_type == 'self' then
			target_pos = self_pos
		elseif pos_type == 'player' then
			target_pos = GetPlayerHero():GetAbsOrigin()
		elseif pos_type == 'best' then
			target_pos = GetBestCastAbilityPoint(ability,entity:GetAbsOrigin() ,GetPlayerHero():GetAbsOrigin())
		end
		
		if #self.add_dis > 0 then
			for i=1 , #self.add_dis/2 do
				local distype = self.add_dis[i*2-1]
				local dis = self.add_dis[i*2]
				BTreeCMN.Print('distype %s dis %s',distype,dis)
				if distype == 0 then
					target_pos = (target_pos - self_pos):Normalized()*dis + target_pos
				elseif distype == 1 then
					target_pos = (target_pos - self_pos):Normalized()*dis + self_pos
				end
			end
		end

		local func_id = self.func
		BTreeCMN.Print('func_id %s',self.func)
		if func_id == 1 then
			entity:CastAbilityNoTarget(ability, 0) 
		elseif func_id == 2 then
			BTreeCMN.Print('CastAbilityOnPosition target_pos %s',target_pos)
			entity:CastAbilityOnPosition(target_pos,ability, 0) 
		elseif func_id == 3 then
			BTreeCMN.Print('CastAbilityOnTarget')
			entity:CastAbilityOnTarget(target,ability, 0) 
		elseif func_id == 4 then
			entity:CastAbilityToggle(ability,-1)
		end
		return true
	end
end

do 
	local AddTimerActionNode = BTreeCMN.Class('AddTimerActionNode',BaseNode)
	BTreeCMN.NodeClassList['AddTimerActionNode'] = AddTimerActionNode

	local loop_enum = {once=0 , loop= 1}
	function AddTimerActionNode:ctor()
		self.super.ctor(self)

		self.name = ""
		self.duration = 0
		self.loop = false
	end

	function AddTimerActionNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)
		
		for i , data in ipairs(_jsonData) do
			local key = data['key']
			local var = data['value']
			if key == 'name' then
				self.name = var
			elseif key == 'duration' then
				self.duration = tonumber(var)
			elseif key == 'loop' then
				self.loop = var == '1'
			end
		end
	end

	function AddTimerActionNode:process(entity)
		self.super.process(self,entity)
		
		local AIMgr = entity.AIMgr
		--BTreeCMN.Print(('self.name %s',self.name)
		AIMgr.timerMgr:AddTimer(self.name,self.duration/1000,self.loop)
		return true
	end
end

do 
	local DelTimerActionNode = BTreeCMN.Class('DelTimerActionNode',BaseNode)
	BTreeCMN.NodeClassList['DelTimerActionNode'] = DelTimerActionNode

	local loop_enum = {once=0 , loop= 1}
	function DelTimerActionNode:ctor()
		self.super.ctor(self)

		self.name = ""
		self.duration = 0
		self.loop = false
	end

	function DelTimerActionNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)
		
		for i , data in ipairs(_jsonData) do
			local key = data['key']
			local var = data['value']
			if key == 'name' then
				self.name = var
			end
		end
	end

	function DelTimerActionNode:process(entity)
		self.super.process(self,entity)
		
		local AIMgr = entity.AIMgr
		AIMgr.timerMgr:DelTimer(self.name)
		return true
	end
end

do 
	local IntVarAssignActionNode = BTreeCMN.Class('IntVarAssignActionNode',BaseNode)
	BTreeCMN.NodeClassList['IntVarAssignActionNode'] = IntVarAssignActionNode

	function IntVarAssignActionNode:ctor()
		self.super.ctor(self)

		self.name = ""
		self.value = 0
	end

	function IntVarAssignActionNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)
		
		for i , data in ipairs(_jsonData) do
			local key = data['key']
			local var = data['value']
			if key == 'name' then
				self.name = var
			elseif key == 'value' then
				self.value = tonumber(var)
			end
		end
	end

	function IntVarAssignActionNode:process(entity)
		self.super.process(self,entity)
		
		local AIMgr = entity.AIMgr
		--BTreeCMN.Print(('IntVarAssignActionNode %s %s',self.name,self.value)
		AIMgr.intVarMgr:AddIntVar(self.name,self.value)
		return true
	end
end

do 
	local DelIntVarActionNode = BTreeCMN.Class('DelIntVarActionNode',BaseNode)
	BTreeCMN.NodeClassList['DelIntVarActionNode'] = DelIntVarActionNode

	function DelIntVarActionNode:ctor()
		self.super.ctor(self)

		self.name = ""
	end

	function DelIntVarActionNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)
		
		for i , data in ipairs(_jsonData) do
			local key = data['key']
			local var = data['value']
			if key == 'name' then
				self.name = var
			end
		end
	end

	function DelIntVarActionNode:process(entity)
		self.super.process(self,entity)
		
		local AIMgr = entity.AIMgr
		AIMgr.intValMgr:DelIntVar(self.name)
		return true
	end
end

do 
	local DelIntVarActionNode = BTreeCMN.Class('DelIntVarActionNode',BaseNode)
	BTreeCMN.NodeClassList['DelIntVarActionNode'] = DelIntVarActionNode

	function DelIntVarActionNode:ctor()
		self.super.ctor(self)

		self.name = ""
	end

	function DelIntVarActionNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)
		
		for i , data in ipairs(_jsonData) do
			local key = data['key']
			local var = data['value']
			if key == 'name' then
				self.name = var
			end
		end
	end

	function DelIntVarActionNode:process(entity)
		self.super.process(self,entity)
		
		local AIMgr = entity.AIMgr
		AIMgr.intValMgr:DelIntVar(self.name)
		return true
	end
end

do 
	local SpeechBubbleActionNode = BTreeCMN.Class('SpeechBubbleActionNode',BaseNode)
	BTreeCMN.NodeClassList['SpeechBubbleActionNode'] = SpeechBubbleActionNode

	function SpeechBubbleActionNode:ctor()
		self.super.ctor(self)
		self.text = ""
		self.duration = 1000
	end

	function SpeechBubbleActionNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)
		
		for i , data in ipairs(_jsonData) do
			local key = data['key']
			local var = data['value']
			if key == 'text' then
				self.text = var
			elseif key == 'duration' then
				self.duration = tonumber(var)
			end
		end
	end

	function SpeechBubbleActionNode:process(entity)
		self.super.process(self,entity)

		--AddSpeechBubble(entity:GetEntityIndex(),self.text,self.duration)
		return true
	end
end

do 
	local ForceKilledActionNode = BTreeCMN.Class('ForceKilledActionNode',BaseNode)
	BTreeCMN.NodeClassList['ForceKilledActionNode'] = ForceKilledActionNode

	function ForceKilledActionNode:ctor()
		self.super.ctor(self)
	end

	function ForceKilledActionNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)
	end

	function ForceKilledActionNode:process(entity)
		self.super.process(self,entity)
		--print('dead -forcekill--')
		--entity:Kill(nil,GetPlayerHero())
		entity:Destroy()
		--entity:ForceKill(false)
		return true
	end
end

do 
	local MoveActionNode = BTreeCMN.Class('MoveActionNode',BaseNode)
	BTreeCMN.NodeClassList['MoveActionNode'] = MoveActionNode

	function MoveActionNode:ctor()
		self.super.ctor(self)

		self.target = 'player'
		self.type = 1
	end

	function MoveActionNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)

		for i , data in ipairs(_jsonData) do
			local key = data['key']
			local var = data['value']
			if key == 'target' then
				self.target = var
			elseif key == 'type' then
				self.type = tonumber(var)
			end
		end
	end

	function MoveActionNode:process(entity)
		self.super.process(self,entity)

		local target = nil
		if self.target == 'player' then
			target = GetPlayerHero()
		else
			target = Entities:FindAllByName(self.target)
		end 

		if target == nil then
			return false
		end

		local target_pos = target:GetAbsOrigin()
		if self.type == 1 then
			entity:MoveToNPC(target)
			--entity:MoveToPosition(target_pos)
		elseif self.type == 2 then
			local self_pos = entity:GetAbsOrigin()
			local diff = target_pos - self_pos
		end

		return true
	end
end

do 
	local FowardToTargetActionNode = BTreeCMN.Class('FowardToTargetActionNode',BaseNode)
	BTreeCMN.NodeClassList['FowardToTargetActionNode'] = FowardToTargetActionNode

	function FowardToTargetActionNode:ctor()
		self.super.ctor(self)
		self.target_type = 'player'
	end

	function FowardToTargetActionNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)
		for i , data in ipairs(_jsonData) do
			local key = data['key']
			local var = data['value']
			if key == 'target' then
				self.target_type = var
			end
		end
	end

	function FowardToTargetActionNode:process(entity)
		self.super.process(self,entity)
		local target_type = self.target_type
		local target = nil
		if target_type == 'player' then
			target = GetPlayerHero()
		else
			target = Entities:FindAllByName(target_type)
		end

		if target == nil then
			return false
		end

		local target_pos = target:GetAbsOrigin()
		local self_pos = entity:GetAbsOrigin()
		local dir = target_pos - self_pos
		entity:SetForwardVector(dir:Normalized())
		return true
	end

end

do 
	local SelectMoveTargetAction = BTreeCMN.Class('SelectMoveTargetAction',BaseNode)
	BTreeCMN.NodeClassList['SelectMoveTargetAction'] = SelectMoveTargetAction

	function SelectMoveTargetAction:ctor()
		self.super.ctor(self)
		self.range = 1800
	end

	function SelectMoveTargetAction:passParam(_jsonData)
		self.super.passParam(self,_jsonData)
		for i , data in ipairs(_jsonData) do
			local key = data['key']
			local var = data['value']
			if key == 'range' then
				self.range = tonumber(var)
			end
		end
	end

	function SelectMoveTargetAction:process(entity)
		self.super.process(self,entity)
		local selfTeam = entity:GetTeam()
		local selfPos = entity:GetAbsOrigin()
		local target = nil
		local minDist = 1000000

		local heroList = HeroList:GetAllHeroes()
		for _ , hero in pairs(heroList) do
	        if hero:GetTeam() ~= selfTeam then
	        	local targetPos = hero:GetAbsOrigin()
	        	local dist = #(targetPos - selfPos)
	        	if dist < self.range and dist < minDist then
	        		target = hero
	        		minDist = dist
	        	end
	        end
		end

		if target then
			entity.moveTarget = target
			print('entity.moveTarget ',target)
		end
		return true
	end

end
local BTreeCMN = GameRules.BTreeCMN
local BaseNode = GameRules.BaseNode
require 'behavior/AIDef'

do 
  local CheckTimerStatusCond = BTreeCMN.Class('CheckTimerStatusCond',BaseNode)
  BTreeCMN.NodeClassList['CheckTimerStatusCond'] = CheckTimerStatusCond

  local operator_type_enum = { IsEnd = 1, IsExist = 2 }

  function CheckTimerStatusCond:ctor()
    self.super.ctor(self)

    self.name = ""
    self.operator = operator_type_enum.IsEnd
  end

  function CheckTimerStatusCond:passParam(_jsonData)
    self.super.passParam(self,_jsonData)
    
    for i , data in ipairs(_jsonData) do
      local key,val = self:passParamData(data)
      if key == 'name' then
        --BTreeCMN.Print(('CheckTimerStatusCond %s ',val)
        self.name = val
      elseif key == 'operator' then
        self.operator = tonumber(val)
      end
    end
  end

  function CheckTimerStatusCond:process(entity)
    self.super.process(self,entity)
    local AIMgr = entity.AIMgr
    local timerMgr = AIMgr.timerMgr
    local rst = timerMgr:IsEnd(self.name)
    --BTreeCMN.Print(('timerMgr:IsEnd(%s) operator %s rst %s ',self.name,self.operator,rst)
    if self.operator == operator_type_enum.IsEnd then
       local ret =rst == 'True'
        --BTreeCMN.Print(('timerMgr:IsEnd----%s',ret)
       return ret
    elseif self.operator == operator_type_enum.IsExist then
      return rst ~= "NoExist"
    end
    return false
  end
end

do 
  local CmpIntVarCond = BTreeCMN.Class('CmpIntVarCond',BaseNode)
  BTreeCMN.NodeClassList['CmpIntVarCond'] = CmpIntVarCond

  function CmpIntVarCond:ctor()
    self.super.ctor(self)

    self.name = ""
    self.value = 0
    self.operator = IntVarCmpType.IsExist
  end

  function CmpIntVarCond:passParam(_jsonData)
    self.super.passParam(self,_jsonData)
    
    for i , data in ipairs(_jsonData) do
      local key,var = self:passParamData(data)
      if key == 'var_name' then
        self.name = var
      elseif key == 'value' then
        self.value = tonumber(var)
      elseif key == 'operator' then
        self.operator = tonumber(var) 
      end
    end
  end

  function CmpIntVarCond:process(entity)
    self.super.process(self,entity)
    local AIMgr = entity.AIMgr
    local intVarMgr = AIMgr.intVarMgr
    local ret = intVarMgr:CmpIntVar(self.name,self.value,self.operator)
    --BTreeCMN.Print(('ret %s %s %s %s',ret,self.name,self.value,self.operator)
    return ret
  end
end

do 
  local TestAbilityCond = BTreeCMN.Class('TestAbilityCond',BaseNode)
  BTreeCMN.NodeClassList['TestAbilityCond'] = TestAbilityCond

  function TestAbilityCond:ctor()
    self.super.ctor(self)

    self.target_type = 'player'
    self.ability_radius = 1
    self.offset = {}
  end

  function TestAbilityCond:passParam(_jsonData)
    self.super.passParam(self,_jsonData)
    
    for i , data in ipairs(_jsonData) do
      local key,var = self:passParamData(data)
      if key == 'target_type' then
        self.target_type = var
      elseif key == 'ability_radius' then
        self.ability_radius = tonumber(var)
      elseif key == 'offset' then
        self.offset = SplitStrToNumArr(var)
      end
    end
  end

  function TestAbilityCond:process(entity)
    self.super.process(self,entity)
    --BTreeCMN.Print(('------TestAbilityCond')
    local target = nil

    if self.target_type == 'player' then
      target = GetPlayerHero()
    else
      target = Entities:FindAllByName(target_type)
    end

    if target == nil then
      return false;
    end

    local target_pos = target:GetAbsOrigin();
    local self_pos = entity:GetAbsOrigin();
    local diff = target_pos - self_pos

    for i=1,(#self.offset)/2 do
      if self.offset[i*2-1] == 0 then
        if #diff < self.offset[i*2] then
          return true;
        end
        self_pos = self_pos + diff:Normalized()*self.offset[i*2]
      elseif self.offset[i*2-1] == 1 then
        self_pos = self_pos + entity:GetForwardVector():Normalized()*self.offset[i*2]
      end
    end

    diff = target_pos - self_pos
    return #diff < self.ability_radius
  end
end

do 
  local IsAbilityCond = BTreeCMN.Class('IsAbilityCond',BaseNode)
  BTreeCMN.NodeClassList['IsAbilityCond'] = IsAbilityCond

  function IsAbilityCond:ctor()
    self.super.ctor(self)

    self.ability_idx = 0
    self.ability_type = 0
  end

  function IsAbilityCond:passParam(_jsonData)
    self.super.passParam(self,_jsonData)
    
    for i , data in ipairs(_jsonData) do
      local key,var = self:passParamData(data)
      if key == 'ability_type' then
        self.ability_type = tonumber(var) 
      elseif key == 'ability_idx' then
        self.ability_idx = tonumber(var)
      elseif key == 'check_type' then
        self.check_type = tonumber(var)
      end
    end
  end

  function IsAbilityCond:process(entity)
    self.super.process(self,entity)
    local ability    
    if self.ability_type == 1 then
      ability = entity:GetAbilityByIndex(self.ability_idx)
    elseif self.ability_type == 2 then
       ability = entity:GetItemInSlot(self.ability_idx)
    end

    local ability = entity:GetAbilityByIndex(self.ability_idx)
    if ability == nil then
      return false
    end
    if self.check_type == 1 or self.check_type == nil then
        return ability:GetCooldownTimeRemaining() <= 0
    elseif self.check_type == 2 then
        return not ability:IsInAbilityPhase()
    end

    return ability:GetCooldownTimeRemaining() <= 0
  end
end


atalanta_entangling_trap = class({})
LinkLuaModifier("modifier_atalanta_trap", "abilities/atalanta/modifier_atalanta_trap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_entangle", "abilities/atalanta/modifier_entangle", LUA_MODIFIER_MOTION_NONE)


function atalanta_entangling_trap:GetCastRange(vLocation,hTarget)
  return self:GetSpecialValueFor("cast_range")
end
function atalanta_entangling_trap:GetAOERadius()
  return self:GetSpecialValueFor("entangle_radius")
end

if IsClient() then
  return 
end

function atalanta_entangling_trap:VFX1_Entangle(hTarget,hDummyCenter,fEntangleDuration)
  --local PI = ParticleManager:CreateParticle("particles/custom/atalanta/entangle/pair_tree.vpcf", PATTACH_ABSORIGIN_FOLLOW, hDummyCenter)
  local PI = ParticleManager:CreateParticle("particles/custom/atalanta/entangle_better/pair_tree.vpcf", PATTACH_ABSORIGIN_FOLLOW, _G.ParticleDummy)
  ParticleManager:SetParticleControlEnt(PI, 0, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetAbsOrigin(), true)
  ParticleManager:SetParticleControlEnt(PI, 1, hDummyCenter, PATTACH_ABSORIGIN_FOLLOW, nil, hDummyCenter:GetAbsOrigin(), true)
  ParticleManager:SetParticleControl(PI, 2, Vector(fEntangleDuration,0,0))
  return PI
end
function atalanta_entangling_trap:DestroyAllVFX(bInstant,hDummy,PI1,PI2,PI3)
  FxDestroyer(PI1,bInstant)
  FxDestroyer(PI2,bInstant)
  FxDestroyer(PI3,bInstant)
  hDummy:RemoveSelf()
end
function atalanta_entangling_trap:CalculateCenterFor2(hTarget1,hTarget2)
  local vTarget1 = hTarget1:GetAbsOrigin()
  local vTarget2 = hTarget2:GetAbsOrigin()
  local fCenterX = (vTarget1.x + vTarget2.x)/2
  local fCenterY = (vTarget1.y + vTarget2.y)/2
  local vCenter = GetGroundPosition(Vector(fCenterX, fCenterY, 0),self:GetCaster())
  return vCenter
end
function atalanta_entangling_trap:CalculateCenterFor3(hTarget1,hTarget2,hTarget3)
  local vTarget1 = hTarget1:GetAbsOrigin()
  local vTarget2 = hTarget2:GetAbsOrigin()
  local vTarget3 = hTarget3:GetAbsOrigin()
  local fCenterX = (vTarget1.x + vTarget2.x + vTarget3.x)/3
  local fCenterY = (vTarget1.y + vTarget2.y + vTarget3.y)/3
  local vCenter = GetGroundPosition(Vector(fCenterX, fCenterY, 0),self:GetCaster())
  return vCenter
end

function atalanta_entangling_trap:EntanglePunishCheck(vCenter,hTarget,fEntanglePunishRange)
  local vPos = hTarget:GetAbsOrigin()
  local fDistToCenter = (vCenter - vPos):Length2D()
  if fDistToCenter > fEntanglePunishRange then 
    self:ActivationPull(hTarget,vCenter,fEntanglePunishRange)
    return true
  end
  return false
end

function atalanta_entangling_trap:EntangleDownscaleCheck(hTarget)
  if not hTarget:IsAlive() or hTarget:IsMagicImmune() then 
    return true
  end
  return false
end

function atalanta_entangling_trap:EntanglePunish(hTarget)
  local hCaster = self:GetCaster()
  local fStunDuration = self:GetSpecialValueFor("stun_duration")
  local fDamage = self:GetSpecialValueFor("damage")
  giveUnitDataDrivenModifier(hCaster, hTarget, "stunned", fStunDuration)
  hTarget:EmitSound("Atalanta.TrapSnap")
  DoDamage(hCaster, hTarget, fDamage, DAMAGE_TYPE_MAGICAL, 0, self, false)
end

function atalanta_entangling_trap:OnSpellStart()
  local hCaster = self:GetCaster()
  local vLocation = self:GetCursorPosition()
  if self.hTrap ~= nil and not self.hTrap:IsNull() then
    self.hTrap:RemoveSelf()
  end  
  self.hTrap = CreateUnitByName("atalanta_trap", vLocation, true, hCaster, hCaster, hCaster:GetTeam())
  self.hTrap:AddNewModifier(hCaster,self,"modifier_atalanta_trap",{Duration = -1})
  self:TrapThink(self.hTrap)
  hCaster:CloseTraps(self)
end

function atalanta_entangling_trap:TrapThink(hTrap)
  local hCaster = self:GetCaster()
  local fTriggerRadius = self:GetSpecialValueFor("trigger_radius")
  local fArmDelay = self:GetSpecialValueFor("arm_delay")
  
  Timers:CreateTimer(fArmDelay,function()
    if not hTrap:IsNull() and hTrap:IsAlive() then
      local tTargets = FindUnitsInRadius(hCaster:GetTeam(), hTrap:GetAbsOrigin(), nil, fTriggerRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)  
      for k,v in pairs(tTargets) do
        if v ~= nil then
          self:Activate(v, hTrap)
          return nil
        end
      end
      return 0.1
    else
      return nil
    end
  end)
end
function atalanta_entangling_trap:ActivationPull(hTarget,vCenter,fTargetsDistPull)
  local vPos = hTarget:GetAbsOrigin()
  local vToCenter = vCenter - vPos
  local fDistToCenter = vToCenter:Length2D()
  local fDiff = fDistToCenter - fTargetsDistPull
  if fDiff > 0 then 
    FindClearSpaceForUnit(hTarget,vPos + vToCenter:Normalized()*fDiff,true)
  end
end

function atalanta_entangling_trap:Activate(hTarget, hTrap)
  local fEntangleRadius = self:GetSpecialValueFor("entangle_radius")
  local hCaster = self:GetCaster()
  local fCounter = 0.0
  local fTargetsDistPull = self:GetSpecialValueFor("initial_pull")
  local hDummy = SpawnDummy(hCaster)  

  local tTargets = FindUnitsInRadius(hCaster:GetTeam(), hTarget:GetAbsOrigin(), nil, fEntangleRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)  
  for i = 1,3 do 
    if tTargets[i] ~= nil then
      tTargets[i]:AddNewModifier(self:GetCaster(),self,"modifier_entangle",{Duration = self:GetSpecialValueFor("entangle_duration")})
    end
  end
  if #tTargets == 1 then 
    hDummy:SetAbsOrigin(hTrap:GetAbsOrigin())
    self:EntangleThinkFor1(fCounter,tTargets[1],hDummy)    
  elseif #tTargets == 2 then 
    local vCenter = self:CalculateCenterFor2(tTargets[1],tTargets[2])
    self:ActivationPull(tTargets[1],vCenter,fTargetsDistPull)
    self:ActivationPull(tTargets[2],vCenter,fTargetsDistPull) 
    self:EntangleThinkFor2(fCounter,tTargets[1],tTargets[2],hDummy)    
  elseif #tTargets >= 3 then 
    local vCenter = self:CalculateCenterFor3(tTargets[1],tTargets[2],tTargets[3])
    self:ActivationPull(tTargets[1],vCenter,fTargetsDistPull)
    self:ActivationPull(tTargets[2],vCenter,fTargetsDistPull)  
    self:ActivationPull(tTargets[3],vCenter,fTargetsDistPull)
    self:EntangleThinkFor3(fCounter,tTargets[1],tTargets[2],tTargets[3],hDummy)  
  end
  local PI = ParticleManager:CreateParticle("particles/custom/atalanta/trap_triggered.vpcf", PATTACH_ABSORIGIN, hCaster)
  ParticleManager:SetParticleControl(PI, 0, hTrap:GetAbsOrigin())
  tTargets[1]:EmitSound("Hero_Windrunner.ShackleshotCast")
  hTrap:RemoveSelf()
  self.hTrap = nil
end

function atalanta_entangling_trap:EntangleThinkFor1(fCounter,hTarget1,hDummy)
  local fEntanglePunishRange = self:GetSpecialValueFor("entangle_punish_dist")
  local fEntangleDuration = self:GetSpecialValueFor("entangle_duration")
  local fInterval = 0.033
  local PI1 = self:VFX1_Entangle(hTarget1,hDummy,fEntangleDuration-fCounter)
  
  Timers:CreateTimer(function()
    fCounter = fCounter + fInterval
    if fCounter < fEntangleDuration then
      local vT1Pos = hTarget1:GetAbsOrigin()
      local bT1Check = self:EntanglePunishCheck(hDummy:GetAbsOrigin(),hTarget1,fEntanglePunishRange)
      if bT1Check then
        self:EntanglePunish(hTarget1)
        self:DestroyAllVFX(false,hDummy,PI1)
        return nil
      end
      return fInterval     
    else 
      self:DestroyAllVFX(false,hDummy,PI1)
      return nil
    end
  end)
end

function atalanta_entangling_trap:EntangleThinkFor2(fCounter,hTarget1,hTarget2,hDummy)
  local fEntanglePunishRange = self:GetSpecialValueFor("entangle_punish_dist")
  local fEntangleDuration = self:GetSpecialValueFor("entangle_duration")
  local fInterval = 0.033
  local PI1 = self:VFX1_Entangle(hTarget1,hDummy,fEntangleDuration-fCounter)
  local PI2 = self:VFX1_Entangle(hTarget2,hDummy,fEntangleDuration-fCounter)
  
  Timers:CreateTimer(function()
    fCounter = fCounter + fInterval
    if fCounter < fEntangleDuration then
      local bT1DownscaleCheck = self:EntangleDownscaleCheck(hTarget1)
      local bT2DownscaleCheck = self:EntangleDownscaleCheck(hTarget2)
      if bT1DownscaleCheck then
        self:DestroyAllVFX(true,hDummy,PI1,PI2)
        self:EntangleThinkFor1(fCounter,hTarget2,hDummy)
        return nil
      end
      if bT2DownscaleCheck then
        self:DestroyAllVFX(true,hDummy,PI1,PI2)
        self:EntangleThinkFor1(fCounter,hTarget1,hDummy)
        return nil
      end  
      local vCenter = self:CalculateCenterFor2(hTarget1,hTarget2)
      local bT1Check = self:EntanglePunishCheck(vCenter,hTarget1,fEntanglePunishRange)
      local bT2Check = self:EntanglePunishCheck(vCenter,hTarget2,fEntanglePunishRange)
      if bT1Check or bT2Check then
        self:EntanglePunish(hTarget1)
        self:EntanglePunish(hTarget2)
        self:DestroyAllVFX(false,hDummy,PI1,PI2)
        return nil
      end
      hDummy:SetAbsOrigin(vCenter) 
      return fInterval     
    else 
      self:DestroyAllVFX(false,hDummy,PI1,PI2)
      return nil
    end
  end)
end

function atalanta_entangling_trap:EntangleThinkFor3(fCounter,hTarget1,hTarget2,hTarget3,hDummy)
  local fEntanglePunishRange = self:GetSpecialValueFor("entangle_punish_dist")
  local fEntangleDuration = self:GetSpecialValueFor("entangle_duration")
  local fInterval = 0.033
  local PI1 = self:VFX1_Entangle(hTarget1,hDummy,fEntangleDuration-fCounter)
  local PI2 = self:VFX1_Entangle(hTarget2,hDummy,fEntangleDuration-fCounter)
  local PI3 = self:VFX1_Entangle(hTarget3,hDummy,fEntangleDuration-fCounter)
  
  Timers:CreateTimer(function()
    fCounter = fCounter + fInterval
    if fCounter < fEntangleDuration then
      local bT1DownscaleCheck = self:EntangleDownscaleCheck(hTarget1)
      local bT2DownscaleCheck = self:EntangleDownscaleCheck(hTarget2)
      local bT3DownscaleCheck = self:EntangleDownscaleCheck(hTarget3)
      if bT1DownscaleCheck then
        self:DestroyAllVFX(true,hDummy,PI1,PI2,PI3)
        self:EntangleThinkFor2(fCounter,hTarget2,hTarget3,hDummy)
        return nil
      end
      if bT2DownscaleCheck then
        self:DestroyAllVFX(true,hDummy,PI1,PI2,PI3)
        self:EntangleThinkFor2(fCounter,hTarget1,hTarget2,hDummy)
        return nil
      end  
      if bT3DownscaleCheck then
        self:DestroyAllVFX(true,hDummy,PI1,PI2,PI3)
        self:EntangleThinkFor2(fCounter,hTarget1,hTarget2,hDummy)
        return nil
      end      
      local vCenter = self:CalculateCenterFor3(hTarget1,hTarget2,hTarget3)
      local bT1Check = self:EntanglePunishCheck(vCenter,hTarget1,fEntanglePunishRange)
      local bT2Check = self:EntanglePunishCheck(vCenter,hTarget2,fEntanglePunishRange)
      local bT3Check = self:EntanglePunishCheck(vCenter,hTarget3,fEntanglePunishRange)
      if bT1Check or bT2Check or bT3Check then
        self:EntanglePunish(hTarget1)
        self:EntanglePunish(hTarget2)
        self:EntanglePunish(hTarget3)
        self:DestroyAllVFX(false,hDummy,PI1,PI2,PI3)
        return nil
      end        
      hDummy:SetAbsOrigin(vCenter) 
      return fInterval     
    else 
      self:DestroyAllVFX(false,hDummy,PI1,PI2,PI3)
      return nil
    end
  end)
end
atalanta_cobweb_shot = class({})
LinkLuaModifier("modifier_cobweb_slow", "abilities/atalanta/modifier_cobweb_slow", LUA_MODIFIER_MOTION_NONE)

function atalanta_cobweb_shot:GetCastRange(vLocation,hTarget)
  return self:GetSpecialValueFor("max_range_of_bounce")
end

if IsClient() then
  return 
end

--courtesy of BMD's physics
function atalanta_cobweb_shot:FindWallVector(vVelocity, vWallPos, vUnitPos)
  local navX = GridNav:WorldToGridPosX(vWallPos.x)
  local navY = GridNav:WorldToGridPosY(vWallPos.y)
  local navPos = Vector(GridNav:GridPosToWorldCenterX(navX), GridNav:GridPosToWorldCenterY(navY), 0)
  
  local dir = navPos - vUnitPos
  dir.z = 0
  dir = dir:Normalized()
  local normal = Vector(0,0,0)
  local diff = vVelocity:Normalized()
  
  if dir:Dot(Vector(1,0,0)) > .707 then
    normal = Vector(1,0,0)
    local navPos2 = navPos + Vector(-64,0,0)
    local navConnect2 = not GridNav:IsTraversable(navPos2) or GridNav:IsBlocked(navPos2)
    if navConnect2 then
      if vVelocity.y > 0 then
        normal = Vector(0,1,0)
        navPos2 = navPos + Vector(0,-64,0)
        navConnect2 = not GridNav:IsTraversable(navPos2) or GridNav:IsBlocked(navPos2)
        if navConnect2 then
          normal = Vector(diff.x * -1, diff.y * -1, diff.z)
        end
      else
        normal = Vector(0,-1,0)
        navPos2 = navPos + Vector(0,64,0)
        navConnect2 = not GridNav:IsTraversable(navPos2) or GridNav:IsBlocked(navPos2)
        if navConnect2 then
          normal = Vector(diff.x * -1, diff.y * -1, diff.z)
        end
      end
    end
  elseif dir:Dot(Vector(-1,0,0)) > .707 then
    normal = Vector(-1,0,0)
    local navPos2 = navPos + Vector(64,0,0)
    local navConnect2 = not GridNav:IsTraversable(navPos2) or GridNav:IsBlocked(navPos2)
    if navConnect2 then
      if vVelocity.y > 0 then
        normal = Vector(0,1,0)
        navPos2 = navPos + Vector(0,-64,0)
        navConnect2 = not GridNav:IsTraversable(navPos2) or GridNav:IsBlocked(navPos2)
        if navConnect2 then
          normal = Vector(diff.x * -1, diff.y * -1, diff.z)
        end
      else
        normal = Vector(0,-1,0)
        navPos2 = navPos + Vector(0,64,0)
        navConnect2 = not GridNav:IsTraversable(navPos2) or GridNav:IsBlocked(navPos2)
        if navConnect2 then
          normal = Vector(diff.x * -1, diff.y * -1, diff.z)
        end
      end
    end
  elseif dir:Dot(Vector(0,1,0)) > .707 then
    normal = Vector(0,1,0)
    local navPos2 = navPos + Vector(0,-64,0)
    local navConnect2 = not GridNav:IsTraversable(navPos2) or GridNav:IsBlocked(navPos2)
    if navConnect2 then
      if vVelocity.x > 0 then
        normal = Vector(1,0,0)
        navPos2 = navPos + Vector(-64,0,0)
        navConnect2 = not GridNav:IsTraversable(navPos2) or GridNav:IsBlocked(navPos2)
        if navConnect2 then
          normal = Vector(diff.x * -1, diff.y * -1, diff.z)
        end
      else
        normal = Vector(-1,0,0)
        navPos2 = navPos + Vector(64,0,0)
        navConnect2 = not GridNav:IsTraversable(navPos2) or GridNav:IsBlocked(navPos2)
        if navConnect2 then
          normal = Vector(diff.x * -1, diff.y * -1, diff.z)
        end
      end
    end
  elseif dir:Dot(Vector(0,-1,0)) > .707 then
    normal = Vector(0,-1,0)
    local navPos2 = navPos + Vector(0,64,0)
    local navConnect2 = not GridNav:IsTraversable(navPos2) or GridNav:IsBlocked(navPos2)
    if navConnect2 then
      if vVelocity.x > 0 then
        normal = Vector(-1,0,0)
        navPos2 = navPos + Vector(-64,0,0)
        navConnect2 = not GridNav:IsTraversable(navPos2) or GridNav:IsBlocked(navPos2)
        if navConnect2 then
          normal = Vector(diff.x * -1, diff.y * -1, diff.z)
        end
      else
        normal = Vector(0,-1,0)
        navPos2 = navPos + Vector(64,0,0)
        navConnect2 = not GridNav:IsTraversable(navPos2) or GridNav:IsBlocked(navPos2)
        if navConnect2 then
          normal = Vector(diff.x * -1, diff.y * -1, diff.z)
        end
      end
    end
  end  
  return normal
end



function atalanta_cobweb_shot:OnSpellStart()
  local hCaster = self:GetCaster()
  local vTarget = self:GetCursorPosition()
  local vOrigin = hCaster:GetAbsOrigin()
  local vFacing = ForwardVForPointGround(hCaster,vTarget)
  local fArrowInterval = 0.033
  local fEffectInterval = 0.33
  local fBounceSpeedMod = 1
  local iMaxBounce = self:GetSpecialValueFor("number_of_webs")
  local fMaxTravelDist = self:GetSpecialValueFor("max_range_of_bounce")
  local fWebDuration = self:GetSpecialValueFor("web_duration")
  local fSpeed = 2250
  local iCurrentBounce = 0
  local fWebWidth = 70
  local fDamagePerSec = self:GetSpecialValueFor("dps")
  local fWebLockDuration = self:GetSpecialValueFor("web_lock_duration")
  local fWebSlowDuration = 0.4
  local fWebSlowAmount = self:GetSpecialValueFor("web_slow")
  CustomNetTables:SetTableValue("sync","atalanta_web", {fSlow = fWebSlowAmount})
  local vLastPos = vOrigin  
  local vVelocity = vFacing * fSpeed
  local tBounceLocs = {}
  local tAlreadyLockedOnce = {}
  local vLastBounce = vOrigin 
  hCaster:CloseTraps(self)
  hCaster:UseArrow(1)
  hCaster:EmitSound("Hero_DrowRanger.FrostArrows")
  FxDestroyer(self.PIWebs, false)
  if self.ThinkerArrow then Timers:RemoveTimer(self.ThinkerArrow) end
  if self.ThinkerWebDuration then Timers:RemoveTimer(self.ThinkerWebDuration) end
  if self.ThinkerWebEffect then Timers:RemoveTimer(self.ThinkerWebEffect) end
  if self.hActiveArrow then
    FxDestroyer(self.PICurrentStrand, false)
    FxDestroyer(self.PIArrow, false)
    self.hActiveArrow:RemoveSelf()
    self.hActiveArrow = nil
  end  

  self.PIWebs = {}
  self.hActiveArrow = SpawnDummy(hCaster,vOrigin,vFacing)  
  self.PIArrow = ParticleManager:CreateParticle("particles/custom/atalanta/cobweb_arrow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.hActiveArrow)
  
  self.ThinkerArrow = Timers:CreateTimer(function()
    local fDistTraveled = (vLastBounce - vLastPos):Length2D()    
    if not self.hActiveArrow:IsNull() and iCurrentBounce <= iMaxBounce and fDistTraveled < fMaxTravelDist then
      local vNewPos = GetGroundPosition(vLastPos + vVelocity * fArrowInterval, self.hActiveArrow)
      if GridNav:IsBlocked(vNewPos) or not GridNav:IsTraversable(vNewPos) then
        local vWallN = self:FindWallVector(vVelocity, vNewPos, vLastPos)
        local vNewVelocity = ((-2 * vVelocity:Dot(vWallN) * vWallN) + vVelocity) * fBounceSpeedMod
        vFacing = vNewVelocity / (fSpeed * fBounceSpeedMod)
        vVelocity = vFacing * fSpeed

        self.hActiveArrow:SetForwardVector(vFacing)
        table.insert(tBounceLocs, vLastPos)
        vLastBounce = vLastPos

        if iCurrentBounce > 0 then 
          self.PIWebs[iCurrentBounce] = ParticleManager:CreateParticle("particles/custom/atalanta/cobweb_web.vpcf", PATTACH_ABSORIGIN_FOLLOW, _G.ParticleDummy)
          --ParticleManager:SetParticleControl(self.PIWebs[iCurrentBounce-1], 0, Vector(1,1,1))
          ParticleManager:SetParticleControl(self.PIWebs[iCurrentBounce], 2, tBounceLocs[iCurrentBounce])
          ParticleManager:SetParticleControl(self.PIWebs[iCurrentBounce], 3, tBounceLocs[iCurrentBounce+1])          
        end
        --local PI1 = FxCreator("particles/custom/atalanta/cobweb_arrow_bounce.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.hActiveArrow, 3, nil)
        local PI1 = ParticleManager:CreateParticle("particles/custom/atalanta/cobweb_arrow_bounce.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.hActiveArrow)
        ParticleManager:SetParticleControl(PI1, 3, vNewPos)
        self.hActiveArrow:EmitSound("Hero_DrowRanger.ProjectileImpact")
        --fDistTraveled = 0.0
        iCurrentBounce = iCurrentBounce + 1
      else
        self.hActiveArrow:SetAbsOrigin(vNewPos)
        vLastPos = vNewPos
        --fDistTraveled = fDistTraveled + (vVelocity * fArrowInterval):Length()
        if iCurrentBounce > 0 then 
          FxDestroyer(self.PICurrentStrand, false)
          self.PICurrentStrand =  ParticleManager:CreateParticle("particles/custom/atalanta/cobweb_web_current.vpcf", PATTACH_ABSORIGIN_FOLLOW, _G.ParticleDummy)
          --ParticleManager:SetParticleControl(self.PICurrentStrand, 0, Vector(1,1,1))
          ParticleManager:SetParticleControl(self.PICurrentStrand, 2, tBounceLocs[iCurrentBounce])
          ParticleManager:SetParticleControl(self.PICurrentStrand, 3, vLastPos)--]]
        end
      end

      return fArrowInterval
    else
      FxDestroyer(self.PICurrentStrand, false)
      FxDestroyer(self.PIArrow, false)
      self.hActiveArrow:RemoveSelf()
      self.hActiveArrow = nil
      self.ThinkerWebDuration = Timers:CreateTimer(fWebDuration,function()
        Timers:RemoveTimer(self.ThinkerWebEffect)
        FxDestroyer(self.PIWebs, false)
        return nil
      end)
      return nil
    end
  end)  
  
  self.ThinkerWebEffect = Timers:CreateTimer(function()
    if #tBounceLocs > 1 then
      local tAlreadyHitThisTick = {}
      for i = 1, #tBounceLocs-1 do
        local tTargets = FindUnitsInLine(hCaster:GetTeamNumber(),tBounceLocs[i],tBounceLocs[i+1],hCaster,fWebWidth, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0)
        for k,v in pairs(tTargets) do
          local bAlreadyHit = false
          for l,b in pairs(tAlreadyHitThisTick) do
            if v == b then
              bAlreadyHit = true
              break
            end
          end
          if not bAlreadyHit then 
            local bWasLocked = false
            for l,b in pairs(tAlreadyLockedOnce) do
              if v == b then 
                bWasLocked = true
                break
              end
            end
            table.insert(tAlreadyHitThisTick, v)
            v:AddNewModifier(hCaster, self, "modifier_cobweb_slow", { Duration = fWebSlowDuration, fSlow = fWebSlowAmount})
            DoDamage(hCaster, v, fDamagePerSec * fEffectInterval, DAMAGE_TYPE_MAGICAL, 0, self, false)
            if not bWasLocked then
              giveUnitDataDrivenModifier(hCaster, v, "locked", fWebLockDuration)
              giveUnitDataDrivenModifier(hCaster, v, "rooted", fWebLockDuration)
              table.insert(tAlreadyLockedOnce,v)
            end
          end
        end
      end
    end
    return fEffectInterval
  end)
end
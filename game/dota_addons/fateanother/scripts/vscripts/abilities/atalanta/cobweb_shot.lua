atalanta_cobweb_shot = class({})

if IsClient() then
  return 
end

function atalanta_cobweb_shot:Facing(vTarget,vOrigin)
  local vDisplacement, vFacing = vTarget - vOrigin
  if math.abs(vDisplacement.x) < 0.05 then
    vDisplacement.x = 0
  end
  if math.abs(vDisplacement.y) < 0.05 then
    vDisplacement.y = 0
  end
  vDisplacement.z = 0
  if vDisplacement == Vector(0, 0, 0) then
    vFacing = hCaster:GetForwardVector()
  else
    vFacing = vDisplacement:Normalized()
  end  
  return vFacing
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
  local vFacing = self:Facing(vTarget, vOrigin)  
  local fInterval = 0.033
  
  local hArrow = CreateUnitByName("visible_dummy_unit", vOrigin, false, hCaster, hCaster, hCaster:GetTeamNumber())
  hArrow:FindAbilityByName("dummy_visible_unit_passive"):SetLevel(1)
  hArrow:SetDayTimeVisionRange(0)
  hArrow:SetNightTimeVisionRange(0)
  hArrow:SetAbsOrigin(vOrigin)
  hArrow:SetForwardVector(vFacing)
  hArrow.vLastPos = vOrigin
  hArrow.fSpeed = 1500
  hArrow.vFacing = vFacing
  hArrow.vVelocity = hArrow.vFacing * hArrow.fSpeed

  local fCounter = 0.0
  Timers:CreateTimer(function()
    fCounter = fCounter + fInterval
    if not hArrow:IsNull() and fCounter < 10 then
      local vNewPos = GetGroundPosition(hArrow.vLastPos + hArrow.vVelocity * fInterval, hArrow)
      if GridNav:IsBlocked(vNewPos) or not GridNav:IsTraversable(vNewPos) then
        print("bounce")
        local vWallN = self:FindWallVector(hArrow.vVelocity, vNewPos, hArrow.vLastPos)
        local vNewVelocity = (-2 * hArrow.vVelocity:Dot(vWallN) * vWallN) + hArrow.vVelocity
        hArrow.vVelocity = vNewVelocity
        hArrow.vFacing = vNewVelocity / hArrow.fSpeed
        --hArrow:SetForwardVector(hArrow.vFacing) --need proper model to check if need orient change first
      else
        DebugDrawCircle(hArrow:GetAbsOrigin(), Vector(255,0,0), 0.5, 500, true, 0.5)
        hArrow:SetAbsOrigin(vNewPos)
        hArrow.vLastPos = vNewPos
      end

      return fInterval
    else
      hArrow:RemoveSelf()
      return nil
    end
  end)  
end
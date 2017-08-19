gilgamesh_enuma_elish = class({})
gilgamesh_enuma_elish_activate = class({})

if not IsServer() then
  return
end

Wrappers.ChargedBeam(gilgamesh_enuma_elish,gilgamesh_enuma_elish_activate)

---[[------------this function is not needed, merely for testing and adjusting numbers
function gilgamesh_enuma_elish:GetTestPrints()
  print("channeling:  "..self.channel_charge.."  channeltime: "..GameRules:GetGameTime()-self:GetChannelStartTime())
  local damage_total = self:GetBeamDamage()
  local bonus_base_total, bonus_per_charge = self:__Formula("damage_charge_start", "damage_charge_end", "damage_total")
  local damage_bonus_add = self:__Formula("add1_charge_start", "add1_charge_end", "damage_total", bonus_per_charge)
  print("DMG BONUS ADD:   ",damage_bonus_add,"    base bonus total: ", bonus_base_total, "   dmg total :   ",damage_total)
  local endradius_total = self:GetBeamEndRadius()
  local bonus_base_total_radius = self:__Formula("endradius_charge_start","endradius_charge_end","endradius_total")
  --print("RADIUSEND BONUS base bonus total: ", bonus_base_total_radius, "   radius total :   ",endradius_total)
end
--]]

function gilgamesh_enuma_elish:VFX1_Red_Aura(caster)
  --FxDestroyer(self.PI1, false)
  self.PI1 = ParticleManager:CreateParticle("particles/custom/gilgamesh/gilgamesh_enuma_elish_charge_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
end

function gilgamesh_enuma_elish:VFX2_Sparkles(caster)
  --FxDestroyer(self.PI2,false)
  self.PI2 = FxCreator("particles/custom/gilgamesh/enuma_elish/charging_sparkles.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster,0,nil)
end

function gilgamesh_enuma_elish:VFX3_Projectile(caster)
  local casterLocation = caster:GetAbsOrigin()
  local frontward = caster:GetForwardVector()
  local targetPoint =  self:GetCursorPosition()

  local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
  dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
  dummy:SetForwardVector(frontward)

  local radius = self.StartRadius
  local fxIndex = ParticleManager:CreateParticle("particles/custom/gilgamesh/enuma_elish/projectile.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
  ParticleManager:SetParticleControl(fxIndex, 3, targetPoint)

  Timers:CreateTimer( function()
    if IsValidEntity(dummy) and not dummy:IsNull() then
      local newLoc = GetGroundPosition(dummy:GetAbsOrigin() + self.Speed * 0.03 * frontward, dummy)
      dummy:SetAbsOrigin( newLoc )
      radius = radius + (self.end_radius - self.StartRadius) * self.Speed * 0.03 / (self.range - self.end_radius)
      -- radius = keys.StartRadius + (enuma.fEndRadius - keys.StartRadius) * (newLoc - casterLocation):Length2D() / enuma.fDistance
      ParticleManager:SetParticleControl(fxIndex, 2, Vector(radius,0,0))
      -- DebugDrawCircle(newLoc, Vector(255,0,0), 0.5, radius, true, 0.15)
      return 0.03
    else
      return nil
    end
  end)
  Timers:CreateTimer((self.range - self.end_radius) / self.Speed + 0.35, function() 
    FxDestroyer(fxIndex,false)
    dummy:RemoveSelf()
  end)
end

function gilgamesh_enuma_elish:DestroyAllVFX()
  FxDestroyer(self.PI1, false)
  FxDestroyer(self.PI2, false)
end

function gilgamesh_enuma_elish:AfterOnSpellSt()
  local caster = self:GetCaster()
  self:VFX1_Red_Aura(caster)
  ParticleManager:SetParticleControl(self.PI1, 1, Vector(300,1,1))    
  caster:EmitSound("Hero_Dark_Seer.Wall_of_Replica_lp")
  StartAnimation(self:GetCaster(), {duration=10, activity=ACT_DOTA_CAST_ABILITY_6, rate=1.2})
end

function gilgamesh_enuma_elish:AfterThinkChargeIncr()
  local caster = self:GetCaster()
  self:GetTestPrints()

  if self.channel_charge == 25 then
    FreezeAnimation(self:GetCaster())
    caster:EmitSound("Hero_Weaver.CrimsonPique.Layer")
  elseif self.channel_charge == 29 then   
    self:VFX2_Sparkles(caster)
  end
  
  --red aura
  local intensity = self.channel_charge * 20 + 200
  ParticleManager:SetParticleControl(self.PI1, 1, Vector(intensity,1,1))    

  --red floor
  local intensity2 = self.channel_charge * 15 + 130
  ParticleManager:SetParticleControl(self.PI1, 3, Vector(intensity2,1,1))    

  --sparkles
  if self.channel_charge > 32 then
    local intensity = -0.6 + self.channel_charge / 100 * 6
    ParticleManager:SetParticleControl(self.PI2, 2, Vector(1, 1, intensity))
  end
end


function gilgamesh_enuma_elish:AfterChannelFin_Success()
  local caster = self:GetCaster()
  giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", self:GetSpecialValueFor("endcast_pause"))  
  caster:StopSound("Hero_Dark_Seer.Wall_of_Replica_lp")
  EmitGlobalSound("Gilgamesh.Enuma2") 
  
  Timers:CreateTimer(0.2,function()
    local beam = self:LaunchBeam("")    
    self:VFX3_Projectile(caster)
  end)
  Timers:CreateTimer(0.5,function()
    self:DestroyAllVFX()
  end)
end

function gilgamesh_enuma_elish:AfterChannelFin_Fail()
  local caster = self:GetCaster()
  EndAnimation(caster)
  caster:StopSound("Hero_Dark_Seer.Wall_of_Replica_lp")
  self:DestroyAllVFX()
end

function gilgamesh_enuma_elish:OnProjectileHit_ExtraData(hTarget,vLocation,table)
  if hTarget ~= nil then
    local caster = self:GetCaster()
    local damage = table.damage
    if hTarget:GetUnitName() == "gille_gigantic_horror" then damage = damage * 1.3 end
    DoDamage(caster, hTarget, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
    local PIOnTarget = FxCreator("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_illuminate_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget,0,nil)
  end
end

function gilgamesh_enuma_elish:GetBeamSpeed()
  self.Speed = self:GetSpecialValueFor("speed")
  return self.Speed 
end

function gilgamesh_enuma_elish:GetBeamRange()
  self.range = self:GetSpecialValueFor("range")
  local caster = self:GetCaster()
  if caster.IsEnumaImproved then 
    local attribute_ability = caster.MasterUnit2:FindAbilityByName("gilgamesh_attribute_sword_of_creation")
    local bonus = attribute_ability:GetSpecialValueFor("enuma_range")
    self.range = self.range + bonus
  end
  return self.range
end

function gilgamesh_enuma_elish:GetBeamRadius()
  self.StartRadius = self:GetSpecialValueFor("radius")
  return self.StartRadius
end

function gilgamesh_enuma_elish:GetBeamEndRadius()
  self.end_radius = self:ChargeGetTotal("end_radius","endradius_charge_start","endradius_charge_end","endradius_total")
  local caster = self:GetCaster()
  if caster.IsEnumaImproved then 
    local attribute_ability = caster.MasterUnit2:FindAbilityByName("gilgamesh_attribute_sword_of_creation")
    local bonus = attribute_ability:GetSpecialValueFor("enuma_radius")
    self.end_radius = self.end_radius + bonus
  end
  return self.end_radius
end

function gilgamesh_enuma_elish:GetBeamDamage()
  return self:ChargeGetTotal("damage","damage_charge_start","damage_charge_end","damage_total", "add1_charge_start", "add1_charge_end")
end

function gilgamesh_enuma_elish:GetCastAnimation()
  return nil
end

function gilgamesh_enuma_elish:GetAbilityTextureName()
  return "custom/gilgamesh_enuma_elish"
end
function gilgamesh_enuma_elish_activate:GetAbilityTextureName()
  return "custom/gilgamesh_enuma_elish"
end

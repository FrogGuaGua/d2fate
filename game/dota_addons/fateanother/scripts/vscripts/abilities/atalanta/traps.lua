atalanta_traps = class({})
atalanta_traps_close = class({})
LinkLuaModifier("modifier_traps_gcd", "abilities/atalanta/modifier_traps_gcd", LUA_MODIFIER_MOTION_NONE)

if IsClient() then
  return 
end

function atalanta_traps:OnUpgrade()
  local hCaster = self:GetCaster()
  local iLevel = self:GetLevel()
  self.sAq = "atalanta_sting_shot"
  self.sAw = "atalanta_cobweb_shot"
  self.sAe = "atalanta_entangling_trap"
  self.sAd = "atalanta_reload"
  self.sAf = "atalanta_traps_close"
  self.sAr = "fate_empty4"
  if iLevel == 1 then
    local hAf = hCaster:FindAbilityByName(self.sAf)
    hAf.fGCD = self:GetSpecialValueFor("gcd")
    hAf.sAq = self.sAq
    hAf.sAw = self.sAw
    hAf.sAe = self.sAe
    hAf.sAd = self.sAd
    hAf.sAr = self.sAr
    hAf.hAq = hCaster:AddAbility(self.sAq)
    hAf.hAw = hCaster:AddAbility(self.sAw)
    hAf.hAe = hCaster:AddAbility(self.sAe)
    hAf.hAd = hCaster:AddAbility(self.sAd)
    hAf.hAr = hCaster:AddAbility(self.sAr)
    hAf.hAq:SetLevel(iLevel)
    hAf.hAw:SetLevel(iLevel)
    hAf.hAe:SetLevel(iLevel)
    hAf.hAd:SetLevel(iLevel)
    hAf.hAr:SetLevel(iLevel)
  else
    hCaster:FindAbilityByName(self.sAq):SetLevel(iLevel)
    hCaster:FindAbilityByName(self.sAw):SetLevel(iLevel)
    hCaster:FindAbilityByName(self.sAe):SetLevel(iLevel)
    hCaster:FindAbilityByName(self.sAd):SetLevel(iLevel)
    hCaster:FindAbilityByName(self.sAr):SetLevel(iLevel)
  end
end
function atalanta_traps_close:OnUpgrade()
  local hCaster = self:GetCaster()
  local hAbility = self
  
  if not hCaster.CloseTraps then
    function hCaster:CloseTraps(hAbilityUsed,...)
      hAbility:OnSpellStart(...)
      hAbility:TriggerGCD(hAbilityUsed)
    end
  end
end
function atalanta_traps:OnSpellStart()
  local hCaster = self:GetCaster()
  local hAq = hCaster:GetAbilityByIndex(0)
  local hAw = hCaster:GetAbilityByIndex(1)
  local hAe = hCaster:GetAbilityByIndex(2)
  local hAd = hCaster:GetAbilityByIndex(3)
  local hAf = hCaster:GetAbilityByIndex(4)
  local hAr = hCaster:GetAbilityByIndex(5)
  hCaster:SwapAbilities(hAq:GetName(), self.sAq, false, true)
  hCaster:SwapAbilities(hAw:GetName(), self.sAw, false, true) 
  hCaster:SwapAbilities(hAe:GetName(), self.sAe, false, true) 
  hCaster:SwapAbilities(hAd:GetName(), self.sAd, false, true) 
  hCaster:SwapAbilities(hAf:GetName(), self.sAf, false, true) 
  hCaster:SwapAbilities(hAr:GetName(), self.sAr, false, true) 
end
function atalanta_traps_close:OnSpellStart()
  local hCaster = self:GetCaster()
  local hAq = hCaster:GetAbilityByIndex(0)
  local hAw = hCaster:GetAbilityByIndex(1)
  local hAe = hCaster:GetAbilityByIndex(2)
  local hAd = hCaster:GetAbilityByIndex(3)
  local hAf = hCaster:GetAbilityByIndex(4)
  local hAr = hCaster:GetAbilityByIndex(5)
  hCaster:SwapAbilities(hAq:GetName(), "atalanta_celestial_arrow", false, true)
  hCaster:SwapAbilities(hAw:GetName(), "atalanta_calydonian_hunt", false, true) 
  hCaster:SwapAbilities(hAe:GetName(), "atalanta_traps", false, true) 
  hCaster:SwapAbilities(hAd:GetName(), "atalanta_crossing_arcadia", false, true) 
  hCaster:SwapAbilities(hAf:GetName(), "atalanta_priestess_of_the_hunt", false, true) 
  if hCaster.bIsBowOfHeavenActive then
    hCaster:SwapAbilities(hAr:GetName(), "atalanta_phoebus_catastrophe_barrage", false, true) 
  else
    hCaster:SwapAbilities(hAr:GetName(), "atalanta_tauropolos_new", false, true) 
  end
end

function atalanta_traps_close:TriggerGCD(hAbilityUsed)
  local fGCD = self.fGCD
  local hCaster = self:GetCaster()
  hCaster:AddNewModifier(hCaster, self, "modifier_traps_gcd", {Duration = fGCD})
  if hAbilityUsed:GetName() == self.sAq then
    self.hAw:StartCooldown(fGCD)
    self.hAe:StartCooldown(fGCD)
  end
  if hAbilityUsed:GetName() == self.sAw then
    self.hAq:StartCooldown(fGCD)
    self.hAe:StartCooldown(fGCD)
  end
  if hAbilityUsed:GetName() == self.sAe then
    self.hAq:StartCooldown(fGCD)
    self.hAw:StartCooldown(fGCD)
  end
end
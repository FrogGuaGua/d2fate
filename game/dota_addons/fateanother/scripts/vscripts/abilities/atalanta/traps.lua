atalanta_traps = class({})
atalanta_traps_close = class({})

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
    hCaster:AddAbility(self.sAq):SetLevel(iLevel)
    hCaster:AddAbility(self.sAw):SetLevel(iLevel)
    hCaster:AddAbility(self.sAe):SetLevel(iLevel)
    hCaster:AddAbility(self.sAd):SetLevel(iLevel)
    hCaster:AddAbility(self.sAr):SetLevel(iLevel)
  else
    hCaster:FindAbilityByName(self.sAq):SetLevel(iLevel)
    hCaster:FindAbilityByName(self.sAw):SetLevel(iLevel)
    hCaster:FindAbilityByName(self.sAe):SetLevel(iLevel)
    hCaster:FindAbilityByName(self.sAd):SetLevel(iLevel)
    hCaster:FindAbilityByName(self.sAr):SetLevel(iLevel)
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
  hCaster:SwapAbilities(hAr:GetName(), "atalanta_phoebus_catastrophe_barrage", false, true) 
end

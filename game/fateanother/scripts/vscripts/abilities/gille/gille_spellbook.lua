function OnSpellbookOpen(keys)
    local caster = keys.caster
    caster:SwapAbilities("gille_torment", "gille_summon_demon", true, false) 
	caster:SwapAbilities("gille_spellbook_of_prelati_blind", "gille_spellbook", true, false) 
    caster:SwapAbilities("gille_spellbook_of_prelati_pain", "gille_exquisite_cadaver", true, false)
    caster:SwapAbilities("gille_spellbook_close","gille_throw_corpse", true, false)
    caster:SwapAbilities("gille_exquisite_cadaver","gille_abyssal_contract", true, false)
end

function OnSpellbookClose(keys)
    local caster = keys.caster
    caster:SwapAbilities("gille_summon_demon","gille_torment", true, false) 
	caster:SwapAbilities("gille_spellbook", "gille_spellbook_of_prelati_blind", true, false) 
    caster:SwapAbilities("gille_exquisite_cadaver", "gille_spellbook_of_prelati_pain", true, true)
    caster:SwapAbilities("gille_throw_corpse","gille_spellbook_close", true, false)
    caster:SwapAbilities("gille_abyssal_contract", "gille_spellbook_of_prelati_pain", true, false)
end


function OnSpellbookUpgrade(keys)
    local caster = keys.caster
    local a1=caster:FindAbilityByName("gille_torment")
    a1:SetLevel(keys.ability:GetLevel())
    local a2=caster:FindAbilityByName("gille_spellbook_of_prelati_blind")
    a2:SetLevel(keys.ability:GetLevel())
    local a3=caster:FindAbilityByName("gille_spellbook_of_prelati_pain")
	a3:SetLevel(keys.ability:GetLevel())
end
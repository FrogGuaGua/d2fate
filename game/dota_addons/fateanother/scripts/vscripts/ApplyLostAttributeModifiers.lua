AttributeModifiers = { 
    npc_dota_hero_tidehunter ={
       InnocentMonsterAcquired = "modifier_innocent_monster",
       ProtectionOfFaithAcquired = "modifier_protection_of_faith" 
    }
}
AttributeAbilities = { 
    npc_dota_hero_tidehunter ={
       InnocentMonsterAcquired = "vlad_attribute_innocent_monster",
       ProtectionOfFaithAcquired = "vlad_attribute_protection_of_faith" 
    }
}
--this is dead code for now

function ApplyLostAttributeModifiers(keys)
	local hero = keys.caster	
	local heroName = hero:GetUnitName()
	local tModifiers = AttributeModifiers[heroName]
	local tAbilities = AttributeAbilities[heroName]
	if tModifiers and tAbilities then
		for k,v in pairs(tModifiers) do
			if hero[k] and not hero:HasModifier(v) then
				hero:AddNewModifier(hero, hero.MasterUnit2:FindAbilityByName(tAbilities[k]), v, {})
			end
		end	
	end
end
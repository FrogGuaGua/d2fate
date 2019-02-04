function OnPrickPokeStart(keys)
    local caster = keys.caster
    local target = keys.target
    local damage = keys.damage
    local stun_duration = keys.stun_duration
    local target_magic_reduction= target:GetMagicalArmorValue() 
    local target_phyical_reduction = GetPhysicalDamageReduction(target:GetPhysicalArmorValue())
    local bones_damage = caster:FindModifierByName("modifier_trouble_times_hero"):GetDeadNumber() * (-0.02)
    damage = damage * (1+bones_damage)
    if target_phyical_reduction < 0 and target_phyical_reduction < target_magic_reduction then
        DoDamage(caster,target , damage , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
    elseif target_magic_reduction < 0 and target_magic_reduction < target_phyical_reduction then
        DoDamage(caster,target , damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
    else
        DoDamage(caster,target , damage , DAMAGE_TYPE_PURE, 0, keys.ability, false)
    end   
    local flayer = caster:FindAbilityByName("lvbu_flayer")
    flayer:AddStack(target)
end
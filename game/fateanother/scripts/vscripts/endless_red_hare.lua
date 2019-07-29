function OnEndlessRedHareDeath(keys)
    local caster=keys.caster
    local ability=keys.ability
    local nowhealth = caster:GetHealth()
    if nowhealth == 0 and ability:IsCooldownReady() then
        local cd = ability:GetCooldown(ability:GetLevel())
        ability:StartCooldown(cd)
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_endless_red_hare_start", {})
        local maxhealth = caster:GetMaxHeath()
        caster:SetHealth(maxhealth)
        Timers:CreateTimer(0.5,function()
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_endless_red_hare_debuff", {})
        end) 
    end
end
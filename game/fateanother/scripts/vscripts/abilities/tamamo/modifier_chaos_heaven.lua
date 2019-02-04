---@class modifier_chaos_heaven_enemy : CDOTA_Modifier_Lua
modifier_chaos_heaven_enemy = {}

if IsServer() then
    function modifier_chaos_heaven_enemy:OnRefresh(args)
        local parent = self:GetParent()
        local caster = self:GetCaster()
        local stack_count = self:GetStackCount()+1
        local mana_burn = caster:GetIntellect() * stack_count
        parent:ReduceMana(mana_burn)
        DoDamage(caster, parent, mana_burn, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
        parent:EmitSound("Tamamo.ChaosHeaven.Enemy")
        local pcf = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/am_manaburn_basher_ti_5.vpcf", PATTACH_ABSORIGIN, parent)
        ParticleManager:ReleaseParticleIndex(pcf)
        if stack_count == self:GetCaster():FindAbilityByName("tamamo_armed_up"):GetSpecialValueFor("stack_explode_count") then
            parent:AddNewModifier(caster, self:GetAbility(), "modifier_chaos_heaven_revoke", { duration = self:GetAbility():GetSpecialValueFor("revoke_duration") })
            parent:EmitSound("Tamamo.ChaosHeaven.Revoke")
            self:Destroy()
        end
    end

    modifier_chaos_heaven_enemy.OnCreated = modifier_chaos_heaven_enemy.OnRefresh
end

LinkLuaModifier("modifier_chaos_heaven_revoke", "abilities/tamamo/modifier_chaos_heaven", LUA_MODIFIER_MOTION_NONE)
---@class modifier_chaos_heaven_revoke : CDOTA_Modifier_Lua
modifier_chaos_heaven_revoke = {}

function modifier_chaos_heaven_revoke:GetEffectName()
    return "particles/units/heroes/hero_shadow_demon/shadow_demon_demonic_purge_debuff.vpcf"
end

function modifier_chaos_heaven_revoke:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
    function modifier_chaos_heaven_revoke:IsRevoked()
        return self:GetParent():GetManaPercent() < self:GetAbility():GetSpecialValueFor("revoke_mana_pct")
    end
end

---@class modifier_chaos_heaven_ally : CDOTA_Modifier_Lua
modifier_chaos_heaven_ally = {}

if IsServer() then
    function modifier_chaos_heaven_ally:OnRefresh(args)
        local parent = self:GetParent()
        local caster = self:GetCaster()
        local targets = FindUnitsInRadius(parent:GetTeamNumber(), parent:GetAbsOrigin(), nil, 450, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        local mana_burn = caster:GetIntellect() * self:GetAbility():GetSpecialValueFor("int_multiplier")
        local health_difference = parent:GetMaxHealth() - parent:GetHealth()
        if mana_burn > health_difference then mana_burn = health_difference end
        if targets[1] then parent:EmitSound("Tamamo.ChaosHeaven.Ally") end
        for _, v in ipairs(targets) do
            v:ReduceMana(mana_burn)
            parent:ApplyHeal(mana_burn, caster)
            local pcf = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
            ParticleManager:SetParticleControl(pcf, 1, v:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(pcf)
        end
    end

    modifier_chaos_heaven_ally.OnCreated = modifier_chaos_heaven_ally.OnRefresh
end
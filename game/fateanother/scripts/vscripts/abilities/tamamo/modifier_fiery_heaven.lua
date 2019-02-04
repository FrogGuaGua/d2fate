---@class modifier_fiery_heaven_enemy : CDOTA_Modifier_Lua
modifier_fiery_heaven_enemy = {}

function modifier_fiery_heaven_enemy:DeclareFunctions()
    return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function modifier_fiery_heaven_enemy:GetModifierMagicalResistanceBonus()
    return -(self:GetAbility():GetSpecialValueFor("mres_reduction") * self:GetStackCount())
end

function modifier_fiery_heaven_enemy:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf"
end

function modifier_fiery_heaven_enemy:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
    function modifier_fiery_heaven_enemy:OnRefresh(args)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        parent:EmitSound("Tamamo.FieryHeaven.Enemy")
        parent:AddNewModifier(self:GetCaster(), ability, "modifier_fiery_heaven_dot", { duration = ability:GetSpecialValueFor("dot_duration"), damage = ability:GetSpecialValueFor("dot") })
        if self:GetStackCount()+1 == self:GetCaster():FindAbilityByName("tamamo_armed_up"):GetSpecialValueFor("stack_explode_count") then
            local damage = ability:GetSpecialValueFor("explode_damage")
            local targets = FindUnitsInRadius(parent:GetTeamNumber(), parent:GetAbsOrigin(), nil, ability:GetSpecialValueFor("explode_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
            DoDamage(self:GetCaster(), parent, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
            for _, v in ipairs(targets) do
                if v ~= parent then
                    DoDamage(self:GetCaster(), v, damage/2, DAMAGE_TYPE_MAGICAL, 0, ability, false)
                end
            end
            parent:EmitSound("Tamamo.FieryHeaven.Explode")
            self:Destroy()
        end
    end

    function modifier_fiery_heaven_enemy:OnDestroy()
        local pcf = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt_explosion.vpcf", PATTACH_ABSORIGIN, self:GetParent())
        ParticleManager:ReleaseParticleIndex(pcf)
    end
    modifier_fiery_heaven_enemy.OnCreated = modifier_fiery_heaven_enemy.OnRefresh
end

LinkLuaModifier("modifier_fiery_heaven_dot", "abilities/tamamo/modifier_fiery_heaven", LUA_MODIFIER_MOTION_NONE)
---@class modifier_fiery_heaven_dot : CDOTA_Modifier_Lua
modifier_fiery_heaven_dot = {}

function modifier_fiery_heaven_dot:GetEffectName()
    return "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff.vpcf"
end

function modifier_fiery_heaven_dot:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
    function modifier_fiery_heaven_dot:OnCreated(args)
        self.damage_per_tick = args.damage / 4
        self:StartIntervalThink(args.duration / 4)
    end
    modifier_fiery_heaven_dot.OnRefresh = modifier_fiery_heaven_dot.OnCreated

    function modifier_fiery_heaven_dot:OnIntervalThink()
        DoDamage(self:GetCaster(), self:GetParent(), self.damage_per_tick, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
    end
end

---@class modifier_fiery_heaven_ally : CDOTA_Modifier_Lua
modifier_fiery_heaven_ally = {}

if IsServer() then
    function modifier_fiery_heaven_ally:OnRefresh(args)
        local parent = self:GetParent()
        parent:EmitSound("Tamamo.FieryHeaven.Ally")
        parent:ApplyHeal(self:GetAbility():GetSpecialValueFor("heal"), self:GetCaster())
    end
    modifier_fiery_heaven_ally.OnCreated = modifier_fiery_heaven_ally.OnRefresh
end

function modifier_fiery_heaven_ally:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_fiery_heaven_ally:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("armor") * self:GetStackCount()
end

function modifier_fiery_heaven_ally:GetEffectName()
    return "particles/units/heroes/hero_sven/sven_warcry_buff.vpcf"
end

function modifier_fiery_heaven_ally:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
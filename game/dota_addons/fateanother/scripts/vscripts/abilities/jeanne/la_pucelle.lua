---@class jeanne_combo_la_pucelle : CDOTA_Ability_Lua
jeanne_combo_la_pucelle = class({})
LinkLuaModifier("modifier_jeanne_la_pucelle", "abilities/jeanne/la_pucelle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_la_pucelle_phase1_aura", "abilities/jeanne/la_pucelle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_la_pucelle_phase1_debuff", "abilities/jeanne/la_pucelle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_la_pucelle_phase2", "abilities/jeanne/la_pucelle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_la_pucelle_fire_thinker", "abilities/jeanne/la_pucelle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_la_pucelle_fire_damage", "abilities/jeanne/la_pucelle", LUA_MODIFIER_MOTION_NONE)

function jeanne_combo_la_pucelle:GetIntrinsicModifierName()
    return "modifier_jeanne_la_pucelle"
end

---@class modifier_jeanne_la_pucelle : CDOTA_Modifier_Lua
modifier_jeanne_la_pucelle = class({})

if IsServer() then
    function modifier_jeanne_la_pucelle:DeclareFunctions()
        return { MODIFIER_EVENT_ON_TAKEDAMAGE }
    end

    function modifier_jeanne_la_pucelle:OnTakeDamage(args)
        local parent = self:GetParent()
        if not args.unit == self:GetParent() then return end

        local ability = self:GetAbility()
        local threshold = ability:GetSpecialValueFor("health_threshold_pct")/100

        if parent:GetHealth() < parent:GetMaxHealth() * threshold and parent:GetStrength() >= 19.1 and parent:GetAgility() >= 19.1 and parent:GetIntellect() >= 19.1 and ability:IsCooldownReady() and IsRevivePossible(parent) then
            parent:SetHealth(1)
            ability:StartCooldown(ability:GetCooldown(-1))
            parent:AddNewModifier(parent, ability, "modifier_jeanne_la_pucelle_phase1_aura", {duration = ability:GetSpecialValueFor("phase1_duration")})
            EmitGlobalSound("Hero_Phoenix.SuperNova.Explode")
            parent:EmitSound("Hero_Phoenix.SunRay.Loop")
            parent:EmitSound("Hero_DoomBringer.ScorchedEarthAura")

            local masterCombo = parent.MasterUnit2:FindAbilityByName(ability:GetAbilityName())
            if masterCombo then
                masterCombo:EndCooldown()
                masterCombo:StartCooldown(ability:GetCooldown(-1))
            end
        end
    end
end

---@class modifier_jeanne_la_pucelle_phase1_aura : CDOTA_Modifier_Lua
modifier_jeanne_la_pucelle_phase1_aura = class({})

function modifier_jeanne_la_pucelle_phase1_aura:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf"
end

function modifier_jeanne_la_pucelle_phase1_aura:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = IsServer(),
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }
end

if IsServer() then
    function modifier_jeanne_la_pucelle_phase1_aura:IsAura()
        return true
    end

    function modifier_jeanne_la_pucelle_phase1_aura:GetModifierAura()
        return "modifier_jeanne_la_pucelle_phase1_debuff"
    end

    function modifier_jeanne_la_pucelle_phase1_aura:GetAuraRadius()
        return self:GetAbility():GetSpecialValueFor("phase1_radius")
    end

    function modifier_jeanne_la_pucelle_phase1_aura:GetAuraSearchTeam()
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end

    function modifier_jeanne_la_pucelle_phase1_aura:GetAuraSearchFlags()
        return DOTA_UNIT_TARGET_FLAG_NONE
    end

    function modifier_jeanne_la_pucelle_phase1_aura:GetAuraSearchType()
        return DOTA_UNIT_TARGET_ALL
    end

    function modifier_jeanne_la_pucelle_phase1_aura:OnDestroy()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        parent:AddNewModifier(parent, ability, "modifier_jeanne_la_pucelle_phase2", {duration = ability:GetSpecialValueFor("phase2_duration")})
    end
end

---@class modifier_jeanne_la_pucelle_phase1_debuff : CDOTA_Modifier_Lua
modifier_jeanne_la_pucelle_phase1_debuff = class({})

function modifier_jeanne_la_pucelle_phase1_debuff:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_supernova_radiance.vpcf"
end

if IsServer() then
    function modifier_jeanne_la_pucelle_phase1_debuff:OnCreated(args)
        local ability = self:GetAbility()
        local tick = 0.25
        self.damage = ability:GetSpecialValueFor("phase1_dps") * tick
        self.slow = -(ability:GetSpecialValueFor("phase1_slow"))
        self:StartIntervalThink(tick)
    end

    function modifier_jeanne_la_pucelle_phase1_debuff:OnIntervalThink()
        DoDamage(self:GetCaster(), self:GetParent(), self.damage, DAMAGE_TYPE_PURE, 0, self:GetAbility(), false)
    end

    function modifier_jeanne_la_pucelle_phase1_debuff:DeclareFunctions()
        return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
    end

    function modifier_jeanne_la_pucelle_phase1_debuff:GetModifierMoveSpeedBonus_Percentage()
        return self.slow
    end
end

---@class modifier_jeanne_la_pucelle_phase2 : CDOTA_Modifier_Lua
modifier_jeanne_la_pucelle_phase2 = class({})

function modifier_jeanne_la_pucelle_phase2:GetEffectName()
    return "particles/econ/events/ti6/radiance_owner_ti6.vpcf"
end

function modifier_jeanne_la_pucelle_phase2:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }
end

if IsServer() then
    function modifier_jeanne_la_pucelle_phase2:OnCreated(args)
        self:StartIntervalThink(0.25)
    end

    function modifier_jeanne_la_pucelle_phase2:OnIntervalThink()
        local parent = self:GetParent()
        CreateModifierThinker(parent, self:GetAbility(), "modifier_jeanne_la_pucelle_fire_thinker", {duration = 2.1}, parent:GetAbsOrigin(), parent:GetTeamNumber(), false)
    end

    function modifier_jeanne_la_pucelle_phase2:OnDestroy()
        local parent = self:GetParent()
        parent:StopSound("Hero_DoomBringer.ScorchedEarthAura")
        parent:StopSound("Hero_Phoenix.SunRay.Loop")
        ResetAbilities(parent)
        ResetItems(parent)
        parent:SetHealth(parent:GetMaxHealth())
        parent:GiveMana(parent:GetMaxMana())
    end
end

---@class modifier_jeanne_la_pucelle_fire_thinker : CDOTA_Modifier_Lua
modifier_jeanne_la_pucelle_fire_thinker = class({})

if IsServer() then
    function modifier_jeanne_la_pucelle_fire_thinker:OnCreated(args)
        self.particle = ParticleManager:CreateParticle("particles/custom/ruler/la_pucelle/la_pucelle_flame.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle, 1, Vector(self:GetDuration(),0,0))
        self:StartIntervalThink(1)
    end

    function modifier_jeanne_la_pucelle_fire_thinker:OnIntervalThink()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local targets = FindUnitsInRadius(parent:GetTeam(), parent:GetAbsOrigin(), nil, 325, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        for k, v in pairs(targets) do
            if not v:HasModifier("modifier_jeanne_la_pucelle_fire_damage") then
                v:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_jeanne_la_pucelle_fire_damage", {duration = 1})
            end
        end
    end

    function modifier_jeanne_la_pucelle_fire_thinker:OnDestroy()
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        UTIL_Remove(self:GetParent())
    end
end

---@class modifier_jeanne_la_pucelle_fire_damage : CDOTA_Modifier_Lua
modifier_jeanne_la_pucelle_fire_damage = class({})

if IsServer() then
    function modifier_jeanne_la_pucelle_fire_damage:OnCreated(args)
        local ability = self:GetAbility()
        local parent = self:GetParent()
        DoDamage(self:GetCaster(), parent, parent:GetHealth() * (ability:GetSpecialValueFor("phase2_fire_dps")/100), DAMAGE_TYPE_MAGICAL, 0, ability, false)
    end
end
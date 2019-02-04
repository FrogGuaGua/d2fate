---@class tamamo_amaterasu : CDOTA_Ability_Lua
tamamo_amaterasu = {}

function tamamo_amaterasu:OnSpellStart()
    local caster = self:GetCaster()
    local pos = caster:GetAbsOrigin()
    local duration = self:GetSpecialValueFor("duration")
    local radius = self:GetSpecialValueFor("radius")

    if caster.IsWitchcraftAcquired then radius = radius + 200 end

    if IsValidEntity(self.thinker) then
        self.thinker:FindModifierByName("modifier_amaterasu_thinker"):Destroy()
    end
    self.thinker = CreateModifierThinker(caster, self, "modifier_amaterasu_thinker", { duration = duration, radius = radius }, pos, caster:GetTeamNumber(), false)
    EmitGlobalSound("Tamamo.Amaterasu")
    EmitGlobalSound("Tamamo.Amaterasu.Cast")
    EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Tamamo.Amaterasu.Cast2", caster)
    EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Tamamo.Amaterasu.Cast3", caster)

    local charm = caster:FindModifierByName("modifier_tamamo_charms")
    if charm then
        local ability = charm:GetAbility()
        local targets = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        for _, v in ipairs(targets) do
            if v:IsOpposingTeam(caster:GetTeamNumber()) then
                v:AddNewModifier(caster, ability, ability.enemy_charm, { duration = 15 }):IncrementStackCount()
            else
                v:AddNewModifier(caster, ability, ability.ally_charm, { duration = 15 }):IncrementStackCount()
            end
        end
        charm:UseStack()
    end
end

function tamamo_amaterasu:GetIntrinsicModifierName()
    return "modifier_amaterasu_passive"
end

LinkLuaModifier("modifier_amaterasu_passive", "abilities/tamamo/amaterasu", LUA_MODIFIER_MOTION_NONE)
---@class modifier_amaterasu_passive : CDOTA_Modifier_Lua
modifier_amaterasu_passive = {}

function modifier_amaterasu_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function modifier_amaterasu_passive:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("passive_int")
end


LinkLuaModifier("modifier_amaterasu_thinker", "abilities/tamamo/amaterasu", LUA_MODIFIER_MOTION_NONE)
---@class modifier_amaterasu_thinker : CDOTA_Modifier_Lua
modifier_amaterasu_thinker = {}

if IsServer() then
    function modifier_amaterasu_thinker:OnCreated(args)
        local parent = self:GetParent()
        self.center = parent:GetAbsOrigin()
        self.radius = args.radius
        parent.radius = args.radius

        self.torii = {}
        for i = 1, 8 do
            local x = math.cos(i*math.pi/4) * self.radius
            local y = math.sin(i*math.pi/4) * self.radius
            local position = GetGroundPosition(Vector(self.center.x + x, self.center.y + y, 0), nil)
            local angles = VectorToAngles((self.center - position):Normalized())
            local entity_info = { model = "models/misc/templedoor.vmdl", origin = position, angles = angles, scale = 1.2 }
            self.torii[i] = SpawnEntityFromTableSynchronous("prop_dynamic", entity_info )
        end

        local dazzle_pcf = ParticleManager:CreateParticle('particles/units/heroes/hero_dazzle/dazzle_weave.vpcf', PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(dazzle_pcf, 0, self.center)
        ParticleManager:SetParticleControl(dazzle_pcf, 1, Vector(self.radius,0,0))
        ParticleManager:ReleaseParticleIndex(dazzle_pcf)

        self.circle_pcf = ParticleManager:CreateParticle('particles/custom/tamamo/tamamo_amaterasu_continuous.vpcf', PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(self.circle_pcf, 0, self.center)
        ParticleManager:SetParticleControl(self.circle_pcf, 1, Vector(self.radius,0,0))

        self.center_pcf = ParticleManager:CreateParticle("particles/econ/items/dazzle/dazzle_ti6/dazzle_ti6_shallow_grave.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(self.center_pcf, 0, self.center)

        parent:EmitSound("Tamamo.Amaterasu.Loop")
        self:StartIntervalThink(0.9)
    end

    function modifier_amaterasu_thinker:OnIntervalThink()
        ParticleManager:DestroyParticle(self.circle_pcf, false)
        ParticleManager:ReleaseParticleIndex(self.circle_pcf)
        self.circle_pcf = ParticleManager:CreateParticle('particles/custom/tamamo/tamamo_amaterasu_continuous.vpcf', PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(self.circle_pcf, 0, self.center)
        ParticleManager:SetParticleControl(self.circle_pcf, 1, Vector(self.radius,0,0))
    end

    function modifier_amaterasu_thinker:IsAura()
        return true
    end

    function modifier_amaterasu_thinker:GetModifierAura()
        return "modifier_amaterasu"
    end

    function modifier_amaterasu_thinker:GetAuraRadius()
        return self.radius
    end

    function modifier_amaterasu_thinker:GetAuraSearchTeam()
        return DOTA_UNIT_TARGET_TEAM_BOTH
    end

    function modifier_amaterasu_thinker:GetAuraSearchType()
        return DOTA_UNIT_TARGET_ALL
    end

    function modifier_amaterasu_thinker:OnDestroy()
        local parent = self:GetParent()
        ParticleManager:DestroyParticle(self.circle_pcf, false)
        ParticleManager:ReleaseParticleIndex(self.circle_pcf)
        ParticleManager:DestroyParticle(self.center_pcf, false)
        ParticleManager:ReleaseParticleIndex(self.center_pcf)
        parent:StopSound("Tamamo.Amaterasu.Loop")
        EmitSoundOnLocationWithCaster(self.center, "Tamamo.Amaterasu.End", parent)
        for _, v in ipairs(self.torii) do
            UTIL_Remove(v)
        end
        UTIL_Remove(self:GetParent())
    end
end

LinkLuaModifier("modifier_amaterasu", "abilities/tamamo/amaterasu", LUA_MODIFIER_MOTION_NONE)
---@class modifier_amaterasu : CDOTA_Modifier_Lua
modifier_amaterasu = {}

function modifier_amaterasu:DeclareFunctions()
    return { MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE }
end

function modifier_amaterasu:GetModifierTotalPercentageManaRegen()
    if self:GetStackCount() == 1 then
        return self:GetAbility():GetSpecialValueFor("mana_regen_pct")
    end
end

if IsServer() then
    function modifier_amaterasu:OnCreated(args)
        if self:GetParent():IsOpposingTeam(self:GetCaster():GetTeamNumber()) then
            self.tick = 0.25
            self:StartIntervalThink(self.tick)
        else
            self:SetStackCount(1)
        end
    end

    function modifier_amaterasu:OnIntervalThink()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local mana_burn = parent:GetMaxMana() * (ability:GetSpecialValueFor("mana_drain_pct")/100) * self.tick
        parent:ReduceMana(mana_burn)
        DoDamage(self:GetCaster(), parent, mana_burn * 0.2, DAMAGE_TYPE_MAGICAL, 0, ability, false)

        local thinker = ability.thinker
        if thinker:IsNull() then return end
        local targets = FindUnitsInRadius(thinker:GetTeamNumber(), thinker:GetAbsOrigin(), nil, thinker.radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        local heal = (mana_burn * 0.2) / #targets
        for _, v in ipairs(targets) do
            v:ApplyHeal(heal, self:GetCaster())
        end
    end
end
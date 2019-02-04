function create_charms_particle(particle_path, hero)
    local pcf = ParticleManager:CreateParticle(particle_path, PATTACH_ABSORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControl(pcf, 1, Vector(6, 0, 0))
    return pcf
end

---@class tamamo_throw_charm : CDOTA_Ability_Lua
tamamo_throw_charm = {}

function tamamo_throw_charm:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function tamamo_throw_charm:OnSpellStart()
    local caster = self:GetCaster()
    local pos = caster:GetAbsOrigin() + Vector(0, 0, 200)
    local cursor = self:GetCursorPosition()
    local speed = 1500

    self:ThrowCharm(pos, cursor, speed)
    if caster.IsSpiritTheftAcquired then
        Timers:CreateTimer(0.2, function() self:ThrowCharm(pos, cursor, speed) end)
    end
end

function tamamo_throw_charm:ThrowCharm(pos, end_point, speed)
    local caster = self:GetCaster()
    local projectile_duration = (end_point - pos):Length() / speed
    local projectile_particle = "particles/units/heroes/hero_wisp/wisp_guardian.vpcf"
    local explosion_particle = "particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf"
    caster:EmitSound("Tamamo.ThrowCharm.Launch")
    local explosion_sound = "Tamamo.ThrowCharm.Empty"

    local modifier_ability
    local modifier = caster:FindModifierByName("modifier_tamamo_charms")
    if modifier then
        modifier_ability = modifier:GetAbility()
        projectile_particle = "particles/econ/items/wisp/wisp_guardian_ti7.vpcf"
        explosion_particle = modifier_ability.explosion_pcf
        explosion_sound = modifier_ability.explosion_sound
        modifier:UseStack()
    end

    local pcf = ParticleManager:CreateParticle(projectile_particle, PATTACH_CUSTOMORIGIN, nil)
    local direction = (end_point - pos):Normalized()
    ParticleManager:SetParticleControl(pcf, 0, pos)
    local start_time = GameRules:GetGameTime()
    self:SetContextThink(tostring(pcf), function()
        if GameRules:GetGameTime() - start_time < projectile_duration then
            pos = pos + direction * speed * FrameTime()
            ParticleManager:SetParticleControl(pcf, 0, pos)
            return FrameTime()
        end

        ParticleManager:DestroyParticle(pcf, false)
        ParticleManager:ReleaseParticleIndex(pcf)
        local exp_pcf = ParticleManager:CreateParticle(explosion_particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(exp_pcf, 0, end_point)
        ParticleManager:ReleaseParticleIndex(exp_pcf)
        EmitSoundOnLocationWithCaster(end_point, explosion_sound, caster)

        local targets = FindUnitsInRadius(caster:GetTeamNumber(), end_point, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        for _, v in ipairs(targets) do self:OnCharmHit(v, modifier_ability) end
    end, FrameTime())
end

function tamamo_throw_charm:OnUpgrade()
    local charms = {
        "tamamo_fiery_heaven",
        "tamamo_frigid_heaven",
        "tamamo_swirling_heaven",
        "tamamo_chaos_heaven",
    }
    for _, v in ipairs(charms) do self:GetCaster():FindAbilityByName(v):UpgradeAbility(true) end
end

---@param target CDOTA_BaseNPC
function tamamo_throw_charm:OnCharmHit(target, ability)
    local caster = self:GetCaster()
    if target:IsOpposingTeam(caster:GetTeamNumber()) then
        if ability then target:AddNewModifier(caster, ability, ability.enemy_charm, { duration = 15 }):IncrementStackCount() end
        DoDamage(caster, target, self:GetSpecialValueFor("damage"), DAMAGE_TYPE_MAGICAL, 0, self, false)
    else
        if ability then target:AddNewModifier(caster, ability, ability.ally_charm, { duration = 15 }):IncrementStackCount() end
    end
end

local charm_spell_start = function(self)
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_tamamo_charms", {})
    caster:FindAbilityByName("tamamo_armed_up"):StartCooldown(vlua.select(caster.IsWitchcraftAcquired, 1, 35))
    caster:FindAbilityByName("tamamo_armed_up_close"):OnSpellStart()
    caster:EmitSound("Tamamo.ArmedUp.Activate")
end

---@class tamamo_fiery_heaven : CDOTA_Ability_Lua
tamamo_fiery_heaven = {
    OnSpellStart = charm_spell_start,
    enemy_charm = "modifier_fiery_heaven_enemy",
    ally_charm = "modifier_fiery_heaven_ally",
    explosion_pcf = "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf",
    explosion_sound = "Tamamo.ThrowCharm.FieryHeaven"
}
---@class tamamo_frigid_heaven : CDOTA_Ability_Lua
tamamo_frigid_heaven = {
    OnSpellStart = charm_spell_start,
    enemy_charm = "modifier_frigid_heaven_enemy",
    ally_charm = "modifier_frigid_heaven_ally",
    explosion_pcf = "particles/units/heroes/hero_lich/lich_frost_nova.vpcf",
    explosion_sound = "Tamamo.ThrowCharm.FrigidHeaven"
}
---@class tamamo_swirling_heaven : CDOTA_Ability_Lua
tamamo_swirling_heaven = {
    OnSpellStart = charm_spell_start,
    enemy_charm = "modifier_swirling_heaven_enemy",
    ally_charm = "modifier_swirling_heaven_ally",
    explosion_pcf = "particles/units/heroes/hero_brewmaster/brewmaster_windwalk.vpcf",
    explosion_sound = "Tamamo.ThrowCharm.SwirlingHeaven"
}
---@class tamamo_chaos_heaven : CDOTA_Ability_Lua
tamamo_chaos_heaven = {
    OnSpellStart = charm_spell_start,
    enemy_charm = "modifier_chaos_heaven_enemy",
    ally_charm = "modifier_chaos_heaven_ally",
    explosion_pcf = "particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explode.vpcf",
    explosion_sound = "Tamamo.ThrowCharm.ChaosHeaven"
}

LinkLuaModifier("modifier_fiery_heaven_enemy", "abilities/tamamo/modifier_fiery_heaven", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fiery_heaven_ally", "abilities/tamamo/modifier_fiery_heaven", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frigid_heaven_enemy", "abilities/tamamo/modifier_frigid_heaven", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frigid_heaven_ally", "abilities/tamamo/modifier_frigid_heaven", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_swirling_heaven_enemy", "abilities/tamamo/modifier_swirling_heaven", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_swirling_heaven_ally", "abilities/tamamo/modifier_swirling_heaven", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chaos_heaven_enemy", "abilities/tamamo/modifier_chaos_heaven", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_chaos_heaven_ally", "abilities/tamamo/modifier_chaos_heaven", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_tamamo_charms", "abilities/tamamo/charms", LUA_MODIFIER_MOTION_NONE)
---@class modifier_tamamo_charms : CDOTA_Modifier_Lua
modifier_tamamo_charms = {}

if IsServer() then
    function modifier_tamamo_charms:OnRefresh(args)
        self:UpdateParticle(6)
        self:SetStackCount(6)
    end

    function modifier_tamamo_charms:UseStack()
        self:UpdateParticle(self:GetStackCount()-1)
        if self:GetStackCount() == 1 then
            self:Destroy()
        else
            self:DecrementStackCount()
        end
    end

    function modifier_tamamo_charms:UpdateParticle(particle_count)
        if self.pcf then
            ParticleManager:DestroyParticle(self.pcf, false)
            ParticleManager:ReleaseParticleIndex(self.pcf)
        end
        self.pcf = ParticleManager:CreateParticle("particles/custom/tamamo/charms/charms.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.pcf, 1, Vector(particle_count, 0, 0))
    end

    function modifier_tamamo_charms:OnDestroy()
        ParticleManager:DestroyParticle(self.pcf, false)
        ParticleManager:ReleaseParticleIndex(self.pcf)
    end

    modifier_tamamo_charms.OnCreated = modifier_tamamo_charms.OnRefresh
end

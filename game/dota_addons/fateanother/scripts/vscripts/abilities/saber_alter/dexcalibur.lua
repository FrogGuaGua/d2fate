---@class saber_alter_excalibur : CDOTA_Ability_Lua
saber_alter_excalibur = class({})
LinkLuaModifier("modifier_dexcalibur_hit", "abilities/saber_alter/dexcalibur", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dexcalibur_anim", "abilities/saber_alter/dexcalibur", LUA_MODIFIER_MOTION_NONE)

function saber_alter_excalibur:OnSpellStart()
    local caster = self:GetCaster()
    local pos = caster:GetAbsOrigin()
    local length = self:GetSpecialValueFor("length")
    local width = self:GetSpecialValueFor("width")
    local direction = (self:GetCursorPosition() - pos):Normalized()
    local duration = 1.6

    giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 4.75)
    EmitGlobalSound("Saber.Caliburn")
    caster:AddNewModifier(caster, self, "modifier_dexcalibur_anim", {duration=4.0})

    Timers:CreateTimer(0.75, function()
        if not caster:IsAlive() then return end
        EmitGlobalSound("Saber_Alter.Excalibur")
    end)

    Timers:CreateTimer(self:GetSpecialValueFor("delay") - self:GetCastPoint(), function()
        if not caster:IsAlive() then return end
        ScreenShake(caster:GetAbsOrigin(), 7, 2.0, 2, 10000, 0, true)
        EmitGlobalSound("Saber.Excalibur_Ready")

        local kv = {
            speed = ((length - width) / duration),
            radius = width,
            duration = duration
        }
        kv.dir_x, kv.dir_y, kv.dir_z = direction.x, direction.y, direction.z

        local thinker = CreateModifierThinker(caster, self, "modifier_beam_thinker", kv, caster:GetAbsOrigin() + direction * (width), caster:GetTeamNumber(), false)

        local p = ParticleManager:CreateParticle( "particles/custom/saber_alter/excalibur/shockwave.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, thinker )
        ParticleManager:SetParticleControlForward(p, 5, Vector(0,0,1))
        ParticleManager:ReleaseParticleIndex(p)
    end)
end

function saber_alter_excalibur:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    if not hTarget:HasModifier("modifier_dexcalibur_hit") then
        local damage = self:GetSpecialValueFor("damage")
        if caster.IsDarklightAcquired then damage = damage + 300 end
        ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle("particles/custom/saber_alter/excalibur/hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget))
        DoDamage(caster, hTarget, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
    end
    hTarget:AddNewModifier(caster, self, "modifier_dexcalibur_hit", {duration=0.2})
end

---@class modifier_dexcalibur_anim : CDOTA_Modifier_Lua
modifier_dexcalibur_anim = {}
modifier_dexcalibur_anim.IsHidden = function(self) return true end

function modifier_dexcalibur_anim:OnCreated(args)
    local parent = self:GetParent()
    local p1 = ParticleManager:CreateParticle("particles/econ/items/doom/doom_f2p_death_effect/doom_bringer_f2p_death_ring_d_black.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:ReleaseParticleIndex(p1)

    local p2 = ParticleManager:CreateParticle("particles/custom/saber_alter/saber_alter_excalibur_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(p2, 0, parent, PATTACH_POINT_FOLLOW, "attach_sword", parent:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p2)

    self:StartIntervalThink(1.1)
end

function modifier_dexcalibur_anim:OnIntervalThink()
    local parent = self:GetParent()

    local p1 = ParticleManager:CreateParticle("particles/custom/saber_alter/saber_alter_excalibur_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:ReleaseParticleIndex(p1)

    self.p2 = ParticleManager:CreateParticle("particles/custom/saber_alter/saber_alter_excalibur_overcharge.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(self.p2, 0, parent, PATTACH_POINT_FOLLOW, "attach_sword", parent:GetAbsOrigin(), true)

    self.p3 = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_blackhole_n.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(self.p3, 1, parent, PATTACH_POINT_FOLLOW, "attach_origin", parent:GetAbsOrigin(), true)

    self:StartIntervalThink(-1)
end

function modifier_dexcalibur_anim:OnDestroy()
    ParticleManager:DestroyParticle(self.p2, false)
    ParticleManager:ReleaseParticleIndex(self.p2)
    ParticleManager:DestroyParticle(self.p3, false)
    ParticleManager:ReleaseParticleIndex(self.p3)
end

function modifier_dexcalibur_anim:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_dexcalibur_anim:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

---@class modifier_dexcalibur_hit : CDOTA_Modifier_Lua
modifier_dexcalibur_hit = {}
modifier_dexcalibur_hit.IsHidden = function(self) return true end
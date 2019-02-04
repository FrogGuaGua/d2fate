---@class saber_excalibur : CDOTA_Ability_Lua
saber_excalibur = class({})
LinkLuaModifier("modifier_excalibur_hit", "abilities/saber/excalibur", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_excalibur_anim", "abilities/saber/excalibur", LUA_MODIFIER_MOTION_NONE)

function saber_excalibur:OnSpellStart()
    local caster = self:GetCaster()
    local pos = caster:GetAbsOrigin()
    local length = self:GetSpecialValueFor("length")
    local width = self:GetSpecialValueFor("width")
    local direction = (self:GetCursorPosition() - pos):Normalized()
    local duration = 1.5

    giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 4.0)
    EmitGlobalSound("Saber.Excalibur_Ready")
    caster:AddNewModifier(caster, self, "modifier_excalibur_anim", {duration=4.0})

    Timers:CreateTimer(0.5, function()
        if not caster:IsAlive() then return end
        EmitGlobalSound("Saber.Excalibur")
    end)

    Timers:CreateTimer(self:GetSpecialValueFor("cast_delay") - self:GetCastPoint(), function()
        if not caster:IsAlive() then return end
        ScreenShake(caster:GetAbsOrigin(), 5, 0.1, 2, 20000, 0, true)

        local kv = {
            speed = ((length - width) / duration),
            radius = width,
            duration = duration
        }
        kv.dir_x, kv.dir_y, kv.dir_z = direction.x, direction.y, direction.z

        local thinker = CreateModifierThinker(caster, self, "modifier_beam_thinker", kv, caster:GetAbsOrigin() + direction * (width), caster:GetTeamNumber(), false)

        local p = ParticleManager:CreateParticle( "particles/custom/saber/excalibur/shockwave.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, thinker )
        ParticleManager:SetParticleControl(p, 4, Vector(width,0,0))
        ParticleManager:SetParticleControlForward(p, 5, Vector(0,0,1))
        ParticleManager:ReleaseParticleIndex(p)
    end)
end

function saber_excalibur:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    if not hTarget:HasModifier("modifier_excalibur_hit") then
        local damage = self:GetSpecialValueFor("damage")
        if caster.IsExcaliburAcquired then damage = damage + 300 end
        ParticleManager:ReleaseParticleIndex(ParticleManager:CreateParticle("particles/custom/saber/excalibur/hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget))
        DoDamage(caster, hTarget, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
    end
    hTarget:AddNewModifier(caster, self, "modifier_excalibur_hit", {duration=0.2})
end

---@class modifier_excalibur_hit : CDOTA_Modifier_Lua
modifier_excalibur_hit = {}
modifier_excalibur_hit.IsHidden = function(self) return true end

---@class modifier_excalibur_anim : CDOTA_Modifier_Lua
modifier_excalibur_anim = {}
modifier_excalibur_anim.IsHidden = function(self) return true end

function modifier_excalibur_anim:OnCreated(args)
    local parent = self:GetParent()
    local p1 = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_cast.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(p1, 0, parent, PATTACH_POINT_FOLLOW, "attach_sword", parent:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p1)

    local p2 = ParticleManager:CreateParticle("particles/custom/saber_excalibur_charge.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    local p3 = ParticleManager:CreateParticle("particles/custom/saber_excalibur_charge.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    local p4 = ParticleManager:CreateParticle("particles/custom/saber_excalibur_charge.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(p2, 1, Vector(400, -1, -1))
    ParticleManager:SetParticleControl(p3, 1, Vector(300, 1, 1))
    ParticleManager:SetParticleControl(p4, 1, Vector(350, 0, 0))
    ParticleManager:ReleaseParticleIndex(p2)
    ParticleManager:ReleaseParticleIndex(p3)
    ParticleManager:ReleaseParticleIndex(p4)

    self:StartIntervalThink(1.1)
end

function modifier_excalibur_anim:OnIntervalThink()
    local parent = self:GetParent()
    local p1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:ReleaseParticleIndex(p1)

    self.p2 = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_overcharge.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControlEnt(self.p2, 0, parent, PATTACH_POINT_FOLLOW, "attach_sword", parent:GetAbsOrigin(), true)
    self:StartIntervalThink(-1)
end

function modifier_excalibur_anim:OnDestroy()
    ParticleManager:DestroyParticle(self.p2, false)
    ParticleManager:ReleaseParticleIndex(self.p2)
end

function modifier_excalibur_anim:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
    }
end

function modifier_excalibur_anim:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function modifier_excalibur_anim:GetOverrideAnimationRate()
    return 1.5
end
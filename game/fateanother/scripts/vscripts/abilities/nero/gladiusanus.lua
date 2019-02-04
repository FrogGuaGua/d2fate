---@class nero_gladiusanus_blauserum : CDOTA_Ability_Lua
nero_gladiusanus_blauserum = {}

function nero_gladiusanus_blauserum:OnSpellStart()
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_gladiusanus_channel", {})
    self.modifier = caster:AddNewModifier(caster, self, "modifier_gladiusanus", {duration = self:GetSpecialValueFor("duration")})
    self.damage = 0
end

function nero_gladiusanus_blauserum:OnChannelThink(tick)
    self.damage = self.damage + self:GetCaster():GetAttackDamage() * ((self:GetSpecialValueFor("damage_pct")/100)/self:GetChannelTime()) * tick
    self.modifier:SetStackCount(math.floor(self.damage))
end

function nero_gladiusanus_blauserum:OnChannelFinish(bInterrupted)
    self:GetCaster():RemoveModifierByName("modifier_gladiusanus_channel")
end

LinkLuaModifier("modifier_gladiusanus_channel", "abilities/nero/gladiusanus", LUA_MODIFIER_MOTION_NONE)
---@class modifier_gladiusanus_channel : CDOTA_Modifier_Lua
modifier_gladiusanus_channel = {}

function modifier_gladiusanus_channel:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

function modifier_gladiusanus_channel:OnCreated(args)
    local ability = self:GetAbility()
    self.magic_res = ability:GetSpecialValueFor("channel_magicres")
    self.armor = ability:GetSpecialValueFor("channel_armor")
end

function modifier_gladiusanus_channel:GetModifierMagicalResistanceBonus()
    return self.magic_res
end

function modifier_gladiusanus_channel:GetModifierMagicalResistanceBonus()
    return self.armor
end

LinkLuaModifier("modifier_gladiusanus", "abilities/nero/gladiusanus", LUA_MODIFIER_MOTION_NONE)
---@class modifier_gladiusanus : CDOTA_Modifier_Lua
modifier_gladiusanus = {}

function modifier_gladiusanus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_gladiusanus:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end

if IsServer() then
    function modifier_gladiusanus:OnCreated(args)
        local parent = self:GetParent()
        self.pcf = ParticleManager:CreateParticle("particles/custom/nero/nero_scorched_earth.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControl(self.pcf, 1, Vector(300, 300, 300))
    end

    function modifier_gladiusanus:OnAttackStart(args)
        local parent = self:GetParent()
        if args.attacker == parent then
            parent:AddNewModifier(parent, self:GetAbility(), "modifier_gladiusanus_anim", {})
        end
    end

    function modifier_gladiusanus:OnAttackLanded(args)
        local caster = self:GetParent()
        local target = args.target
        if args.attacker == caster then
            if caster.IsPTBAcquired then
                local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
                local damage = caster:GetAgility() * 5
                for k,v in pairs(targets) do
                    DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, self:GetAbility(), false)
                end
            end

            caster:EmitSound("Nero.Gladiusanus")
            CreateSlashFx(caster, target:GetAbsOrigin()+Vector(250, 250, 0), target:GetAbsOrigin()+Vector(-250,-250,0))
            local flameFx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControl(flameFx, 2, target:GetAbsOrigin())
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, target)
            ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
            ParticleManager:SetParticleControl(particle, 1, Vector(300, 300, 300))
            ParticleManager:SetParticleControl(particle, 3, Vector(300, 300, 300))
            ParticleManager:ReleaseParticleIndex(flameFx)
            ParticleManager:ReleaseParticleIndex(particle)

            self:Destroy()
        end
    end

    function modifier_gladiusanus:OnDestroy()
        self:GetParent():RemoveModifierByName("modifier_gladiusanus_anim")
        ParticleManager:DestroyParticle(self.pcf, false)
        ParticleManager:ReleaseParticleIndex(self.pcf)
    end
end

LinkLuaModifier("modifier_gladiusanus_anim", "abilities/nero/gladiusanus", LUA_MODIFIER_MOTION_NONE)
---@class modifier_gladiusanus_anim : CDOTA_Modifier_Lua
modifier_gladiusanus_anim = {}

function modifier_gladiusanus_anim:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_gladiusanus_anim:GetOverrideAnimation()
    return ACT_DOTA_ATTACK_EVENT
end

function modifier_gladiusanus_anim:OnAttack(args)
    if args.attacker == self:GetParent() then
        self:Destroy()
    end
end
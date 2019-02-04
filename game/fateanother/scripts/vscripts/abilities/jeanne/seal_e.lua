---@class jeanne_seal_e : CDOTA_Ability_Lua
jeanne_seal_e = class({})
LinkLuaModifier("modifier_jeanne_reflect_enemy", "abilities/jeanne/seal_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_reflect_ally", "abilities/jeanne/seal_e", LUA_MODIFIER_MOTION_NONE)

function jeanne_seal_e:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:IsOpposingTeam(caster:GetTeam()) then
        target:AddNewModifier(caster, self, "modifier_jeanne_reflect_enemy", {duration = self:GetSpecialValueFor("debuff_duration")})
        target:EmitSound("ruler_amplify_damage")
    else
        target:AddNewModifier(caster, self, "modifier_jeanne_reflect_ally", {duration = self:GetSpecialValueFor("reflect_duration")})
        target:EmitSound("Item.LotusOrb.Target")
    end

    local spellbook = caster:FindAbilityByName("jeanne_seal_spellbook")
    if spellbook then spellbook:OnSealCast() end
end

---@class modifier_jeanne_reflect_enemy : CDOTA_Modifier_Lua
modifier_jeanne_reflect_enemy = class({})

if IsServer() then
    function modifier_jeanne_reflect_enemy:OnCreated(args)
        local parent = self:GetParent()
        self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(self.particle, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.particle, 2, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    end

    function modifier_jeanne_reflect_enemy:OnDestroy()
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
end

function modifier_jeanne_reflect_enemy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
    }
end

function modifier_jeanne_reflect_enemy:GetModifierPhysicalArmorBonus()
    return -(self:GetAbility():GetSpecialValueFor("armor_reduction"))
end

function modifier_jeanne_reflect_enemy:GetModifierMagicalResistanceBonus()
    return -(self:GetAbility():GetSpecialValueFor("mres_reduction_pct"))
end

---@class modifier_jeanne_reflect_ally : CDOTA_Modifier_Lua
modifier_jeanne_reflect_ally = class({})

function modifier_jeanne_reflect_ally:GetEffectName()
    return "particles/items3_fx/lotus_orb_shield.vpcf"
end

function modifier_jeanne_reflect_ally:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
    function modifier_jeanne_reflect_ally:DeclareFunctions()
        return {
            MODIFIER_PROPERTY_REFLECT_SPELL
        }
    end

    function modifier_jeanne_reflect_ally:GetReflectSpell(args)
        local parent = self:GetParent()
        local target = args.ability:GetCaster()

        if target:GetTeamNumber() == parent:GetTeamNumber() then return end
        if args.ability.bIsReflection then return end

        if parent.lastSpellReflected then
            parent:RemoveAbility(parent.lastSpellReflected:GetAbilityName())
            parent.lastSpellReflected = nil
        end

        local ability = parent:AddAbility(args.ability:GetAbilityName())
        ability:SetStolen(true)
        ability:SetHidden(true)
        ability.bIsReflection = true
        ability:SetLevel(args.ability:GetLevel())
        parent:SetCursorCastTarget(target)
        if bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_CHANNELLED) == DOTA_ABILITY_BEHAVIOR_CHANNELLED then
            ability:OnChannelFinish(false)
        else
            ability:OnSpellStart()
        end
        parent:EmitSound("Item.LotusOrb.Activate")
        parent.lastSpellReflected = ability

        local pcf = ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_reflect.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:ReleaseParticleIndex(pcf)
        self:Destroy()
    end

    function modifier_jeanne_reflect_ally:OnDestroy()
        self:GetParent():EmitSound("Item.LotusOrb.Destroy")
    end
end
gille_spellbook_of_prelati_pain = class({})
LinkLuaModifier("modifier_gille_spellbook_of_prelati_pain", "abilities/gille/gille_spellbook_of_prelati_pain", LUA_MODIFIER_MOTION_NONE)

function gille_spellbook_of_prelati_pain:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local ability = self
    if target:HasModifier("modifier_gille_spellbook_of_prelati_pain") then
        target:RemoveModifierByName("modifier_gille_spellbook_of_prelati_pain")
    end
    target:AddNewModifier(caster, ability, "modifier_gille_spellbook_of_prelati_pain", {duration = ability:GetSpecialValueFor("duration")})
end




modifier_gille_spellbook_of_prelati_pain = class({})
function modifier_gille_spellbook_of_prelati_pain:IsDebuff()  return true end


function modifier_gille_spellbook_of_prelati_pain:OnCreated(args)
    local ability = self:GetAbility()
    local target = self:GetParent()
    self.boom_damage = ability:GetSpecialValueFor("corpse_boom")
    self.corpse_explosion_ratio = ability:GetSpecialValueFor("corpse_boom_ratio")
    self.damage = ability:GetSpecialValueFor("damage_per_hit")
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("interval"))
    self.duration = ability:GetSpecialValueFor("duration")
    --self.fx = ParticleManager:CreateParticle("particles/custom/gille/gille_pain.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
end

function modifier_gille_spellbook_of_prelati_pain:OnIntervalThink()
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    local target = self:GetParent()
    DoDamage(caster, target, self.damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    if caster.IsBlackMagicImproved == true then
        local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        for _,v in pairs(targets) do
            if v ~= target then
                if v:HasModifier("modifier_gille_spellbook_of_prelati_pain") then
                    v:RemoveModifierByName("modifier_gille_spellbook_of_prelati_pain")
                end
                v:AddNewModifier(caster, ability, "modifier_gille_spellbook_of_prelati_pain", {duration = self.duration})
            end
        end
    end
end

function modifier_gille_spellbook_of_prelati_pain:OnDeath()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    print("sdasdasdasdasd")
    local targets = FindUnitsInRadius(caster:GetTeam(), self:GetParent():GetAbsOrigin(), nil, self.corpse_explosion_ratio, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
    for _,v in pairs(targets) do
        print(self.boom_damage)
        DoDamage(caster, v, self.boom_damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
        if v ~= target then
            if v:HasModifier("modifier_gille_spellbook_of_prelati_pain") then
                v:RemoveModifierByName("modifier_gille_spellbook_of_prelati_pain")
            end
            v:AddNewModifier(caster, ability, "modifier_gille_spellbook_of_prelati_pain", {duration = self.duration})
        end
    end
end

function modifier_gille_spellbook_of_prelati_pain:GetEffectName()
    return "particles/custom/gille/gille_pain.vpcf"
end

function modifier_gille_spellbook_of_prelati_pain:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_gille_spellbook_of_prelati_pain:RemoveOnDeath()
    return false
end



atalanta_last_spurt = class({})
LinkLuaModifier("modifier_last_spurt", "abilities/atalanta/modifier_last_spurt", LUA_MODIFIER_MOTION_NONE)

function atalanta_last_spurt:OnUpgrade()
    local caster = self:GetCaster()
    local ability = self

    if IsServer() and not caster.CastLastSpurt then
        function caster:CastLastSpurt(...)
            ability:OnSpellStart(...)
        end
    end
end

function atalanta_last_spurt:OnSpellStart()
    local caster = self:GetCaster()
    local aoe = self:GetSpecialValueFor("aoe")
    local duration = self:GetSpecialValueFor("duration")

    caster:EmitSound("Ability.Windrun")

    local stacks = 0
    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    for k,v in pairs(targets) do
        if not IsFacingUnit(v, caster, 180) then
            stacks = stacks + 1
        end
    end

    caster:RemoveModifierByName("modifier_last_spurt")
    caster:AddNewModifier(caster, self, "modifier_last_spurt", {
        duration = duration
    })
    caster:SetModifierStackCount("modifier_last_spurt", self, stacks)
end

function atalanta_last_spurt:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function atalanta_last_spurt:GetAbilityTextureName()
    return "custom/atalanta_last_spurt"
end
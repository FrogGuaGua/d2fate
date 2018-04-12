---@class jeanne_seal_w : CDOTA_Ability_Lua
jeanne_seal_w = class({})
LinkLuaModifier("modifier_jeanne_vitality", "abilities/jeanne/seal_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jeanne_vitality_debuff", "abilities/jeanne/seal_w", LUA_MODIFIER_MOTION_NONE)

function jeanne_seal_w:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:IsOpposingTeam(caster:GetTeam()) then
        target:AddNewModifier(caster, self, "modifier_jeanne_vitality_debuff", {duration = self:GetSpecialValueFor("debuff_duration")})
        target:EmitSound("DOTA_Item.UrnOfShadows.Activate")
    else
        target:AddNewModifier(caster, self, "modifier_jeanne_vitality", {duration = self:GetSpecialValueFor("buff_duration")})
        target:EmitSound("ruler_vitality_buff")
    end

    local spellbook = caster:FindAbilityByName("jeanne_seal_spellbook")
    if spellbook then spellbook:OnSealCast() end
end


---@class modifier_jeanne_vitality : CDOTA_Modifier_Lua
modifier_jeanne_vitality = class({})

function modifier_jeanne_vitality:GetEffectName()
    return "particles/econ/items/dazzle/dazzle_dark_light_weapon/dazzle_dark_shallow_grave.vpcf"
end

function modifier_jeanne_vitality:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_jeanne_vitality:DeclareFunctions()
    return { MODIFIER_PROPERTY_MIN_HEALTH }
end

function modifier_jeanne_vitality:GetMinHealth()
    return 1
end

---@class modifier_jeanne_vitality_debuff : CDOTA_Modifier_Lua
modifier_jeanne_vitality_debuff = class({})

function modifier_jeanne_vitality_debuff:GetEffectName()
    return "particles/items2_fx/urn_of_shadows_damage.vpcf"
end

function modifier_jeanne_vitality_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_jeanne_vitality_debuff:DisableHeal()
    return true
end
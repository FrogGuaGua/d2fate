---@class tamamo_armed_up : CDOTA_Ability_Lua
tamamo_armed_up = {}

function tamamo_armed_up:OnSpellStart()
    local caster = self:GetCaster()
    local charms = {
        "tamamo_fiery_heaven",
        "tamamo_frigid_heaven",
        "tamamo_swirling_heaven",
        "fate_empty1",
        "tamamo_armed_up_close",
        "fate_empty2",
        "attribute_bonus_custom"
    }
    if caster.IsSpiritTheftAcquired then charms[6] = "tamamo_chaos_heaven" end
    caster.spellbook_open = true
    UpdateAbilityLayout(caster, charms)
end

---@class tamamo_armed_up_close : CDOTA_Ability_Lua
tamamo_armed_up_close = {}

function tamamo_armed_up_close:OnSpellStart()
    local caster = self:GetCaster()
    local charms = {
        "tamamo_throw_charm",
        "tamamo_foxs_wedding",
        "tamamo_mantra",
        "fate_empty1",
        "tamamo_armed_up",
        "tamamo_amaterasu",
        "attribute_bonus_custom"
    }
    if caster.combo_ready or caster.IsEscapeAcquired then charms[4] = "tamamo_polygamist_castration_fist" end
    caster.spellbook_open = false
    UpdateAbilityLayout(caster, charms)
end
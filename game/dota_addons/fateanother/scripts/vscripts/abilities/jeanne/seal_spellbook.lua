---@class jeanne_seal_spellbook : CDOTA_Ability_Lua
jeanne_seal_spellbook = class({})
jeanne_seal_spellbook.IsResetable = false

function jeanne_seal_spellbook:OnToggle()
    if self:GetToggleState() then
        self:ToggleAbility()
        return
    end

    local seals = {
        "jeanne_seal_q",
        "jeanne_seal_w",
        "jeanne_seal_e",
        "fate_empty1",
        "jeanne_seal_spellbook_close",
        "jeanne_seal_r",
        "attribute_bonus_custom"
    }

    for k, v in pairs(seals) do
        if not self:GetCaster():HasAbility(v) then self:GetCaster():AddAbility(v):SetLevel(1) end
    end

    UpdateAbilityLayout(self:GetCaster(), seals)
end

function jeanne_seal_spellbook:OnSealCast()
    local caster = self:GetCaster()
    self:StartCooldown(self:GetSpecialValueFor("cooldown"))
    caster:FindAbilityByName("jeanne_seal_spellbook_close"):ToggleAbility()
    DoDamage(caster, caster, caster:GetMaxHealth() * (self:GetSpecialValueFor("health_cost_pct")/100), DAMAGE_TYPE_PURE, 0, self, false)
end


---@class jeanne_seal_spellbook_close : CDOTA_Ability_Lua
jeanne_seal_spellbook_close = class({})

function jeanne_seal_spellbook_close:OnToggle()
    if self:GetToggleState() then
        self:ToggleAbility()
        return
    end

    local caster = self:GetCaster()
    local abilities = {
        "jeanne_charisma",
        "jeanne_purge_the_unjust",
        "jeanne_gods_resolution",
        "jeanne_seal_spellbook",
        "jeanne_magic_resistance_ex",
        "jeanne_luminosite_eternelle",
        "attribute_bonus_custom"
    }

    if caster.bIsIDAcquired then abilities[5] = "jeanne_identity_discernment" end
    UpdateAbilityLayout(caster, abilities, false)
    caster:FindAbilityByName("attribute_bonus_custom"):SetHidden(false)
end
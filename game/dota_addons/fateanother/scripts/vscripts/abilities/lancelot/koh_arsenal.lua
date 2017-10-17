lancelot_knight_of_honor_arsenal = class({})

local tAbilities = {
    "lancelot_caliburn",
    "lancelot_snatch_strike",
    "lancelot_windblade",
    "lancelot_gb_thrown",
    "lancelot_knight_of_honor_arsenal_close",
    "lancelot_gae_dearg",
    "attribute_bonus_custom"
}

local tProxy = {
    "lancelot_caliburn",
    "fate_empty1",
    "fate_empty2",
    "fate_empty3",
    "lancelot_knight_of_honor_arsenal_close",
    "fate_empty4",
    "attribute_bonus_custom"
}

function lancelot_knight_of_honor_arsenal:OnUpgrade()
    local hCaster = self:GetCaster()
    local hAbility = hCaster:FindAbilityByName("lancelot_knight_of_honor")

    if hAbility:GetLevel() ~= self:GetLevel() then
        hAbility:SetLevel(self:GetLevel())
    end

    for i = 1, self:GetLevel() do
        if not hCaster:HasAbility(tAbilities[i]) then
            local abil = hCaster:AddAbility(tAbilities[i])
            abil:SetLevel(1)
            abil:SetHidden(true)
        end

        if i == 5 then
            if not hCaster:HasAbility(tAbilities[6]) then
                local abil = hCaster:AddAbility(tAbilities[6])
                abil:SetLevel(1)
                abil:SetHidden(true)
            end
        end
    end
end

function lancelot_knight_of_honor_arsenal:OnSpellStart()
    local hCaster = self:GetCaster()
    local iLevel = self:GetLevel()
    local t = {}

    for i = 1, #tAbilities do
        if not hCaster:HasAbility(tAbilities[i]) then
            t[i] = tProxy[i]
        else
            t[i] = tAbilities[i]
        end
    end

    UpdateAbilityLayout(hCaster, t)
end

function lancelot_knight_of_honor_arsenal:CastFilterResult()
    if self:GetCaster():HasModifier("modifier_arondite") then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function lancelot_knight_of_honor_arsenal:GetCustomCastError()
    return "#Cannot_Be_Cast_Now"
end
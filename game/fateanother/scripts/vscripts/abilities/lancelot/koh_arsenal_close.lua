lancelot_knight_of_honor_arsenal_close = class({})

function lancelot_knight_of_honor_arsenal_close:OnSpellStart()
    local hCaster = self:GetCaster()

    local tAbilities = {
        "lancelot_smg_barrage",
        "lancelot_double_edge",
        "lancelot_knight_of_honor_arsenal",
        "rubick_empty1",
        "lancelot_arms_mastership",
        "lancelot_arondite",
        "attribute_bonus_custom",
    }

    if hCaster.nukeAvail then
        tAbilities[4] = "lancelot_nuke"
    elseif hCaster:HasAbility("lancelot_blessing_of_fairy") then
        tAbilities[4] = "lancelot_blessing_of_fairy"
    end

    UpdateAbilityLayout(hCaster, tAbilities)
end
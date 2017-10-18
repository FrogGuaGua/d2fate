atalanta_attribute_arrows_of_the_big_dipper = class({})
LinkLuaModifier("modifier_arrows_of_the_big_dipper", "abilities/atalanta/modifier_arrows_of_the_big_dipper", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bow_of_heaven", "abilities/atalanta/modifier_bow_of_heaven", LUA_MODIFIER_MOTION_NONE)

atalanta_attribute_hunters_mark = class({})
atalanta_attribute_golden_apple = class({})
atalanta_attribute_crossing_arcadia_plus = class({})
atalanta_attribute_bow_of_heaven = class({})


function atalanta_attribute_arrows_of_the_big_dipper:GetAbilityTextureName()
    return "custom/atalanta_arrows_of_the_big_dipper"
end

function atalanta_attribute_hunters_mark:GetAbilityTextureName()
    return "custom/atalanta_hunters_mark"
end

function atalanta_attribute_golden_apple:GetAbilityTextureName()
    return "custom/atalanta_golden_apple"
end

function atalanta_attribute_crossing_arcadia_plus:GetAbilityTextureName()
    return "custom/atalanta_crossing_arcadia"
end
function atalanta_attribute_bow_of_heaven:GetAbilityTextureName()
    return "custom/atalanta_bow_of_heaven"
end



function WrapAttributes(ability, attributeName, callback)
    function ability:OnSpellStart()
        local caster = self:GetCaster()
        local player = caster:GetPlayerOwner()
        local hero = caster:GetPlayerOwner():GetAssignedHero()

        hero[attributeName] = true

    	local master = hero.MasterUnit
    	master:SetMana(master:GetMana() - self:GetManaCost(1))

        if callback then
            callback(self, hero)
        end
    end
end

WrapAttributes(atalanta_attribute_hunters_mark, "HuntersMarkAcquired")
WrapAttributes(atalanta_attribute_golden_apple, "GoldenAppleAcquired")
WrapAttributes(atalanta_attribute_bow_of_heaven, "BowOfHeavenAcquired", function(ability,hero)
    local fExtraRange = ability:GetSpecialValueFor("r_extra_range")
    local fAgiScaling = ability:GetSpecialValueFor("r_agi_scaling")
    local fMaxDist = ability:GetSpecialValueFor("phoebus_max_distance_from_r")
    CustomNetTables:SetTableValue("sync","atalanta_bow_of_heaven", {fExtraRange = fExtraRange, fAgiScaling = fAgiScaling, fMaxDist = fMaxDist})
    Timers:CreateTimer(function()
        if not hero:IsAlive() then
            return 1
        else
            hero:AddNewModifier(hero, nil, "modifier_bow_of_heaven", {Duration = -1})
            return nil
        end
    end)
end)

WrapAttributes(atalanta_attribute_crossing_arcadia_plus, "CrossingArcadiaPlusAcquired", function(ability, hero)
    hero:FindAbilityByName("atalanta_crossing_arcadia"):SetLevel(2)
end)

WrapAttributes(atalanta_attribute_arrows_of_the_big_dipper, "ArrowsOfTheBigDipperAcquired", function(ability, hero)
    local fExtraRange = ability:GetSpecialValueFor("attribute_bonus_range")
    local fVisionRadius = ability:GetSpecialValueFor("attribute_vision_radius")
    local fVisionDuration = ability:GetSpecialValueFor("attribute_vision_duration")
    local fArrowsNeeded = ability:GetSpecialValueFor("attribute_arrows_needed")
    local fRangePerAGI = ability:GetSpecialValueFor("attribute_range_per_agi")
    local fAOEPerAGI = ability:GetSpecialValueFor("attribute_aoe_per_agi")
    CustomNetTables:SetTableValue("sync","atalanta_big_dipper", {fExtraRange = fExtraRange, fVisionRadius = fVisionRadius, fVisionDuration = fVisionDuration, fArrowsNeeded = fArrowsNeeded, fRangePerAGI = fRangePerAGI, fAOEPerAGI = fAOEPerAGI})
    hero:AddNewModifier(hero, nil, "modifier_arrows_of_the_big_dipper", {})

    function hero:CheckBonusArrow(keys)
        if not hero:HasModifier("modifier_arrows_of_the_big_dipper") then
            hero:AddNewModifier(hero, nil, "modifier_arrows_of_the_big_dipper", {})
        end

        local arrowsUsed = hero:GetModifierStackCount("modifier_arrows_of_the_big_dipper", caster)
	arrowsUsed = arrowsUsed + 1

        if arrowsUsed >= ability:GetSpecialValueFor("attribute_arrows_needed") then
            local copyKeys = {}
            for k,v in pairs(keys) do
                copyKeys[k] = v
            end
            copyKeys.DontCountArrow = true 
            copyKeys.DontUseArrow = true 

	    Timers:CreateTimer(0.1, function()
	        hero:ShootArrow(copyKeys)
            end)

	    arrowsUsed = 0
        end

	hero:SetModifierStackCount("modifier_arrows_of_the_big_dipper", hero, arrowsUsed)
    end
end)

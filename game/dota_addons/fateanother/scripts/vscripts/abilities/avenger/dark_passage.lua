avenger_dark_passage = class({})
LinkLuaModifier("modifier_dark_passage", "abilities/avenger/modifier_dark_passage", LUA_MODIFIER_MOTION_NONE)

function avenger_dark_passage:OnSpellStart()
    local hCaster = self:GetCaster()
    local vPos = self:GetCursorPosition()
    local fRange = self:GetSpecialValueFor("range")
    local fHealthCost = self:GetSpecialValueFor("health_cost")
    local fPenaltyCooldown = self:GetSpecialValueFor("penalty_cooldown")

    if hCaster.IsDPImproved then
        self:EndCooldown()
        self:StartCooldown(1)
        fRange = 1000
    end

    local currentStack = hCaster:GetModifierStackCount("modifier_dark_passage", self)
    currentHealthCost = fHealthCost * 2 ^ currentStack
    if currentStack == 0 and hCaster:HasModifier("modifier_dark_passage") then currentStack = 1 end
    hCaster:RemoveModifierByName("modifier_dark_passage")  
    hCaster:AddNewModifier(hCaster, self, "modifier_dark_passage", { Duration = 15 })
    hCaster:SetModifierStackCount("modifier_dark_passage", self, currentStack + 1)

    if hCaster:GetHealth() <= currentHealthCost then
        hCaster:SetHealth(1)
        self:StartCooldown(fPenaltyCooldown)
    else
        hCaster:SetHealth(hCaster:GetHealth() - currentHealthCost)
    end
    
    hCaster:EmitSound("Hero_ShadowDemon.ShadowPoison.Release")
    local tParams = {
        sInEffect = hCaster:HasModifier("modifier_true_form") and "particles/custom/avenger/avenger_dark_passage_start_trueform.vpcf" or "particles/custom/avenger/avenger_dark_passage_start.vpcf",
        sOutEffect = hCaster:HasModifier("modifier_true_form") and "particles/custom/avenger/avenger_dark_passage_end_trueform.vpcf" or "particles/custom/avenger/avenger_dark_passage_end.vpcf"
    }
    AbilityBlink(hCaster, vPos, fRange, tParams)
end

function avenger_dark_passage:CastFilterResultLocation( vLocation )
    if IsServer() then return AbilityBlinkCastError(self:GetCaster(), vLocation) end
end

function avenger_dark_passage:GetCustomCastErrorLocation( vLocation )
    return "#Cannot_Blink"
end

function avenger_dark_passage:OnOwnerSpawned()
    self:EndCooldown()
end
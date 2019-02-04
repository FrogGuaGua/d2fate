lvbu_prick_poke = class({})


function lvbu_prick_poke:GetDamage()
    return self:GetSpecialValueFor("basedamage")
end

function lvbu_prick_poke:GetRatio()
    return self:GetSpecialValueFor("ratio")
end


if IsClient() then
    return 
end

function lvbu_prick_poke:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetTarget()
    
end
modifier_dark_passage = class({})

function modifier_dark_passage:IsDebuff()
    return true
end

function modifier_dark_passage:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
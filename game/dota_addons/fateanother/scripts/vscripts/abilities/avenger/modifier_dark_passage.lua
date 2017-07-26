modifier_dark_passage = class({})

function modifier_dark_passage:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_RESPAWN
    }
    return funcs
end

function modifier_dark_passage:IsDebuff()
    return true
end

function modifier_dark_passage:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_dark_passage:OnRespawn(args)
    local hUnit = args.unit
    local hParent = self:GetParent()
    if hUnit == hParent then
        local hAbility = hParent:FindAbilityByName("avenger_dark_passage") 
        hAbility:EndCooldown()
        self:Destroy()
    end
end
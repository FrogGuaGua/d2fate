modifier_sex_scroll_slow = class({})

function modifier_sex_scroll_slow:OnCreated()
    self.slowPerc = -100.0
    self.slowDur = 3.0
    self:StartIntervalThink(0.1)
end

function modifier_sex_scroll_slow:OnRefresh()
    self:OnCreated()
end

function modifier_sex_scroll_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
 
    return funcs
end

function modifier_sex_scroll_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.slowPerc
end

function modifier_sex_scroll_slow:OnIntervalThink()
    if self.slowDur > 0 then
        self.state = {}
        self.slowPerc = self.slowPerc + (100.0 / 3.0 * 0.1)
        self.slowDur = self.slowDur - 0.1
    else  
        self:StartIntervalThink(-1)
        self:Destroy()
    end
end

-----------------------------------------------------------------------------------
function modifier_sex_scroll_slow:GetEffectName()
    return "particles/items_fx/diffusal_slow.vpcf"
end

function modifier_sex_scroll_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_sex_scroll_slow:GetAttributes() 
    return MODIFIER_ATTRIBUTE_NONE
end

function modifier_sex_scroll_slow:IsPurgable()
    return false
end

function modifier_sex_scroll_slow:IsDebuff()
    return true
end


function modifier_sex_scroll_slow:RemoveOnDeath()
    return true
end

function modifier_sex_scroll_slow:GetTexture()
    return "custom/s_scroll"
end
-----------------------------------------------------------------------------------

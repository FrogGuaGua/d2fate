modifier_priestess_of_the_hunt = class({})

local THINK_INTERVAL = 0.05
function modifier_priestess_of_the_hunt:OnCreated()
    local hero = self:GetParent()
    if IsServer() then
        hero.NextArrow = 0

        self:SetStackCount(self:GetMaxStackCount())
        self:StartIntervalThink(THINK_INTERVAL)
    end

    local modifier = self

    function hero:HasArrow()
        return modifier:GetStackCount() > 0
    end

    function hero:GetArrowCount()
        return modifier:GetStackCount()
    end

    function hero:UseArrow(number)
        local count = modifier:GetStackCount()
        modifier:SetStackCount(math.max(count - number, 0))
    end

    function hero:AddArrows(number)
        local count = modifier:GetStackCount()
        modifier:SetStackCount(count + number)

        if (count + number) >= modifier:GetMaxStackCount() then
            hero.NextArrow = 0
            modifier:UpdateProgress()
        end
    end

    function hero:CapArrows()
        if IsServer() then
            local count = modifier:GetStackCount()
            modifier:SetStackCount(math.min(count, modifier:GetMaxStackCount()))
        end
    end
end

function modifier_priestess_of_the_hunt:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_RESPAWN,
    }
 
    return funcs
end

function modifier_priestess_of_the_hunt:OnRespawn()
    self:SetStackCount(self:GetMaxStackCount())
    local hero = self:GetParent()
    hero.NextArrow = 0
    self:UpdateProgress()
end

function modifier_priestess_of_the_hunt:GetMaxStackCount()
    local ability = self:GetAbility()
    local arrows = ability:GetSpecialValueFor("arrows")

    local hero = self:GetParent()
    local celestialArrow = hero:FindAbilityByName("atalanta_celestial_arrow")
    arrows = arrows + celestialArrow:GetSpecialValueFor("bonus_arrows")

    return arrows
end

function modifier_priestess_of_the_hunt:OnIntervalThink()
    if IsServer() then
        local hero = self:GetParent()
        local nextArrow = hero.NextArrow

        if self:GetStackCount() >= self:GetMaxStackCount() then
                return
        end

        nextArrow = nextArrow + hero:GetAttacksPerSecond() * THINK_INTERVAL

        if nextArrow >= 1 then
            nextArrow = nextArrow - 1
            self:SetStackCount(self:GetStackCount() + 1)
        end

        hero.NextArrow = nextArrow

        self:UpdateProgress()
    end
end

function modifier_priestess_of_the_hunt:UpdateProgress() 
    local hero = self:GetParent()
    local progress = hero:FindModifierByName("modifier_priestess_of_the_hunt_progress")
    progress:SetStackCount(hero.NextArrow * 100)
end

function modifier_priestess_of_the_hunt:GetAttributes() 
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_priestess_of_the_hunt:IsDebuff()
    return false
end

function modifier_priestess_of_the_hunt:RemoveOnDeath()
    return false
end

function modifier_priestess_of_the_hunt:GetTexture()
    return "custom/atalanta_priestess_of_the_hunt"
end

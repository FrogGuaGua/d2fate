LinkLuaModifier("modifier_nero_tanoxi", "abilities/nero/rosa_ichthys", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("nero_rosa_ichthys", "abilities/nero/rosa_ichthys", LUA_MODIFIER_MOTION_NONE)

modifier_nero_tanoxi = class({})
function modifier_nero_tanoxi:GetIntrinsicModifierName()
    return "modifier_nero_tanoxi"
end

function modifier_nero_tanoxi:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS
    }
end

function modifier_nero_tanoxi:GetStack()
    local caster = self:GetCaster()
    local modifier = caster:FindModifierByName("modifier_nero_tanoxi")
    local currentStack = modifier and modifier:GetStackCount() or 0
    return currentStack
end

function modifier_nero_tanoxi:GetStackValue()
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("nero_rosa_ichthys")
    return ability:GetSpecialValueFor("bonus_agi")
end

function modifier_nero_tanoxi:GetModifierBonusStats_Agility()
    return self:GetStack() * self:GetStackValue()
end

function modifier_nero_tanoxi:OnDestory()
    UTIL_Remove(self:GetParent())
end

nero_rosa_ichthys = class({})
function nero_rosa_ichthys:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local player = caster:GetPlayerOwner()
    local dmg = self:GetSpecialValueFor("damage")
    if caster:HasModifier("modifier_nero_tanoxi") then
        local modifier = caster:FindModifierByName("modifier_nero_tanoxi")
        local currentStack = modifier and modifier:GetStackCount() or 0
        if currentStack > 5 then
            self:EndCooldown()
            if caster.IsPavilionAcquired == true then
                self:StartCooldown(0.8)
            else
                self:StartCooldown(1.0)
            end
            caster:GiveMana(200)
        end
        caster:RemoveModifierByName("modifier_nero_tanoxi")
        caster:AddNewModifier(
            caster,
            self,
            "modifier_nero_tanoxi",
            {
                duration = self:GetSpecialValueFor("duration")
            }
        )

        if currentStack > 19 then
            currentStack = 19
        end
        caster:SetModifierStackCount("modifier_nero_tanoxi", self, currentStack + 1)
        if target == caster.Focus then
            if currentStack > 18 then
                currentStack = 18
            end
            caster:SetModifierStackCount("modifier_nero_tanoxi", self, currentStack + 2)
        end
    else
        caster:AddNewModifier(
            caster,
            self,
            "modifier_nero_tanoxi",
            {
                duration = self:GetSpecialValueFor("duration")
            }
        )
        caster:SetModifierStackCount("modifier_nero_tanoxi", self, 1)
        if target == caster.Focus then
            caster:SetModifierStackCount("modifier_nero_tanoxi", self, 2)
        end
    end
    caster:SetAbsOrigin(target:GetAbsOrigin())
    FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
    local flower = ParticleManager:CreateParticle("particles/custom/nero/nero_q.vpcf", PATTACH_ABSORIGIN, target)
    Timers:CreateTimer(
        1.5,
        function()
            ParticleManager:DestroyParticle(flower, false)
            ParticleManager:ReleaseParticleIndex(flower)
        end
    )
    
    if caster.IsPavilionAcquired == true then
        dmg = dmg + caster:GetAgility() * 3
        caster:PerformAttack( target, true, true, true, true, false, false, true )
        target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 0.5})
    else
        target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 0.1})
    end
    DoDamage(caster, target, dmg, DAMAGE_TYPE_MAGICAL, 0, self, false)
    caster:SetAbsOrigin(target:GetAbsOrigin() - RandomVector(100))
    FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
    caster:SetForwardVector((target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized())
    caster:EmitSound("Nero.Gladiusanus")
end

modifier_workshop_recall = class({})

function modifier_workshop_recall:GetEffectName()
    return "particles/units/heroes/hero_wisp/wisp_relocate_channel.vpcf"
end

function modifier_workshop_recall:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_workshop_recall:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_DEATH,
    }

    return funcs
end

function modifier_workshop_recall:OnCreated(args)
    self.bDamageFlag = false
end

if IsServer() then
    function modifier_workshop_recall:OnDestroy(args)
        local hParent = self:GetParent()
        local hCaster = self:GetCaster()

        if not self.bDamageFlag then
            local vCaster = hCaster:GetAbsOrigin()

            local pcTeleportOut = ParticleManager:CreateParticle("particles/custom/caster/caster_recall_out.vpcf", PATTACH_CUSTOMORIGIN, hParent)
            ParticleManager:SetParticleControl(pcTeleportOut, 0, hParent:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(pcTeleportOut)

            hParent:SetAbsOrigin(vCaster)
            FindClearSpaceForUnit(hParent, hParent:GetAbsOrigin(), true)

            local pcTeleportIn = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_ABSORIGIN, target)
            ParticleManager:ReleaseParticleIndex(pcTeleportIn)
        end
    end

    function modifier_workshop_recall:OnTakeDamage(args)
        if args.unit == self:GetParent() then
            self.bDamageFlag = true
            self:Destroy()
        end
    end

    function modifier_workshop_recall:OnDeath(args)
        if args.unit == self:GetCaster() then
            self.bDamageFlag = true
            self:Destroy()
        end
    end
end
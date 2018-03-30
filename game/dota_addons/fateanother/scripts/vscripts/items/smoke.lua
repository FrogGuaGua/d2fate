---@class item_smoke : CDOTA_Item_Lua
item_smoke = class({})

LinkLuaModifier("modifier_smoke", "items/smoke", LUA_MODIFIER_MOTION_NONE)

function item_smoke:IsStackable()
    return true
end

function item_smoke:OnSpellStart()
    local caster = self:GetCaster()
    local pcfSmoke = ParticleManager:CreateParticle("particles/items2_fx/smoke_of_deceit.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(pcfSmoke, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(pcfSmoke, 1, Vector(1000, 1000, 1000))
    ParticleManager:ReleaseParticleIndex(pcfSmoke)
    caster:EmitSound("DOTA_Item.SmokeOfDeceit.Activate")

    local targets = FindUnitsInRadius(
        caster:GetTeam(),
        caster:GetAbsOrigin(),
        nil,
        self:GetSpecialValueFor("radius"),
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,
        0,
        FIND_ANY_ORDER,
        false
    )

    for k, v in pairs(targets) do
        ProjectileManager:ProjectileDodge(v)
        v:AddNewModifier(caster, self, "modifier_smoke", {duration = self:GetSpecialValueFor("duration"), radius = self:GetSpecialValueFor("detection_radius")})
    end

    self:SpendCharge()
end

---@class modifier_smoke : CDOTA_Modifier_Lua
modifier_smoke = class({})

if IsServer() then
    function modifier_smoke:OnCreated(args)
        self.radius = args.radius
        self:StartIntervalThink(FrameTime())
    end

    function modifier_smoke:OnIntervalThink()
        local parent = self:GetParent()
        local area = FindUnitsInRadius(
            parent:GetTeam(),
            parent:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            0,
            FIND_ANY_ORDER,
            false
        )

        if area[1] then self:Destroy() end
    end
end

function modifier_smoke:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true
    }
end

function modifier_smoke:GetEffectName()
    return "particles/items2_fx/smoke_of_deceit_buff.vpcf"
end

function modifier_smoke:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_smoke:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_smoke:OnAttackLanded(args)
    if args.attacker == self:GetParent() then
        self:Destroy()
    end
end

function modifier_smoke:GetModifierInvisibilityLevel()
    return 1.0
end

function modifier_smoke:GetTexture()
    return "custom/smoke_of_deceit"
end
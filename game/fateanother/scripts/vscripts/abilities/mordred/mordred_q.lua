---@class mordred_q_1 : CDOTA_Ability_Lua
mordred_q_1 = class({})

LinkLuaModifier("modifier_mordred_q", "abilities/mordred/modifier_mordred_q", LUA_MODIFIER_MOTION_NONE)

function mordred_q_1:OnSpellStart()
    local caster = self:GetCaster()
    local endRad = self:GetSpecialValueFor("end_radius")

    local projectile = {
        Ability = self,
        EffectName = nil,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = self:GetSpecialValueFor("range") - endRad,
        fStartRadius = self:GetSpecialValueFor("start_radius"),
        fEndRadius = endRad,
        Source = caster,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 4.0,
        vVelocity = caster:GetForwardVector() * 1800,
    }
    ProjectileManager:CreateLinearProjectile(projectile)

    local pcfHit = ParticleManager:CreateParticle("particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControlForward(pcfHit, 0, caster:GetForwardVector())
    ParticleManager:ReleaseParticleIndex(pcfHit)

    caster:SwapAbilities("mordred_q_1", "mordred_q_2", false, true)
    caster:AddNewModifier(caster, self, "modifier_mordred_q", {duration = 5})
end

function mordred_q_1:OnProjectileHit(hTarget, vLocation)
    if not hTarget then return end
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage") + caster:GetAttackDamage() * self:GetSpecialValueFor("ad_scaling")
    DoDamage(caster, hTarget, damage, DAMAGE_TYPE_PHYSICAL, 0, self, false)
end

---@class mordred_q_2 : CDOTA_Ability_Lua
mordred_q_2 = class({})

LinkLuaModifier("modifier_mordred_q_charge", "abilities/mordred/mordred_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_q_knockback", "abilities/mordred/mordred_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_q_slow", "abilities/mordred/mordred_q", LUA_MODIFIER_MOTION_NONE)

function mordred_q_2:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    caster:AddNewModifier(caster, self, "modifier_mordred_q_charge", {duration = -1, speed = 1800, target = target:GetEntityIndex()})

    caster:SwapAbilities("mordred_q_2", "mordred_q_3", false, true)
    caster:AddNewModifier(caster, self, "modifier_mordred_q", {duration = 5})
end

---@class modifier_mordred_q_charge : CDOTA_Modifier_Lua
modifier_mordred_q_charge = class({})

if IsServer() then
    function modifier_mordred_q_charge:OnCreated(args)
        local ability = self:GetAbility()
        self.speed = args.speed
        self.target = EntIndexToHScript(args.target)
        self.knockback = ability:GetSpecialValueFor("knockback")
        self.slow = ability:GetSpecialValueFor("slow_duration")
        self.damage = ability:GetSpecialValueFor("damage")
        self:StartIntervalThink(FrameTime())
    end

    function modifier_mordred_q_charge:OnIntervalThink()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local pos = parent:GetAbsOrigin()
        local between = self.target:GetAbsOrigin() - pos
        local to = GetGroundPosition(pos + between:Normalized() * self.speed * FrameTime(), parent)

        if not GridNav:IsTraversable(to) or GridNav:IsBlocked(to) or between:Length2D() < parent:GetHullRadius() + self.target:GetHullRadius() then
            self:Destroy()
            return
        end

        local hitTargets = FindUnitsInRadius(parent:GetTeam(), to, nil, 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        for k, v in pairs(hitTargets) do
            if not v:HasModifier("modifier_mordred_q_knockback") then
                local damage = self.damage
                v:AddNewModifier(parent, ability, "modifier_mordred_q_knockback", { duration = self.knockback, distance = 100, height = 200, source = parent:GetEntityIndex()})
                v:AddNewModifier(parent, ability, "modifier_stunned", { duration = self.knockback })
                if v == self.target then v:AddNewModifier(parent, ability, "modifier_mordred_q_slow", {duration = self.slow}) else damage = damage / 2 end
                DoDamage(parent, v, damage, DAMAGE_TYPE_PHYSICAL, 0, self, false)
            end
        end

        parent:SetAbsOrigin(to)
    end

    function modifier_mordred_q_charge:OnDestroy()
        local parent = self:GetParent()
        FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
    end

    function modifier_mordred_q_charge:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ORDER,
            MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
        }
    end

    function modifier_mordred_q_charge:OnOrder(args)
        if args.unit ~= self:GetParent() then return end
        local order = args.order_type
        local validOrders = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 21}

        for _, v in pairs(validOrders) do
            if order == v then
                self:Destroy()
                break
            end
        end
    end

    function modifier_mordred_q_charge:GetModifierMoveSpeed_Absolute()
        return 0
    end
end

modifier_mordred_q_charge.IsHidden = function(obj) return true end
modifier_mordred_q_charge.GetEffectName = function(obj) return "particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge_wave.vpcf" end
modifier_mordred_q_charge.GetEffectAttachType = function(obj) return PATTACH_ABSORIGIN_FOLLOW end

---@class modifier_mordred_q_knockback : CDOTA_Modifier_Lua
modifier_mordred_q_knockback = class({})

if IsServer() then
    function modifier_mordred_q_knockback:OnCreated(args)
        local parent = self:GetParent()
        local source = EntIndexToHScript(args.source):GetAbsOrigin()
        local normal = (parent:GetAbsOrigin() - source):Normalized()

        self.airTime = self:GetDuration()
        local speed = args.distance / self.airTime
        self.zVel = (args.height/self.airTime) * 4
        self.direction = Vector(normal.x * speed, normal.y * speed, self.zVel)

        self:StartIntervalThink(FrameTime())
    end

    function modifier_mordred_q_knockback:OnIntervalThink()
        local parent = self:GetParent()
        self.direction.z = self.direction.z - ((self.zVel/self.airTime) * 2 * FrameTime())
        parent:SetAbsOrigin(parent:GetAbsOrigin() + self.direction * FrameTime())
    end

    function modifier_mordred_q_knockback:OnDestroy()
        local parent = self:GetParent()
        FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
    end
end

modifier_mordred_q_knockback.IsHidden = function(obj) return true end


---@class modifier_mordred_q_slow : CDOTA_Modifier_Lua
modifier_mordred_q_slow = class({})

function modifier_mordred_q_slow:OnCreated(args)
    self.slow = -self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_mordred_q_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_mordred_q_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

---@class mordred_q_3 : CDOTA_Ability_Lua
mordred_q_3 = class({})

LinkLuaModifier("modifier_mordred_q_leap", "abilities/mordred/mordred_q", LUA_MODIFIER_MOTION_NONE)

function mordred_q_3:OnSpellStart()
    local caster = self:GetCaster()
    local to = self:GetCursorPosition()
    local airTime = self:GetSpecialValueFor("air_time")
    local between = (to - caster:GetAbsOrigin())
    local speed = between:Length() / airTime
    local normal = between:Normalized()

    caster:AddNewModifier(caster, self, "modifier_mordred_q_leap", {duration = airTime, xDirection = normal.x, yDirection = normal.y, speed = speed})
end

function mordred_q_3:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function mordred_q_3:CastFilterResultLocation(vLocation)
    if IsServer() then
        if not GridNav:IsTraversable(vLocation) or GridNav:IsBlocked(vLocation) then return UF_FAIL_CUSTOM end
    end

    return UF_SUCCESS
end

function mordred_q_3:GetCustomCastErrorLocation(vLocation)
    return "#Cannot_Travel"
end

---@class modifier_mordred_q_leap : CDOTA_Modifier_Lua
modifier_mordred_q_leap = class({})

if IsServer() then
    function modifier_mordred_q_leap:OnCreated(args)
        local parent = self:GetParent()
        local speed = args.speed
        local height = 400

        local dust = ParticleManager:CreateParticle("particles/dev/library/base_dust_hit.vpcf", PATTACH_ABSORIGIN, parent)
        ParticleManager:ReleaseParticleIndex(dust)

        self.airTime = self:GetDuration()
        self.zVel = (height / self.airTime) * 4
        self.direction = Vector(args.xDirection * speed, args.yDirection * speed, self.zVel)

        self:StartIntervalThink(FrameTime())
    end

    function modifier_mordred_q_leap:OnIntervalThink()
        local parent = self:GetParent()
        self.direction.z = self.direction.z - ((self.zVel/self.airTime) * 2 * FrameTime())
        parent:SetAbsOrigin(parent:GetAbsOrigin() + self.direction * FrameTime())
    end

    function modifier_mordred_q_leap:OnDestroy()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local damage = ability:GetSpecialValueFor("damage")
        local pos = parent:GetAbsOrigin()
        local radius = ability:GetSpecialValueFor("radius")
        local targets = FindUnitsInRadius(parent:GetTeam(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

        for k, v in pairs(targets) do
            if not v:IsMagicImmune() then v:AddNewModifier(parent, ability, "modifier_stunned", {duration = ability:GetSpecialValueFor("stun")}) end
            DoDamage(parent, v, damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
        end

        local dust = ParticleManager:CreateParticle("particles/dev/library/base_dust_hit.vpcf", PATTACH_ABSORIGIN, parent)
        ParticleManager:ReleaseParticleIndex(dust)
        FindClearSpaceForUnit(parent, pos, true)
    end

    function modifier_mordred_q_leap:CheckState()
        return {
            [MODIFIER_STATE_STUNNED] = IsServer()
        }
    end
end

modifier_mordred_q_leap.IsHidden = function(obj) return true end

---@class mordred_q_4 : CDOTA_Ability_Lua
mordred_q_4 = class({})

LinkLuaModifier("modifier_mordred_q_throw", "abilities/mordred/mordred_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_q_throw_hurt", "abilities/mordred/mordred_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mordred_q_skewer", "abilities/mordred/mordred_q", LUA_MODIFIER_MOTION_NONE)

function mordred_q_4:OnSpellStart()
    local caster = self:GetCaster()
    local to = self:GetCursorPosition()
    local between = (to - caster:GetAbsOrigin())
    local maxDistance = self:GetSpecialValueFor("range")
    local distance = between:Length2D()
    local direction = between:Normalized()
    local maxTravelTime = self:GetSpecialValueFor("travel_time")
    local travelTime = maxTravelTime * (distance/maxDistance)

    local args = {
        duration = travelTime,
        xDirection = direction.x,
        yDirection = direction.y,
        maxTravelTime = maxTravelTime,
        maxDistance = maxDistance,
    }

    caster:AddNewModifier(caster, self, "modifier_mordred_q_throw", args)
end

function mordred_q_4:CastFilterResultLocation(vLocation)
    local caster = self:GetCaster()
    if (vLocation - caster:GetAbsOrigin()):Length2D() < 200 then return UF_FAIL_CUSTOM end
    return UF_SUCCESS
end

function mordred_q_4:GetCustomCastErrorLocation(vLocation)
    return "#Cannot_Travel"
end


---@class modifier_mordred_q_throw : CDOTA_Modifier_Lua
modifier_mordred_q_throw = class({})

if IsServer() then
    function modifier_mordred_q_throw:OnCreated(args)
        local parent = self:GetParent()
        self.damage = self:GetAbility():GetSpecialValueFor("damage")
        self.speed = args.maxDistance/args.maxTravelTime
        self.direction = Vector(args.xDirection, args.yDirection, 0)
        self.next = parent:GetAbsOrigin() + self.direction * self.speed * FrameTime()

        self.pcf = ParticleManager:CreateParticle("particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf", PATTACH_ABSORIGIN, parent)
        ParticleManager:SetParticleControlForward(self.pcf, 3, self.direction)
        ParticleManager:SetParticleControl(self.pcf, 1, self.direction * self.speed)

        self:StartIntervalThink(FrameTime())
    end

    function modifier_mordred_q_throw:OnIntervalThink()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        self.next = self.next + self.direction * self.speed * FrameTime()
        local targets = FindUnitsInRadius(parent:GetTeam(), self.next, nil, 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        for k, v in pairs(targets) do
            if not v:HasModifier("modifier_mordred_q_throw_hurt") then
                v:AddNewModifier(parent, ability, "modifier_mordred_q_throw_hurt", {duration = self:GetDuration()})
                DoDamage(parent, v, self.damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
            end
        end
    end

    function modifier_mordred_q_throw:OnDestroy()
        ParticleManager:DestroyParticle(self.pcf, false)
        ParticleManager:ReleaseParticleIndex(self.pcf)
    end
end

modifier_mordred_q_throw.IsHidden = function(obj) return true end

---@class modifier_mordred_q_throw_hurt : CDOTA_Modifier_Lua
modifier_mordred_q_throw_hurt = class({})
modifier_mordred_q_throw_hurt.IsHidden = function(obj) return true end

---@class modifier_mordred_q_skewer : CDOTA_Modifier_Lua
modifier_mordred_q_skewer = class({})
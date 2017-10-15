atalanta_phoebus_catastrophe_barrage = class({})
LinkLuaModifier("modifier_phoebus_catastrophe_cooldown", "abilities/atalanta/modifier_phoebus_catastrophe_cooldown", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_barrage_slow", "abilities/atalanta/modifier_barrage_slow", LUA_MODIFIER_MOTION_NONE)

require("abilities/atalanta/phoebus_catastrophe")

atalanta_phoebus_catastrophe_wrapper(atalanta_phoebus_catastrophe_barrage)

function atalanta_phoebus_catastrophe_barrage:GetCastRange(location, target)
    if IsClient() then 
        return self:GetSpecialValueFor("range")
    else
        return 10000
    end
end

function atalanta_phoebus_catastrophe_barrage:GetAOERadius()
    return self:GetSpecialValueFor("aoe")
end

function atalanta_phoebus_catastrophe_barrage:CastFilterResultLocation(location)
    local caster = self:GetCaster()


    if IsServer() and not IsInSameRealm(caster:GetOrigin(), location) then
        return UF_FAIL_CUSTOM
    end
    
    if IsServer() and caster.BowOfHeavenAcquired then
        local fMaxDist = CustomNetTables:GetTableValue("sync","atalanta_bow_of_heaven").fMaxDist
        local fCastDistFromCenter = (caster.vRImpactLoc - location):Length2D()
        local fCastDistFromCaster = (caster:GetAbsOrigin() - location):Length2D()
        if fCastDistFromCenter > fMaxDist and fCastDistFromCaster > self:GetSpecialValueFor("range") then
            return UF_FAIL_CUSTOM
        end
    end

    if caster:GetArrowCount() < 2 then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function atalanta_phoebus_catastrophe_barrage:GetCustomCastErrorLocation(location)
    local caster = self:GetCaster()

    if IsServer() and not IsInSameRealm(caster:GetOrigin(), location) then
        return "#Cannot_Be_Cast_Now"
    end
    
    if IsServer() and caster.BowOfHeavenAcquired then
        local fMaxDist = CustomNetTables:GetTableValue("sync","atalanta_bow_of_heaven").fMaxDist
        local fCastDistFromCenter = (caster.vRImpactLoc - location):Length2D()
        local fCastDistFromCaster = (caster:GetAbsOrigin() - location):Length2D()
        if fCastDistFromCenter > fMaxDist and fCastDistFromCaster > self:GetSpecialValueFor("range") then
            return "Not within allowed cast zone..."
        end
    end
    
    if caster:GetArrowCount() < 2 then
        return "Not enough arrows..."
    end
end

function atalanta_phoebus_catastrophe_barrage:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local position = self:GetCursorPosition()
    local origin = caster:GetOrigin()
    local aoe = self:GetAOERadius()
    local arrows = math.floor(math.min(self:GetSpecialValueFor("arrows") + (caster:GetAgility()*self:GetSpecialValueFor("arrows_per_agility")), self:GetSpecialValueFor("arrows_cap")))
    local fixDuration = 3
    local interval = fixDuration / arrows
    
    caster:EndBowOfHeaven()
    Timers:RemoveTimer(caster.BowOfHeavenTimer)
    
    AddFOWViewer(caster:GetTeamNumber(), position, aoe, 3 + fixDuration, false)

    self:ShootAirArrows()

    local barrageMarker = ParticleManager:CreateParticleForTeam("particles/custom/atalanta/atalanta_barrage_marker.vpcf", PATTACH_CUSTOMORIGIN, nil, caster:GetTeamNumber())
    ParticleManager:SetParticleControl( barrageMarker, 0, position)
    --ParticleManager:SetParticleControl( caster.barrageMarker, 1, Vector(0,0,300))
    Timers:CreateTimer( 3, function()
        ParticleManager:DestroyParticle( barrageMarker, false )
        ParticleManager:ReleaseParticleIndex( barrageMarker )
    end)

    Timers:CreateTimer(self:GetSpecialValueFor("delay")-0.4, function()
        --local screenFx = ParticleManager:CreateParticle("particles/custom/screen_green_splash.vpcf", PATTACH_EYES_FOLLOW, caster)

        local midpoint = (origin + position) / 2
        local sourceLocation = midpoint + Vector(0, 0, 1000)

        local arrowAoE = self:GetSpecialValueFor("arrow_aoe")

        --[[if caster:HasModifier("modifier_tauropolos") then
            local tauropolos = caster:FindAbilityByName("atalanta_tauropolos")
            arrowAoE = arrowAoE + tauropolos:GetSpecialValueFor("bonus_aoe_per_agi") * caster:GetAgility()
        end]]
        if caster:HasModifier("modifier_arrows_of_the_big_dipper") then
          local fAgility = caster:GetAgility()
          local tAttributeTable = CustomNetTables:GetTableValue("sync","atalanta_big_dipper")
          arrowAoE = arrowAoE + (tAttributeTable.fAOEPerAGI * fAgility)
        end

        for i=1,arrows do
            Timers:CreateTimer(0.2 + interval * i, function()
                local point = RandomPointInCircle(position, aoe)
                EmitGlobalSound("Ability.Powershot.Alt")
                caster:ShootArrow({
                    Origin = sourceLocation,
                    Position = point,
                    AoE = arrowAoE,
                    Delay = 0.2,
                    DontUseArrow = true,
                    NoShock = true,
		    DontCountArrow = true,
                    Slow = 0.4
                })
            end)
        end
    end)

    --self:AfterSpell()
end

function atalanta_phoebus_catastrophe_barrage:GetAbilityTextureName()
    return "custom/atalanta_phoebus_catastrophe"
end
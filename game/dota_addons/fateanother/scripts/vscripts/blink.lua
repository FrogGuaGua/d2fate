function AbilityBlink(hCaster, vTarget, fMaxDistance, tParams)
    local tParams = tParams or {}
    local sOutEffect = tParams.sInEffect or "particles/items_fx/blink_dagger_start.vpcf"
    local sInEffect = tParams.sOutEffect or "particles/items_fx/blink_dagger_end.vpcf"
    local sOutSound = tParams.sOutSound or "Hero_Antimage.Blink_out"
    local sInSound = tParams.sInSound or "Hero_Antimage.Blink_in"
    
    local bDodge = true
    if tParams.bDodgeProjectiles ~= nil then bDodge = tParams.bDodgeProjectiles end
    
    local bNavCheck = true
    if tParams.bNavCheck ~= nil then bNavCheck = tParams.bNavCheck end

    local vPos = hCaster:GetAbsOrigin()
    local vDifference = vTarget - vPos
    
    local vDirection = vDifference:Normalized()
    local fDistance = vDifference:Length()
    if fDistance >= fMaxDistance then fDistance = fMaxDistance end
    local vBlinkPos = vPos + (vDirection * fDistance)
    
    if bNavCheck then
		local i = 0
        local iStep = 10
        local iSteps = math.ceil(fDistance / iStep)

        while GridNav:IsBlocked( vBlinkPos ) or not GridNav:IsTraversable( vBlinkPos )do
            i = i + 1
            vBlinkPos = vPos + (vDirection * (fDistance - i * iStep))
            if i >= iSteps then break end
        end
    end
    
    local pcBlinkOut = ParticleManager:CreateParticle(sOutEffect, PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(pcBlinkOut, 0, hCaster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(pcBlinkOut)
    hCaster:EmitSound(sOutSound)
    
    ProjectileManager:ProjectileDodge(hCaster)
    FindClearSpaceForUnit(hCaster, vBlinkPos, true)
    
    local pcBlinkIn = ParticleManager:CreateParticle(sInEffect, PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(pcBlinkIn, 0, hCaster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(pcBlinkIn)
    hCaster:EmitSound(sInSound)
end

function AbilityBlinkCastError(hCaster, vLocation)
    if IsClient() then require('libraries/util') end
    
    if IsLocked(hCaster) or hCaster:HasModifier("jump_pause_nosilence") or hCaster:HasModifier("modifier_story_for_someones_sake") then
        return UF_FAIL_CUSTOM
    end
    
    if hCaster:HasModifier("modifier_aestus_domus_aurea_lock") then
        local target = 0
        local targets = FindUnitsInRadius(hCaster:GetTeam(), hCaster:GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
        for i=1, #targets do
            target = targets[i]
            if target:GetName() == "npc_dota_hero_lina" then
                break
            end
        end
        if not IsFacingUnit(hCaster, target, 90) then
            return UF_FAIL_CUSTOM
        end
    end
    
    return UF_SUCCESS
end
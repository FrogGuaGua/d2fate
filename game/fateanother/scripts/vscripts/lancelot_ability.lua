function OnEternalStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    local ply = caster:GetPlayerOwner()
    if caster.IsEternalImproved then
        ability:EndCooldown()
        --SendErrorMessage(caster:GetPlayerOwnerID(), "#Attribute_Not_Earned")
        --return
        ability:StartCooldown(ability:GetSpecialValueFor("reduced_cd"))
    end

    if IsRevoked(caster) then
        keys.ability:EndCooldown()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Revoked_Error")
        return
    end

    caster:EmitSound("Hero_Abaddon.AphoticShield.Cast")
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_eternal_arms_mastership_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
    HardCleanse(caster)
    local dispel = ParticleManager:CreateParticle( "particles/units/heroes/hero_abaddon/abaddon_death_coil_explosion.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControl( dispel, 1, caster:GetAbsOrigin())
    -- Destroy particle after delay
    Timers:CreateTimer( 2.0, function()
        ParticleManager:DestroyParticle( dispel, false )
        ParticleManager:ReleaseParticleIndex( dispel )
    end)
end

function OnSMGStart(keys)
    LancelotCheckCombo(keys.caster, keys.ability)

       --[[print("dudududu")
    local caster = keys.caster
    local frontward = caster:GetForwardVector()
    local smg = 
    {
            Ability = keys.ability,
                EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
                iMoveSpeed = 2000,
                vSpawnOrigin = nil,
                fDistance = 500,
                fStartRadius = 100,
                fEndRadius = keys.EndRadius,
                Source = caster:GetAbsOrigin(),
                bHasFrontalCone = true,
                bReplaceExisting = false,
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
                iUnitTargetType = DOTA_UNIT_TARGET_ALL,
                fExpireTime = GameRules:GetGameTime() + 2.0,
            bDeleteOnHit = false,
            vVelocity = frontward * 2000
    }
    smg.vSpawnOrigin = caster:GetAbsOrigin() 
    ProjectileManager:CreateLinearProjectile(smg)]]
    
    
    -- Store inheritted variables
    local caster = keys.caster
    local ability = keys.ability
    local range = ability:GetLevelSpecialValueFor( "range", ability:GetLevel() - 1 )
    local start_radius = ability:GetLevelSpecialValueFor( "start_radius", ability:GetLevel() - 1 )
    local end_radius = ability:GetLevelSpecialValueFor( "end_radius", ability:GetLevel() - 1 )

    -- I'll just jump in here
    --if caster.ArsenalLevel then
        --local sAbil = caster:GetAbilityByIndex(2):GetAbilityName()
        --if sAbil == "lancelot_knight_of_honor" then
            --caster:SwapAbilities("lancelot_knight_of_honor_arsenal", sAbil, true, false)
        --elseif sAbil == "lancelot_knight_of_honor_arsenal" then
            --caster:SwapAbilities("lancelot_knight_of_honor", sAbil, true, false)
        --end
    --end
    
    -- Initialize local variables
    local current_point = caster:GetAbsOrigin()
    local currentForwardVec = forwardVec
    local current_radius = start_radius
    local current_distance = 0
    local forwardVec = ( keys.target_points[1] - current_point ):Normalized()
    local end_point = current_point + range * forwardVec
    local difference = end_radius - start_radius
    
    -- Loop creating particles
    while current_distance < range do
        -- Create particle
        local particleIndex = ParticleManager:CreateParticle( "particles/custom/lancelot/lancelot_smg.vpcf", PATTACH_CUSTOMORIGIN, caster )
        ParticleManager:SetParticleControl( particleIndex, 0, current_point )
        ParticleManager:SetParticleControl( particleIndex, 1, Vector( current_radius, 0, 0 ) )
        
        Timers:CreateTimer( 1.0, function()
                ParticleManager:DestroyParticle( particleIndex, false )
                ParticleManager:ReleaseParticleIndex( particleIndex )
                return nil
            end
        )
        
        -- Update current point
        current_point = current_point + current_radius * forwardVec
        current_distance = current_distance + current_radius
        current_radius = start_radius + current_distance / range * difference
    end
    
    -- Create particle
    local particleIndex = ParticleManager:CreateParticle( "particles/custom/lancelot/lancelot_smg.vpcf", PATTACH_CUSTOMORIGIN, caster )
    ParticleManager:SetParticleControl( particleIndex, 0, end_point )
    ParticleManager:SetParticleControl( particleIndex, 1, Vector( end_radius, 0, 0 ) )
        
    Timers:CreateTimer( 1.0, function()
            ParticleManager:DestroyParticle( particleIndex, true )
            ParticleManager:ReleaseParticleIndex( particleIndex )
            return nil
        end
    )
end

function OnSMGHit(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
    if target:HasModifier("modifier_c_rule_breaker") or target:HasModifier("modifier_l_rule_breaker") then
        DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    end
    --local armorShred = math.floor(target:GetPhysicalArmorBaseValue() * keys.ArmorShred/100)
    --target:SetPhysicalArmorBaseValue(target:GetPhysicalArmorBaseValue() - armorShred)
    ability:ApplyDataDrivenModifier(caster, target, "modifier_smg_armor_reduction", {keys.Duration})
    --Timers:CreateTimer( keys.Duration, function()
           -- target:SetPhysicalArmorBaseValue(target:GetPhysicalArmorBaseValue() + armorShred) 
            --return
    --end)
end

function OnDEStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    LancelotCheckCombo(keys.caster, keys.ability)
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_double_edge", {})
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_double_edge_ms", {})
    --ability:ApplyDataDrivenModifier(caster, caster, "modifier_double_edge_ms_tier2", {})
end

function OnDEAttack(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ply = caster:GetPlayerOwner()

    keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_double_edge_slow", {}) 
    target:SetMana(target:GetMana() - keys.ManaBurn)
end

function OnKnightStart(keys)
        local caster = keys.caster
        local ply = caster:GetPlayerOwner()
        local ability = keys.ability
        caster.IsKnightOpen = true
        if caster:HasModifier("modifier_arondite") then
            return 
            SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Be_Cast_Now")
        end


        local a1 = caster:GetAbilityByIndex(0)
        local a2 = caster:GetAbilityByIndex(1)
        local a3 = caster:GetAbilityByIndex(2)
        local a4 = caster:GetAbilityByIndex(3)
        local a5 = caster:GetAbilityByIndex(4)
        local a6 = caster:GetAbilityByIndex(5)

        local NPLevel = 1
        if caster.KnightLevel ~= nil then NPLevel = NPLevel + caster.KnightLevel end

        
        caster:SwapAbilities("lancelot_close_spellbook", a5:GetName(), true,false)
        if ability:GetLevel() == 1 then

                caster:FindAbilityByName("lancelot_vortigern"):SetLevel(NPLevel) 
                caster:SwapAbilities("lancelot_vortigern", a1:GetName(), true, false)
                print("opening spellbook")
                caster:SwapAbilities("fate_empty1", a2:GetName(), true, false) 
                caster:SwapAbilities("fate_empty2", a3:GetName(), true, false) 
                caster:SwapAbilities("fate_empty3", a4:GetName(), true, false) 
                caster:SwapAbilities("fate_empty4", a6:GetName(), true, false) 
        elseif ability:GetLevel() == 2 then
                caster:FindAbilityByName("lancelot_vortigern"):SetLevel(NPLevel) 
                caster:FindAbilityByName("lancelot_gae_bolg"):SetLevel(NPLevel)

                caster:SwapAbilities("lancelot_vortigern", a1:GetName(), true, false) 
                caster:SwapAbilities("lancelot_gae_bolg", a2:GetName(), true, false) 
                caster:SwapAbilities("fate_empty2", a3:GetName(), true, false) 
                caster:SwapAbilities("fate_empty3", a4:GetName(), true, false) 
                caster:SwapAbilities("fate_empty4", a6:GetName(), true, false)                 
        elseif ability:GetLevel() == 3 then
                caster:FindAbilityByName("lancelot_vortigern"):SetLevel(NPLevel) 
                caster:FindAbilityByName("lancelot_gae_bolg"):SetLevel(NPLevel)
                caster:FindAbilityByName("lancelot_nine_lives"):SetLevel(NPLevel)

                caster:SwapAbilities("lancelot_vortigern", a1:GetName(), true, false) 
                caster:SwapAbilities("lancelot_gae_bolg", a2:GetName(), true, false) 
                caster:SwapAbilities("fate_empty3", a3:GetName(), true, false) 
                caster:SwapAbilities("lancelot_nine_lives", a4:GetName(), true, false) 
                caster:SwapAbilities("fate_empty4", a6:GetName(), true, false)               
        elseif ability:GetLevel() == 4 then
                caster:FindAbilityByName("lancelot_vortigern"):SetLevel(NPLevel) 
                caster:FindAbilityByName("lancelot_gae_bolg"):SetLevel(NPLevel)
                caster:FindAbilityByName("lancelot_nine_lives"):SetLevel(NPLevel)
                caster:FindAbilityByName("lancelot_rule_breaker"):SetLevel(NPLevel)

                caster:SwapAbilities("lancelot_vortigern", a1:GetName(), true, false) 
                caster:SwapAbilities("lancelot_gae_bolg", a2:GetName(), true, false) 
                caster:SwapAbilities("lancelot_rule_breaker", a3:GetName(), true, false) 
                caster:SwapAbilities("lancelot_nine_lives", a4:GetName(), true, false) 
                caster:SwapAbilities("fate_empty4", a6:GetName(), true, false)                    
        elseif ability:GetLevel() == 5 then
                caster:FindAbilityByName("lancelot_vortigern"):SetLevel(NPLevel) 
                caster:FindAbilityByName("lancelot_gae_bolg"):SetLevel(NPLevel)
                caster:FindAbilityByName("lancelot_nine_lives"):SetLevel(NPLevel)
                caster:FindAbilityByName("lancelot_rule_breaker"):SetLevel(NPLevel)
                caster:FindAbilityByName("lancelot_tsubame_gaeshi"):SetLevel(NPLevel)

                caster:SwapAbilities("lancelot_vortigern", a1:GetName(), true, false) 
                caster:SwapAbilities("lancelot_gae_bolg", a2:GetName(), true, false) 
                caster:SwapAbilities("lancelot_rule_breaker", a3:GetName(), true, false) 
                caster:SwapAbilities("lancelot_nine_lives", a4:GetName(), true, false) 
                caster:SwapAbilities("lancelot_tsubame_gaeshi", a6:GetName(), true, false) 
        end
end

function OnKnightClosed(keys)
        local caster = keys.caster
        caster.IsKnightOpen = false
        local a1 = caster:GetAbilityByIndex(0)
        local a2 = caster:GetAbilityByIndex(1)
        local a3 = caster:GetAbilityByIndex(2)
        local a4 = caster:GetAbilityByIndex(3)
        local a5 = caster:GetAbilityByIndex(4)
        local a6 = caster:GetAbilityByIndex(5)
        -- if knight attribute is not taken, caster.KnightLevel~=nil is false and therefore kills off queueing a 2nd skill. 
        caster:SwapAbilities(a1:GetName(), "lancelot_smg_barrage", false ,true) 
        caster:SwapAbilities(a2:GetName(), "lancelot_double_edge", false, true) 
        caster:SwapAbilities(a3:GetName(), "lancelot_knight_of_honor", false, true)
        if caster.nukeAvail == true then 
            caster:SwapAbilities(a4:GetName(), "lancelot_nuke", false, true) 
        elseif caster:HasAbility("lancelot_blessing_of_fairy") then 
            caster:SwapAbilities(a4:GetName(), "lancelot_blessing_of_fairy", false, true) 
        else 
            caster:SwapAbilities(a4:GetName(), "rubick_empty1", false, true) 
        end
        caster:SwapAbilities(a5:GetName(), "lancelot_arms_mastership", false, true) 
        caster:SwapAbilities(a6:GetName(), "lancelot_arondite", false, true )       
end

function KnightInitialize(keys)
    local caster = keys.caster
    local ability = keys.ability
    local abilityLevel = ability:GetLevel()
    local other = caster:FindAbilityByName("lancelot_knight_of_honor_arsenal")

    if other then
        if abilityLevel ~= other:GetLevel() then
            other:SetLevel(ability:GetLevel())
        end
    end

    local abilities = {
        "lancelot_vortigern",
        "lancelot_gae_bolg",
        "lancelot_nine_lives",
        "lancelot_rule_breaker",
        "lancelot_tsubame_gaeshi"
    }

    for i = 1, abilityLevel do
        if not caster:HasAbility(abilities[i]) then
            caster:AddAbility(abilities[i])
            if i > 1 then caster:RemoveAbility("fate_empty"..tostring(i - 1)) end
        end
    end
        --[[if caster.KnightInitialized ~= true then
                print("knight initialized")
                caster:RemoveAbility("lancelot_vortigern") 
                caster:RemoveAbility("lancelot_gae_bolg") 
                caster:RemoveAbility("lancelot_nine_lives") 
                caster:RemoveAbility("lancelot_rule_breaker") 
                caster:RemoveAbility("lancelot_tsubame_gaeshi") 
                caster.KnightInitialized = true
        end

        if ability:GetLevel() == 1 then
                --print("ability lvl 1")
                caster:AddAbility("lancelot_vortigern")
                if caster.ArsenalAcquired then caster:AddAbility("lancelot_caliburn") end
                caster:AddAbility("fate_empty1"):SetHidden(true)
                caster:AddAbility("fate_empty2")
                caster:AddAbility("fate_empty3")
                caster:AddAbility("fate_empty4")
        elseif ability:GetLevel() == 2 then
                caster:RemoveAbility("fate_empty1")
                --caster:AddAbility("lancelot_vortigern")
                caster:AddAbility("lancelot_gae_bolg")
        elseif ability:GetLevel() == 3 then
                caster:RemoveAbility("fate_empty2")
                --caster:AddAbility("lancelot_vortigern")
               -- caster:AddAbility("lancelot_gae_bolg")
                caster:AddAbility("lancelot_nine_lives")
        elseif ability:GetLevel() == 4 then
                caster:RemoveAbility("fate_empty3") 
                --caster:AddAbility("lancelot_vortigern")
                --caster:AddAbility("lancelot_gae_bolg")
                --caster:AddAbility("lancelot_nine_lives")
                caster:AddAbility("lancelot_rule_breaker")
        elseif ability:GetLevel() == 5 then
                caster:RemoveAbility("fate_empty4")
                --caster:AddAbility("lancelot_vortigern")
                --caster:AddAbility("lancelot_gae_bolg")
                --caster:AddAbility("lancelot_nine_lives")
                --caster:AddAbility("lancelot_rule_breaker")
                caster:AddAbility("lancelot_tsubame_gaeshi")
        end--]]
end

function OnKnightUsed(keys)
        local caster = keys.caster
        if caster:GetName() ~= "npc_dota_hero_sven" then return end
        local ply = caster:GetPlayerOwner()
        local ability = keys.ability

        if not caster.KnightLevel and not caster.ArsenalLevel then
                OnKnightClosed(keys)
                caster:FindAbilityByName("lancelot_knight_of_honor"):StartCooldown(ability:GetCooldown(ability:GetLevel()))
        end
end

function ArsenalReturnMana(caster)
    if caster:GetName() == "npc_dota_hero_sven" and caster.ArsenalLevel == 2 then
        caster:GiveMana(caster:FindAbilityByName("lancelot_knight_of_honor_arsenal"):GetSpecialValueFor("mana_return"))
    end
end

function OnAronditeStart(keys)
    --[[if keys.caster.IsKnightOpen then 
        keys.ability:EndCooldown() 
        keys.caster:GiveMana(800)
        FireGameEvent( 'custom_error_show', { player_ID = keys.caster:GetPlayerOwnerID(), _error = "Cannot Be Used" } )
        return 
    end]]
    local caster = keys.caster
    local ability = keys.ability
    local ply = caster:GetPlayerOwner()
    local groundcrack = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    local warp = ParticleManager:CreateParticle("particles/custom/lancelot/lancelot_arondite_aoe_warp.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(warp,0, caster:GetAbsOrigin())

    -- Destroy particle after delay
    Timers:CreateTimer( 2.0, function()
        ParticleManager:DestroyParticle( groundcrack, false )
        ParticleManager:ReleaseParticleIndex( groundcrack )
        FxDestroyer(warp,false)
    end)
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_arondite", {})

    --Fix for Arondight-KoH abuse, UPDATE: seeing as how SwapAbilities(,,,false) appears to effectively kills off abuse, below fix may no longer be necessary.
    levelKoH = caster:FindAbilityByName("lancelot_knight_of_honor"):GetLevel()
    listOfSkills={"lancelot_vortigern","lancelot_gae_bolg","lancelot_nine_lives","lancelot_rule_breaker","lancelot_tsubame_gaeshi"}
    for i = 1,levelKoH do
        caster:FindAbilityByName(listOfSkills[i]):StartCooldown(10)
        --print(caster:FindAbilityByName(listOfSkills[i]).IsResetable)
        caster:FindAbilityByName(listOfSkills[i]).IsResetable = false
        Timers:CreateTimer(10.0, function()
            caster:FindAbilityByName(listOfSkills[i]).IsResetable = true
        end)
    end

    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
    for k,v in pairs(targets) do
            DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
    end
    --[[if caster.IsTAAcquired then
        keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_arondite_crit", {}) 
    end]]
end

function OnAronditeAttackLanded(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    if caster.IsEFAcquired and caster:GetMana() > 30 then
        caster:SetMana(caster:GetMana() - 30)
        local flame = 
        {
                Ability = ability,
                EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
                iMoveSpeed = 1000,
                vSpawnOrigin = caster:GetAbsOrigin(),
                fDistance = 300,
                fStartRadius = 100,
                fEndRadius = 200,
                Source = caster,
                bHasFrontalCone = true,
                bReplaceExisting = false,
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
                iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                fExpireTime = GameRules:GetGameTime() + 0.5,
                bDeleteOnHit = false,
                vVelocity = caster:GetForwardVector() * 1000
        }
        ProjectileManager:CreateLinearProjectile(flame)
        caster:EmitSound("Hero_Phoenix.FireSpirits.Launch")
    end
end

function OnEternalFlameHit(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    DoDamage(caster, target, 100, DAMAGE_TYPE_MAGICAL, 0, ability, false)

end

function OnAronditeCrit(keys)
    local caster = keys.caster
    local ability = keys.ability
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_arondite_crit_hit", {})
end

function OnFairyDmgTaken(keys)
    local caster = keys.caster
    if caster:GetHealth() < 500 and caster:IsAlive() and caster.IsFairyReady then 
        caster:EmitSound("DOTA_Item.BlackKingBar.Activate")
        keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_fairy_magic_immunity", {})
        keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_blessing_of_fairy_cooldown", {duration = keys.ability:GetCooldown(keys.ability:GetLevel())})
        caster.IsFairyReady = false
        Timers:CreateTimer(keys.ability:GetCooldown(keys.ability:GetLevel()), function()
            caster.IsFairyReady = true
        end)
    end
end

function OnNukeStart(keys)
    local caster = keys.caster
    local ability = keys.ability
    local targetPoint = keys.target_points[1]
    if not IsInSameRealm(caster:GetAbsOrigin(), targetPoint) then 
        caster:SetMana(caster:GetMana()+keys.ability:GetManaCost(keys.ability:GetLevel()-1)) 
        keys.ability:EndCooldown()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Invalid_Location")
        return
    end

    EmitGlobalSound("Lancelot.Nuke_Alert") 

    -- Set master's combo cooldown
    local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
    masterCombo:EndCooldown()
    masterCombo:StartCooldown(keys.ability:GetCooldown(1))
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_nuke_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

    local nukemsg = {
        message = "Engaging Enemy, HQ.",
        duration = 2.0
    }
    FireGameEvent("show_center_message",nukemsg)

    local f16 = CreateUnitByName("f16_dummy", Vector(0, 0, 0), true, nil, nil, caster:GetTeamNumber())
    f16:SetOwner(caster)
    local visiondummy = CreateUnitByName("sight_dummy_unit", targetPoint, false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
    visiondummy:SetDayTimeVisionRange(1500)
    visiondummy:SetNightTimeVisionRange(1500)
    visiondummy:AddNewModifier(caster, nil, "modifier_kill", {duration = 8})

    local unseen = visiondummy:FindAbilityByName("dummy_unit_passive")
    unseen:SetLevel(1)
    local nukeMarker = ParticleManager:CreateParticle( "particles/custom/lancelot/lancelot_nuke_calldown_marker_c.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl( nukeMarker, 0, targetPoint)
    ParticleManager:SetParticleControl( nukeMarker, 1, Vector(300, 300, 300))
    -- Destroy particle after delay
    Timers:CreateTimer( 3.0, function()
        ParticleManager:DestroyParticle( nukeMarker, false )
        ParticleManager:ReleaseParticleIndex( nukeMarker )
    end)

    -- Create F16 nunit
    Timers:CreateTimer(1.97, function()
        EmitGlobalSound("Lancelot.Nuke_Beep")
        EmitGlobalSound("Lancelot.Helicoptor")
        -- Set up unit
        LevelAllAbility(f16)
        FindClearSpaceForUnit(f16, f16:GetAbsOrigin(), true)
        f16:SetAbsOrigin(targetPoint)
        Timers:CreateTimer(0.033, function()
            f16:EmitSound("Hero_Gyrocopter.Rocket_Barrage")
        end)
    end)
    
    
    -- Move jet around
    local flyCount = 0
    local t = 0
    Timers:CreateTimer(2.0, function()
        if flyCount == 121 then f16:ForceKill(true) return end
        t = t+0.12
        SpinInCircle(f16, targetPoint, t, 650)
        flyCount = flyCount + 1
        return 0.033
    end)

    local barrageCount = 0
    Timers:CreateTimer(2.0, function()
        if flyCount == 121 then f16:ForceKill(true) return end
        local barrageVec1 = RandomVector(RandomInt(100, 800))
        local targets1 = FindUnitsInRadius(caster:GetTeam(), targetPoint + barrageVec1, nil, 200, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for k,v in pairs(targets1) do
            DoDamage(caster, v, 300, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
            if not v:IsMagicImmune() then v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.75}) end
        end
        -- particle
        if caster.AltPart.combo == 0 then
            local barrageImpact1 = ParticleManager:CreateParticle( "particles/custom/lancelot/lancelot_nuke_impact_circle.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( barrageImpact1, 0, targetPoint+barrageVec1)
            ParticleManager:SetParticleControl( barrageImpact1, 1, Vector(300, 300, 300))
            Timers:CreateTimer( 2.0, function()
                ParticleManager:DestroyParticle( barrageImpact1, false )
                ParticleManager:ReleaseParticleIndex( barrageImpact1 )
            end)
        else
            local barrageImpact1 = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_impact_circle.vpcf", PATTACH_CUSTOMORIGIN, nil )
            ParticleManager:SetParticleControl( barrageImpact1, 0, targetPoint+barrageVec1)
            ParticleManager:SetParticleControl( barrageImpact1, 1, Vector(300, 300, 300))
            Timers:CreateTimer( 2.0, function()
                ParticleManager:DestroyParticle( barrageImpact1, false )
                ParticleManager:ReleaseParticleIndex( barrageImpact1 )
            end)
        end

        local barrageImpact2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_light_strike_array_impact_sparks.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( barrageImpact2, 0, targetPoint+barrageVec1)
        visiondummy:EmitSound("Hero_Gyrocopter.Rocket_Barrage.Launch")
        -- Destroy particle after delay
        Timers:CreateTimer( 2.0, function()
            ParticleManager:DestroyParticle( barrageImpact2, false )
            ParticleManager:ReleaseParticleIndex( barrageImpact2 )
        end)
    
        barrageCount = barrageCount + 1
        return 0.033
    end)

    Timers:CreateTimer(4.5, function()
        EmitGlobalSound("Lancelot.TacticalNuke") 
    end)

    Timers:CreateTimer(7.0, function()
        EmitGlobalSound("Lancelot.Nuke_Impact")
        local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, 1500, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for k,v in pairs(targets) do
            DoDamage(caster, v, 2000, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
            if not v:IsMagicImmune() then v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 1.0}) end
        end
        -- particle
        local impactFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion_second.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( impactFxIndex, 0, targetPoint)
        ParticleManager:SetParticleControl( impactFxIndex, 1, Vector(2500, 2500, 1500))
        ParticleManager:SetParticleControl( impactFxIndex, 2, Vector(2500, 2500, 2500))
        ParticleManager:SetParticleControl( impactFxIndex, 3, targetPoint)
        ParticleManager:SetParticleControl( impactFxIndex, 4, Vector(2500, 2500, 2500))
        ParticleManager:SetParticleControl( impactFxIndex, 5, Vector(2500, 2500, 2500))

        local mushroom = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_light_strike_array_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil )
        ParticleManager:SetParticleControl( mushroom, 0, targetPoint)

        -- Destroy particle after delay
        Timers:CreateTimer( 2.0, function()
            ParticleManager:DestroyParticle( impactFxIndex, false )
            ParticleManager:ReleaseParticleIndex( impactFxIndex )
            ParticleManager:DestroyParticle( mushroom, false )
            ParticleManager:ReleaseParticleIndex( mushroom )
        end)
    end)
end

lastPos = Vector(0,0,0)
function SpinInCircle(unit, center, t, multiplier)
    local x = math.cos(t) * multiplier
    local y = math.sin(t) * multiplier
    lastPos = unit:GetAbsOrigin()
    unit:SetAbsOrigin(Vector(center.x + x, center.y + y, 750))
    local diff = (unit:GetAbsOrigin() - lastPos):Normalized() 
    unit:SetForwardVector(diff) 


end

function OnEternalImproved(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsEternalImproved = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnEAMDmgTaken(keys)
    local caster= keys.caster
    local dmg = keys.DamageTaken
    if caster.IsEternalImproved then
        heal=dmg * 0.07
    else
        heal=dmg * 0.03
    end
    caster:ApplyHeal(heal, caster)
end

function OnBlessingAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero:AddAbility("lancelot_blessing_of_fairy") 
    hero:FindAbilityByName("lancelot_blessing_of_fairy"):SetLevel(1) 
    hero:SwapAbilities("rubick_empty1", "lancelot_blessing_of_fairy", false, true) 
    hero:RemoveAbility("rubick_empty1") 
    hero.IsFairyReady = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnKnightImproved(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    if hero.KnightLevel == nil then
            local arsenal = hero.MasterUnit2:FindAbilityByName("lancelot_attribute_improve_koh_arsenal")
            if arsenal then arsenal:StartCooldown(9999) end
            hero.KnightLevel = 1
            keys.ability:EndCooldown()
    else
            hero.KnightLevel = 2
    end 
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnEFAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsEFAcquired = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end
function OnTAAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsTAAcquired = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function LancelotCheckCombo(caster, ability)
    local abil = caster:FindAbilityByName("lancelot_arondite")
    local statreq = 19.1
    if caster:HasModifier("modifier_arondite") then
        statreq = statreq + abil:GetLevelSpecialValueFor("bonus_allstat", abil:GetLevel()-1)
    end

    if caster:GetStrength() >= statreq and caster:GetAgility() >= statreq and caster:GetIntellect() >= statreq then
        if ability == caster:FindAbilityByName("lancelot_double_edge") then
            WUsed = true
            WTime = GameRules:GetGameTime()
            Timers:CreateTimer({
                endTime = 3,
                callback = function()
                WUsed = false
            end
            })
        elseif ability == caster:FindAbilityByName("lancelot_smg_barrage") and caster:FindAbilityByName("lancelot_nuke"):IsCooldownReady()  then
            if WUsed == true then 
                local abilname = "rubick_empty1"
                if caster:FindAbilityByName("lancelot_blessing_of_fairy") then abilname = "lancelot_blessing_of_fairy" end

                caster:SwapAbilities("lancelot_nuke", abilname, true, false)
                caster.nukeAvail = true
                local newTime =  GameRules:GetGameTime()
                Timers:CreateTimer({
                    endTime = 3,
                    callback = function()
                    if caster:FindAbilityByName("lancelot_blessing_of_fairy") then abilname = "lancelot_blessing_of_fairy" end
                    caster:SwapAbilities("lancelot_nuke", abilname, false, true) 
                    WUsed = false
                    caster.nukeAvail = false
                end
                })
            end
        end
    end
end
function OnCommandAttack(keys)
        local caster = keys.caster
        local hero = caster:GetPlayerOwner():GetAssignedHero()
        local targetPoint = keys.target_points[1]
        caster:EmitSound("Hero_LegionCommander.PressTheAttack")
        if caster:HasModifier("modifier_annihilate_caster") then
            keys.ability:EndCooldown()
            keys.ability:StartCooldown(1.0)
        end
        
        --local marbleCenter = 0
        --local aotkCenter = Vector(500, -4800, 208)
        --local ubwCenter = Vector(5600, -4398, 200)
        --if hero.IsAOTKDominant then marbleCenter = aotkCenter else marbleCenter = ubwCenter end
        local fx = ParticleManager:CreateParticle("particles/custom/iskandar/iskandar_rd.vpcf", PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControl(fx, 0, targetPoint)
        Timers:CreateTimer( 2.0, function()
		  ParticleManager:DestroyParticle( fx, false )
		  ParticleManager:ReleaseParticleIndex( fx )
	    end)
    
        for i=1, #hero.AOTKSoldiers do
            if IsValidEntity(hero.AOTKSoldiers[i]) then
                if hero.AOTKSoldiers[i]:IsAlive() then
                    keys.ability:ApplyDataDrivenModifier(caster,hero.AOTKSoldiers[i], "modifier_battle_horn_movespeed_buff", {})
                    ExecuteOrderFromTable({
                        UnitIndex = hero.AOTKSoldiers[i]:entindex(),
                        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                        Position = targetPoint
                    })
                end
            end
        end
        local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, 300
                , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        for k,v in pairs(targets) do
            keys.ability:ApplyDataDrivenModifier(caster,v,"modifier_battle_horn_armor_reduction", {})		
        end
end


function OnCommandSalvo(keys)
    local hero = keys.caster
    local target = keys.target
    --if hero.IsAOTKDominant then marbleCenter = aotkCenter else marbleCenter = ubwCenter end
    local caster = keys.caster
    if caster:HasModifier("modifier_annihilate_caster") then
        keys.ability:EndCooldown()
        keys.ability:StartCooldown(1.0)
    end
    local fx = ParticleManager:CreateParticle("particles/custom/iskandar/iskandar_rr.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
    caster:EmitSound("Hero_LegionCommander.Overwhelming.Creep")
    ParticleManager:SetParticleControl(fx, 0, target:GetAbsOrigin())
    Timers:CreateTimer( 2.0, function()
      ParticleManager:DestroyParticle( fx, false )
      ParticleManager:ReleaseParticleIndex( fx )
    end)

    for i=1, #hero.AOTKSoldiers do
        if IsValidEntity(hero.AOTKSoldiers[i]) then
            if hero.AOTKSoldiers[i]:IsAlive() then
                if hero.AOTKSoldiers[i]:GetName() == "iskander_archer" then
                    keys.ability:ApplyDataDrivenModifier(caster,hero.AOTKSoldiers[i],"modifier_aotk_salvo", {})		
                    ExecuteOrderFromTable({
                        UnitIndex = hero.AOTKSoldiers[i]:entindex(),
                        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                        TargetIndex = target:entindex(),
                    })
                end
            end
        end
    end
end


function OnCommandSuppress(keys)
    local caster= keys.caster
    local targetPoint = keys.target_points[1]
    caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast")
    local fx = ParticleManager:CreateParticle("particles/custom/iskandar/iskandar_rw.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(fx, 0, targetPoint)
    Timers:CreateTimer( 2.0, function()
      ParticleManager:DestroyParticle( fx, false )
      ParticleManager:ReleaseParticleIndex( fx )
    end)
    local flag = true
    for i = 1,#caster.AOTKSoldiers do
        if caster.AOTKSoldiers[i]:GetModelName() == "models/iskander/waver.vmdl" then
            flag = false
        end
    end
    if flag then
	    local waver = CreateUnitByName("iskander_waver", targetPoint+Vector(400, 0), true, nil, nil, caster:GetTeamNumber())
	    waver:SetControllableByPlayer(caster:GetPlayerID(), true)
	    waver:SetOwner(caster)
	    table.insert(caster.AOTKSoldiers, waver)
        caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
    end
	for i=0,5 do
		local soldier = CreateUnitByName("iskander_mage", targetPoint + Vector(200, -200 + i*100), true, nil, nil, caster:GetTeamNumber())
		--soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
    end
    local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, 450
    , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
    for k,v in pairs(targets) do
        keys.ability:ApplyDataDrivenModifier(caster,v,"modifier_aotk_suppress_slow", {})
        if caster.IsBeyondTimeAcquired then
            v:AddNewModifier(caster, nil, "modifier_silence", {duration=keys.duration})
        end	
    end
end

function OnCommandReinforce(keys)
    local caster= keys.caster
    local targetPoint = keys.target_points[1]
    if caster:HasModifier("modifier_annihilate_caster") then
        keys.ability:EndCooldown()
        keys.ability:StartCooldown(3.0)
    end
    caster:EmitSound("Hero_Silencer.Curse.Cast")
    local fx = ParticleManager:CreateParticle("particles/custom/iskandar/iskandar_re.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(fx, 0, targetPoint)
    Timers:CreateTimer( 2.0, function()
      ParticleManager:DestroyParticle( fx, false )
      ParticleManager:ReleaseParticleIndex( fx )
    end)
    for i=0,keys.number do
        if i % 2 == 0 then
            local soldier = CreateUnitByName("iskander_archer", targetPoint + Vector(200, -200 + i*100), true, nil, nil, caster:GetTeamNumber())
            soldier:SetOwner(caster)
            table.insert(caster.AOTKSoldiers, soldier)
            caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
        else
            local soldier = CreateUnitByName("iskander_infantry", targetPoint + Vector(0, -200 + i*100), true, nil, nil, caster:GetTeamNumber())
            soldier:SetOwner(caster)
            table.insert(caster.AOTKSoldiers, soldier)
            caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
        end
		--soldier:AddNewModifier(caster, nil, "modifier_phased", {})
	end
end


aotkCenter = Vector(500, -4800, 208)
ubwCenter = Vector(5600, -4398, 200)
function OnCommandAssault(keys)
    local caster= keys.caster
    local targetPoint = keys.target_points[1]
    local center = 0
    if caster.IsAOTKDominant then
        center = aotkCenter 
    else
        center = ubwCenter
    end
    caster:EmitSound("Hero_Centaur.Stampede.Cast")
    local rider = {}
    local flag = true
    for i = 1,#caster.AOTKSoldiers do
        if caster.AOTKSoldiers[i]:GetModelName() == "models/heroes/chaos_knight/chaos_knight.vmdl" then
            flag = false
        end
    end
    if flag then
        local hepha = CreateUnitByName("iskander_hephaestion", center + Vector(900, 600 - RandomInt(0,1200), 0), true, nil, nil, caster:GetTeamNumber())
        hepha:SetControllableByPlayer(caster:GetPlayerID(), true)
        hepha:SetOwner(caster)
        table.insert(caster.AOTKSoldiers, hepha)
        table.insert(rider,hepha)
        caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
    end
    for i=0,4 do
        local soldier = CreateUnitByName("iskander_cavalry", center + Vector(600 + RandomInt(0,600), 600 - RandomInt(0,1200), 0), true, nil, nil, caster:GetTeamNumber())
        soldier:SetOwner(caster)
        table.insert(caster.AOTKSoldiers, soldier)
        table.insert(rider,soldier)
        caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
    end


    --ProjectileManager:CreateLinearProjectile(charge)
    for i=1, #rider do
        local p=rider[i]:GetAbsOrigin()
        local charge =
        {
            Ability = keys.ability,
            EffectName = "",
            iMoveSpeed = 1800,
            vSpawnOrigin = p,
            fDistance = (targetPoint - rider[i]:GetAbsOrigin()):Length2D(),
            Source = rider[i],
            fStartRadius = 200,
            fEndRadius = 200,
            bHasFrontialCone = true,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 2,
            bDeleteOnHit = true,
            vVelocity = (targetPoint - rider[i]:GetAbsOrigin()):Normalized() * 1800
        }
        local projectile = ProjectileManager:CreateLinearProjectile(charge)

        local phyunit = Physics:Unit(rider[i])
        rider[i]:PreventDI()
		rider[i]:SetPhysicsFriction(0)
		rider[i]:SetPhysicsVelocity((targetPoint - rider[i]:GetAbsOrigin()):Normalized() * 1800)
		rider[i]:SetNavCollisionType(PHYSICS_NAV_NOTHING)
        rider[i]:FollowNavMesh(false)
        rider[i]:OnPhysicsFrame(function(unit)
			local diff = targetPoint - rider[i]:GetAbsOrigin()
			local dir = diff:Normalized()
			local particle = ParticleManager:CreateParticle("particles/econ/items/tinker/boots_of_travel/teleport_end_bots_dust.vpcf", PATTACH_ABSORIGIN, rider[i])
			ParticleManager:SetParticleControl(particle, 0, rider[i]:GetAbsOrigin())
			Timers:CreateTimer( 2.0, function()
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
			end)
			unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * dir)
	   		unit:SetForwardVector(dir) 
			if diff:Length() < 50 then
				unit:PreventDI(false)
				unit:SetPhysicsVelocity(Vector(0,0,0))
                unit:OnPhysicsFrame(nil)
                FindClearSpaceForUnit(unit, targetPoint, true)	
			end
        end)
        Timers:CreateTimer(1.5,function()
            rider[i]:PreventDI(false)
            rider[i]:SetPhysicsVelocity(Vector(0,0,0))
            rider[i]:OnPhysicsFrame(nil)
            FindClearSpaceForUnit(rider[i], targetPoint, true)	
        end)
    end

end


function OnCommandAssaultHit(keys)
    local target = keys.target
    local caster =keys.caster
    local pos = target:GetAbsOrigin()
    local cpos =caster:GetAbsOrigin()
    if caster.IsBeyondTimeAcquired then
        keys.damage = keys.damage + 20
    end	
    DoDamage(keys.caster, target,keys.damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
    giveUnitDataDrivenModifier(caster,target, "stunned", 0.5)
    local phyunit = Physics:Unit(target)
    target:SetBounceMultiplier(0)
    target:PreventDI(false)
    target:SetPhysicsVelocity(Vector(0,0,0))
    target:PreventDI()
    target:SetPhysicsFriction(0)
    target:SetPhysicsVelocity((pos - cpos):Normalized() * 300)
    target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    target:OnPhysicsFrame(function(unit) 
		local unitOrigin = unit:GetAbsOrigin()
		local diff = unitOrigin - pos
		if diff:Length() > 150 then
			unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			unit:OnPhysicsFrame(nil)
            FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
            local particle = ParticleManager:CreateParticle("particles/econ/items/tinker/boots_of_travel/teleport_end_bots_dust.vpcf", PATTACH_ABSORIGIN, unit)
			ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
			Timers:CreateTimer( 0.5, function()
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
			end)
		end
    end)
    target:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
        giveUnitDataDrivenModifier(caster, target, "stunned",1.0)
        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		DoDamage(caster, target, 100, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)	
    end)
    Timers:CreateTimer(2,function() 
        FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
    end)
end
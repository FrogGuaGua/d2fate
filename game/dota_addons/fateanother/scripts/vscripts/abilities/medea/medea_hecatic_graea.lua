medea_hecatic_graea = class({})

LinkLuaModifier("modifier_hecatic_graea_anim", "abilities/medea/modifiers/modifier_hecatic_graea_anim", LUA_MODIFIER_MOTION_NONE)

function medea_hecatic_graea:CastFilterResultLocation(vLocation)
	if IsServer() then
		if GridNav:IsBlocked(vLocation) or not GridNav:IsTraversable(vLocation) or not IsInSameRealm(self:GetCaster():GetAbsOrigin(), vLocation) then
			return UF_FAIL_CUSTOM
		end

		return UF_SUCCESS	
	end		
end

function medea_hecatic_graea:GetCustomCastErrorLocation(vLocation)
	return "#Cannot_Travel"
end

function medea_hecatic_graea:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local targetPoint = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	local boltradius = self:GetSpecialValueFor("radius_bolt")
	local boltvector = nil
	local boltCount  = 0
	local maxBolt = self:GetSpecialValueFor("bolt_amount")
	local travelTime = 0.7
	local ascendTime = travelTime + 2.0
	local descendTime = ascendTime + 0.75
	local diff = (targetPoint - caster:GetAbsOrigin()) * 1 / travelTime
	local damage = self:GetSpecialValueFor("damage")

	if caster.IsHGImproved then
		maxBolt = maxBolt + 3
		damage = damage + caster:GetIntellect() * 1.5
	end 

	local initTargets = 0

	if not IsInSameRealm(caster:GetOrigin(), targetPoint) then
		self:EndCooldown() 
		caster:GiveMana(800) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 

	caster:AddNewModifier(caster, ability, "modifier_hecatic_graea_anim", { Duration = 4 })

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", descendTime)
	Timers:CreateTimer(descendTime, function()
		giveUnitDataDrivenModifier(caster, caster, "jump_pause_postdelay", 0.15)
	end)
	local fly = Physics:Unit(caster)
	caster:PreventDI()
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(Vector(diff:Normalized().x * diff:Length2D(), diff:Normalized().y * diff:Length2D(), 1000))
	--allows caster to jump over walls
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)
	caster:SetAutoUnstuck(false)

	Timers:CreateTimer(travelTime, function()  
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
		--caster:SetAbsOrigin(caster:GetGroundPosition(caster:GetAbsOrigin(), caster)+Vector(0,0,1000))
	return end) 
	Timers:CreateTimer(ascendTime, function()  
		caster:SetPhysicsVelocity( Vector( 0, 0, -950) )
	return end) 

	Timers:CreateTimer(descendTime, function()
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
	return end)

	local isFirstLoop = false
	Timers:CreateTimer(0.7, function()
		-- For the first round of shots, find all servants within AoE and guarantee one ray hit
		if isFirstLoop == false then 
			isFirstLoop = true
			initTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(initTargets) do
				self:DropRay(caster, damage, boltradius, ability, v:GetAbsOrigin(), "particles/custom/caster/hecatic_graea/ray.vpcf")
			end
			maxBolt = maxBolt - #initTargets
		else
			if maxBolt <= boltCount then return end
		end

		local rayTarget = RandomPointInCircle(GetGroundPosition(caster:GetAbsOrigin(), caster), radius)
		while GridNav:IsBlocked(rayTarget) or not GridNav:IsTraversable(rayTarget) do
			rayTarget = RandomPointInCircle(GetGroundPosition(caster:GetAbsOrigin(), caster), radius)
		end
		self:DropRay(caster, damage, boltradius, ability, rayTarget, "particles/custom/caster/hecatic_graea/ray.vpcf")
	    boltCount = boltCount + 1
		return 0.1
    end
    )
	Timers:CreateTimer(1.0, function() EmitGlobalSound("Caster.Hecatic") EmitGlobalSound("Caster.Hecatic_Spread") caster:EmitSound("Misc.Crash") return end)
end

function medea_hecatic_graea:DropRay(caster, damage, radius, ability, targetPoint, particle)
	local casterLocation = caster:GetAbsOrigin()
	
	-- print(damage)
	-- Particle
	local dummy = CreateUnitByName("dummy_unit", targetPoint, false, caster, caster, caster:GetTeamNumber())
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

	local fxIndex = ParticleManager:CreateParticle(particle, PATTACH_POINT, dummy)
	ParticleManager:SetParticleControlEnt(fxIndex, 0, dummy, PATTACH_POINT, "attach_hitloc", dummy:GetAbsOrigin(), true)
	local portalLocation = casterLocation + (targetPoint - casterLocation):Normalized() * 300
	portalLocation.z = casterLocation.z
	ParticleManager:SetParticleControl(fxIndex, 4, portalLocation)

	local casterDirection = (portalLocation - targetPoint):Normalized()
	casterDirection.x = casterDirection.x * -1
	casterDirection.y = casterDirection.y * -1
	dummy:SetForwardVector(casterDirection)

	--DebugDrawCircle(targetPoint, Vector(255,0,0), 0.5, radius, true, 0.5)

	Timers:CreateTimer(2, function()
		dummy:RemoveSelf()
	end)
		
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
    	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    	v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
	end
end
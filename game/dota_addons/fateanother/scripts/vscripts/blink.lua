function AbilityBlink(hCaster, vTarget, fMaxDistance, tParams)
	local tParams = tParams or {}
	local sOutEffect = tParams.sInEffect or "particles/items_fx/blink_dagger_start.vpcf"
	local sInEffect = tParams.sOutEffect or "particles/items_fx/blink_dagger_end.vpcf"
	local sOutSound = tParams.sOutSound or "Hero_Antimage.Blink_out"
	local sInSound = tParams.sInSound or "Hero_Antimage.Blink_in"
	local bDodge = tParams.bDodgeProjectiles or true

	local vPos = hCaster:GetAbsOrigin()
	local vDifference = vTarget - vPos
	
	local vDirection = vDifference:Normalized()
	local fDistance = vDifference:Length()
	if fDistance >= fMaxDistance then fDistance = fMaxDistance end
	local vBlinkPos = vPos + (vDirection * fDistance)
	
	local i = 0
	local iStep = 10
	local iSteps = math.ceil(fDistance / iStep)
	
	while GridNav:IsBlocked( vBlinkPos ) or not GridNav:IsTraversable( vBlinkPos )do
		i = i + 1
		vBlinkPos = vPos + (vDirection * (fDistance - i * iStep))
		if i >= iSteps then break end
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
Wrappers = {}

function Wrappers.WrapUnit(hUnit)
	-- Heals
	function hUnit:ApplyHeal(fAmount, hSource, ...)
		local fHeal = fAmount
		local fMaxHealth = hUnit:GetMaxHealth()
		local fCurrentHealth = hUnit:GetHealth()
			
		if fCurrentHealth == fMaxHealth then
			fHeal = 0
		elseif fCurrentHealth + fAmount > fMaxHealth then
			fHeal = fMaxHealth - fCurrentHealth
		end
		
		local tModifiers = hUnit:FindAllModifiers()
		
		for k, v in pairs(tModifiers) do
			if v.OnHeal then
				v:OnHeal(fAmount, fHeal, hSource)
			end
			
			if v.DisableHeal then
				if v:DisableHeal() then return end
			end
		end
		
		hUnit:Heal(fAmount, hSource)
	end
	
	-- Execution
	function hUnit:Execute(hAbility, hKiller, tParams)
		local tParams = tParams or {}
		local bExecution = tParams.bExecution or false
		local tModifiers = hUnit:FindAllModifiers()
	
		for k, v in pairs(tModifiers) do
			if v.OnKill then
				v:OnKill(hAbility, hKiller)
			end
			
			if bExecution then
				if v.BlockExecute then
					if v:BlockExecute() then return end
				end
			end
		end
		
		hUnit:Kill(hAbility, hKiller)
	end
end
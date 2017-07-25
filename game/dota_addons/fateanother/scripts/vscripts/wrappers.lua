Wrappers = {}

function Wrappers.WrapHero(hHero)
	-- Heals
	function hHero:ApplyHeal(fAmount, hSource, ...)
		local fHeal = fAmount
		local fMaxHealth = hHero:GetMaxHealth()
		local fCurrentHealth = hHero:GetHealth()
			
		if fCurrentHealth == fMaxHealth then
			fHeal = 0
		elseif fCurrentHealth + fAmount > fMaxHealth then
			fHeal = fMaxHealth - fCurrentHealth
		end
		
		local tModifiers = hHero:FindAllModifiers()
		
		for k, v in pairs(tModifiers) do
			if v.OnHeal then v:OnHeal(fAmount, fHeal, hSource) end
		end
		
		hHero:Heal(fAmount, hSource)
	end
end
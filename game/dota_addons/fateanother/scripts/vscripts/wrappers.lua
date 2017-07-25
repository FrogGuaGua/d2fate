Wrappers = {}

function Wrappers.WrapHero(hHero)
	-- Heals
	function hHero:ApplyHeal(fAmount, hSource, ...)
	
		-- This could probably be made a general thing for all modifiers that calls "OnHeal", for now it's only needed for QGG
		if hHero:HasModifier("modifier_qgg_oracle") then
			local fHeal = 0
			local fMaxHealth = hHero:GetMaxHealth()
			local fCurrentHealth = hHero:GetHealth()
			
			if fCurrentHealth == fMaxHealth then
				fHeal = 0
			elseif fCurrentHealth + fAmount > fMaxHealth then
				fHeal = fMaxHealth - fCurrentHealth
			else
				fHeal = fAmount
			end
			
			local hModifier = hHero:FindModifierByName("modifier_qgg_oracle")
			hModifier:OnHeal(fHeal)
			return
		end
		
		hHero:Heal(fAmount, hSource)
	end
end
caster_5th_dimensional_jump = class({})

function caster_5th_dimensional_jump:OnSpellStart()
	local tParams = {
		bNavCheck = false,
	}
	AbilityBlink(self:GetCaster(), self:GetCursorPosition(), self:GetSpecialValueFor("distance"), tParams)
end

function caster_5th_dimensional_jump:CastFilterResultLocation( vLocation )
	if IsServer() then return AbilityBlinkCastError(self:GetCaster(), vLocation) end
end

function caster_5th_dimensional_jump:GetCustomCastErrorLocation( vLocation )
	return "#Cannot_Blink"
end
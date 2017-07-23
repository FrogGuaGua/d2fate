modifier_unit_voice = class({})

function modifier_unit_voice:IsHidden()
	return true
end

function modifier_unit_voice:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_unit_voice:IsPermanent()
	return true
end

function modifier_unit_voice:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_RESPAWN,
		MODIFIER_EVENT_ON_DEATH,
	}
	
	return funcs
end

function modifier_unit_voice:OnTakeDamage(args)
	local hUnit = args.unit
	if hUnit == self:GetParent() and hUnit.UnitVoice then
		hUnit.UnitVoice:OnHurt()
	end
end

function modifier_unit_voice:OnOrder(args)
	local hUnit = args.unit
	local eOrder = args.order_type
	local iIssuer = args.issuer_player_index
	local hAbility = args.ability
	
	if not hUnit == self:GetParent() or not hUnit.UnitVoice then return end
	
	if eOrder == 1 then
		hUnit.UnitVoice:OnMove(iIssuer)
	end
	
	if eOrder == 2 then
		hUnit.UnitVoice:OnMove(iIssuer)
	end
	
	if eOrder == 3 then
		hUnit.UnitVoice:OnAttack(iIssuer)
	end
	
	if eOrder == 4 then
		hUnit.UnitVoice:OnAttack(iIssuer)
	end
	
	if eOrder == 5 then
		if not hAbility:IsItem() then hUnit.UnitVoice:OnCast(iIssuer) end
	end
	
	if eOrder == 6 then
		if not hAbility:IsItem() then hUnit.UnitVoice:OnCast(iIssuer) end
	end
end

function modifier_unit_voice:OnRespawn(args)
	local hUnit = args.unit
	if hUnit == self:GetParent() and hUnit.UnitVoice then
		hUnit.UnitVoice:OnRespawn()
	end
end

function modifier_unit_voice:OnDeath(args)
	local hUnit = args.unit
	local hAttacker = args.attacker
	if hUnit == self:GetParent() and hUnit.UnitVoice then
		hUnit.UnitVoice:OnDeath(hAttacker)
	end
end
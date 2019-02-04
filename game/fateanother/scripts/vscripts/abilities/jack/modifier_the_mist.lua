modifier_the_mist = class({})


function modifier_the_mist:OnCreated(args)
	self.fSlow = args.fSlow
end

function modifier_the_mist:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        
	}
	return funcs
end

function modifier_the_mist:IsHidden()
    return false
end
  
function modifier_the_mist:IsDebuff()
    return true
end
  
function modifier_the_mist:RemoveOnDeath()
    return true
end






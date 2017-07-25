modifier_cursed_lance_bp = class({})

if not IsServer() then
	return
end

require("abilities/vlad/modifier_cursed_lance")

cl_wrapper(modifier_cursed_lance_bp)
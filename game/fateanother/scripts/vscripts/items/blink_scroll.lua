---@class item_blink_scroll : CDOTA_Item_Lua
item_blink_scroll = class({})

function item_blink_scroll:OnSpellStart()
    AbilityBlink(self:GetCaster(), self:GetCursorPosition(), self:GetSpecialValueFor("distance"))
end

function item_blink_scroll:IsResettable()
    return true
end

function item_blink_scroll:CastFilterResultLocation( vLocation )
    if IsServer() then return AbilityBlinkCastError(self:GetCaster(), vLocation) end
end

function item_blink_scroll:GetCustomCastErrorLocation( vLocation )
    return "#Cannot_Blink"
end

--if IsClient() then
    function item_blink_scroll:GetCastRange(vLocation, hTarget)
        return 1000
    end
--end
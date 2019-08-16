---@class item_blink_scroll : CDOTA_Item_Lua
item_blink_scroll_ai = class({})

function item_blink_scroll_ai:OnSpellStart()
    AbilityBlink(self:GetCaster(), self:GetCursorPosition(), self:GetSpecialValueFor("distance"))
end

function item_blink_scroll_ai:IsResettable()
    return true
end

function item_blink_scroll_ai:CastFilterResultLocation( vLocation )
    if IsServer() then return AbilityBlinkCastError(self:GetCaster(), vLocation) end
end

function item_blink_scroll_ai:GetCustomCastErrorLocation( vLocation )
    return "#Cannot_Blink"
end

function item_blink_scroll_ai:GetCastRange(vLocation, hTarget)
    return 1000
end

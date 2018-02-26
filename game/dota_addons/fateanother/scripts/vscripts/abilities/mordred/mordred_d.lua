---@class mordred_d : CDOTA_Ability_Lua
mordred_d = class({})

LinkLuaModifier("modifier_mordred_d", "abilities/mordred/modifier_mordred_d", LUA_MODIFIER_MOTION_NONE)

function mordred_d:GetIntrinsicModifierName()
    return "modifier_mordred_d"
end
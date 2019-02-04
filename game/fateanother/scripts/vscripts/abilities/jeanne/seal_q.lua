---@class jeanne_seal_q : CDOTA_Ability_Lua
jeanne_seal_q = class({})
LinkLuaModifier("modifier_jeanne_assertion_taunt", "abilities/jeanne/seal_q", LUA_MODIFIER_MOTION_NONE)

function jeanne_seal_q:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    local pcf
    if target:IsOpposingTeam(caster:GetTeam()) then
        local kv = {
            duration = self:GetSpecialValueFor("taunt_duration"),
            target = caster:GetEntityIndex()
        }
        target:AddNewModifier(caster, self, "modifier_jeanne_assertion_taunt", kv)
        pcf = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        EmitSoundOn("Hero_Chen.TestOfFaith.Target", target)
    else
        HardCleanse(target)
        pcf = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_holy_persuasion_sparks.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        EmitSoundOn("DOTA_Item.IronTalon.Activate", target)
    end
    ParticleManager:ReleaseParticleIndex(pcf)

    local spellbook = caster:FindAbilityByName("jeanne_seal_spellbook")
    if spellbook then spellbook:OnSealCast() end
end


---@class modifier_jeanne_assertion_taunt : CDOTA_Modifier_Lua
modifier_jeanne_assertion_taunt = class({})

function modifier_jeanne_assertion_taunt:GetHeroEffectName()
    return "particles/units/heroes/hero_axe/axe_beserkers_call_hero_effect.vpcf"
end

if IsServer() then
    function modifier_jeanne_assertion_taunt:OnCreated(args)
        self.order = {
            UnitIndex = self:GetParent():GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
            TargetIndex = args.target
        }
        self:StartIntervalThink(FrameTime())
    end

    function modifier_jeanne_assertion_taunt:OnIntervalThink()
        local parent = self:GetParent()
        ExecuteOrderFromTable(self.order)
    end
end
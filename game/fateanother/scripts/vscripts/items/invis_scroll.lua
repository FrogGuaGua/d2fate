---@class item_invis_scroll : CDOTA_Item_Lua
item_invis_scroll = {}

function item_invis_scroll:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    target:AddNewModifier(caster, self, "modifier_invis_scroll", { duration = self:GetSpecialValueFor("duration") })
    target:AddNewModifier(caster, self, "modifier_invis_scroll_cd", { duration = self:GetSpecialValueFor("cooldown") })
    target:EmitSound("Items.InvisScroll")
    self:SpendCharge()
end

function item_invis_scroll:CastFilterResultTarget(target)
    if target:HasModifier("modifier_invis_scroll_cd") or target:IsOpposingTeam(self:GetCaster():GetTeamNumber()) then return UF_FAIL_CUSTOM end
    return UF_SUCCESS
end

function item_invis_scroll:GetCustomCastErrorTarget(target)
    if target:IsOpposingTeam(self:GetCaster():GetTeamNumber()) then
        return "#dota_hud_error_cant_cast_on_enemy"
    end
    return "#error_invis_scroll"
end

LinkLuaModifier("modifier_invis_scroll", "items/invis_scroll", LUA_MODIFIER_MOTION_NONE)
---@class modifier_invis_scroll : CDOTA_Modifier_Lua
modifier_invis_scroll = {}

function modifier_invis_scroll:GetTexture()
    return "custom/invis_scroll"
end

if IsServer() then
    function modifier_invis_scroll:OnCreated(args)
        local pcf = ParticleManager:CreateParticle("particles/items3_fx/glimmer_cape_initial.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:ReleaseParticleIndex(pcf)
        self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("fade_delay"))
    end

    function modifier_invis_scroll:OnIntervalThink()
        local parent = self:GetParent()
        local mod = parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_invis_scroll_active", {})
        mod.modifier = self
        self:StartIntervalThink(-1)
    end

    function modifier_invis_scroll:OnDestroy()
        self:GetParent():RemoveModifierByName("modifier_invis_scroll_active")
    end
end

LinkLuaModifier("modifier_invis_scroll_active", "items/invis_scroll", LUA_MODIFIER_MOTION_NONE)
---@class modifier_invis_scroll_active : CDOTA_Modifier_Lua
modifier_invis_scroll_active = {}

function modifier_invis_scroll_active:CheckState()
    return { [MODIFIER_STATE_INVISIBLE] = true }
end

function modifier_invis_scroll_active:GetEffectName()
    return "particles/items3_fx/glimmer_cape_mainglow.vpcf"
end

function modifier_invis_scroll_active:GetTexture()
    return "custom/invis_scroll"
end

function modifier_invis_scroll_active:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_FINISHED,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }
end

function modifier_invis_scroll_active:GetModifierInvisibilityLevel()
    return 1.0
end

if IsServer() then
    function modifier_invis_scroll_active:OnAttackFinished(args)
        if args.attacker == self:GetParent() then
            self.modifier:StartIntervalThink(self:GetAbility():GetSpecialValueFor("fade_delay"))
            self:Destroy()
        end
    end

    function modifier_invis_scroll_active:OnAbilityExecuted(args)
        if args.unit == self:GetParent() then
            self.modifier:StartIntervalThink(self:GetAbility():GetSpecialValueFor("fade_delay"))
            self:Destroy()
        end
    end
end

LinkLuaModifier("modifier_invis_scroll_cd", "items/invis_scroll", LUA_MODIFIER_MOTION_NONE)
---@class modifier_invis_scroll_cd : CDOTA_Modifier_Lua
modifier_invis_scroll_cd = {}

function modifier_invis_scroll_cd:GetTexture()
    return "custom/invis_scroll"
end
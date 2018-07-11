---@class modifier_custom_mana : CDOTA_Modifier_Lua
---@field maxMana number
---@field mana number
modifier_custom_mana = class({})

if IsServer() then
    function modifier_custom_mana:OnCreated(args)
        local parent = self:GetParent()
        local key = tostring(parent:GetEntityIndex())
        self.tableKey = key.."_mana"
        self.regenKey = key.."_regen"
        self.maxMana = 100
        self.mana = 100
        self:UpdateMana()

        parent.GetMana = function(obj)
            return self.mana
        end

        parent.GetMaxMana = function(obj)
            return self.maxMana
        end

        parent.SetMana = function(obj, value)
            self.mana = value
        end

        parent.SpendMana = function(obj, value, ability)
            self:SpendMana(value)
        end

        parent.GiveMana = function(obj, value)
            self:GiveMana(value)
        end

        self:StartIntervalThink(FrameTime())
    end

    -- every extension of this modifier gives their own think implementation
    function modifier_custom_mana:OnIntervalThink()
        self:StartIntervalThink(-1)
    end

    function modifier_custom_mana:UpdateMana()
        CustomNetTables:SetTableValue("sync", self.tableKey, {mana = self.mana, maxMana = self.maxMana})
    end

    function modifier_custom_mana:SpendMana(value)
        self:ModifyMana(self.mana - value)
    end

    function modifier_custom_mana:GiveMana(value)
        self:ModifyMana(self.mana + value)
    end

    function modifier_custom_mana:ModifyMana(value)
        if value < 0 then
            self.mana = 0
        elseif value > self.maxMana then
            self.mana = self.maxMana
        else
            self.mana = value
        end
        self:UpdateMana()
    end

    --[[function modifier_custom_mana:OnManaSeal()
        self.mana = self.maxMana
    end]]

    function modifier_custom_mana:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ORDER,
            MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE
        }
    end

    function modifier_custom_mana:OnOrder(args)
        if args.unit ~= self:GetParent() then return end
        local order = args.order_type

        if order > 4 and order < 10 then
            if args.ability then
                self:SpendMana(args.ability:GetManaCost(-1))
            end
        end
    end

    function modifier_custom_mana:GetModifierTotalPercentageManaRegen()
        return 1000
    end

    function modifier_custom_mana:GetMana()
        return self.mana
    end

    function modifier_custom_mana:GetMaxMana()
        return self.maxMana
    end
end

function modifier_custom_mana:IsHidden()
    return true
end
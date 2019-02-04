---@class modifier_beam_thinker : CDOTA_Modifier_Lua
modifier_beam_thinker = class({})

if IsServer() then
    function modifier_beam_thinker:DeclareFunctions()
        return {MODIFIER_EVENT_ON_HERO_KILLED}
    end
    
    function modifier_beam_thinker:OnCreated(args)
        self:GetParent():SetForwardVector(self:GetCaster():GetForwardVector())
        self.direction = Vector(args.dir_x, args.dir_y, args.dir_z)
        self.speed = args.speed
        self.startRadius = args.start_radius
        self.endRadius = args.end_radius
        self.radius = args.start_radius or args.radius
        self.targetTeam = args.target_team or DOTA_UNIT_TARGET_TEAM_ENEMY
        self.executed = {}
        self:StartIntervalThink(FrameTime())
    end

    function modifier_beam_thinker:OnIntervalThink()
        local parent = self:GetParent()
        local caster = self:GetCaster()
        local nextPos = parent:GetAbsOrigin() + self.direction * self.speed * FrameTime()
        parent:SetAbsOrigin(GetGroundPosition(nextPos, parent))

        if self.startRadius and self.endRadius then
            self.t = self.t + (FrameTime() / self:GetDuration()) or 0
            self.radius = self.startRadius + (math.abs(self.startRadius - self.endRadius) * self.t)
        end

        local hits = FindUnitsInRadius(caster:GetTeam(), nextPos, nil, self.radius, self.targetTeam, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        if self:GetAbility() and self:GetAbility().OnProjectileHit then
            for _, v in ipairs(hits) do
                local didtargetgetkilled = false
                for __, vv in ipairs(self.executed) do
                    if v == vv then 
                        didtargetgetkilled = true
                        break
                    end
                end
                if not didtargetgetkilled then
                    self:GetAbility():OnProjectileHit(v, nextPos)
                end
            end
        end
    end
    
    function modifier_beam_thinker:OnHeroKilled(args)
        if args.attacker == self:GetCaster() then
            table.insert(self.executed, args.target)
        end
    end


    function modifier_beam_thinker:CheckState()
        return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
    end

    function modifier_beam_thinker:OnDestroy()
        UTIL_Remove(self:GetParent())
    end
end
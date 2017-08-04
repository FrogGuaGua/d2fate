modifier_transfusion_bloodpower = class({})

function modifier_transfusion_bloodpower:GetAttributes()
  return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

--[[particle is too much nerf
if IsServer() then
  function modifier_transfusion_bloodpower:OnCreated()
    local parent = self:GetParent()
    self.PI1 = ParticleManager:CreateParticleForTeam("particles/custom/vlad/vlad_tf_bloodpower.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent, parent:GetTeamNumber())
    ParticleManager:SetParticleControlEnt(self.PI1, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_lance_tip", parent:GetAbsOrigin(), false)
    ParticleManager:SetParticleControlEnt(self.PI1, 3, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_lance_tip", parent:GetAbsOrigin(), false)
  end
  function modifier_transfusion_bloodpower:OnDestroy()
    FxDestroyer(self.PI1, false)
  end
end
--]]

if IsServer() then
  function modifier_transfusion_bloodpower:OnStackCountChanged( iStackCount)
    local bloodpower = self:GetStackCount()
    CustomNetTables:SetTableValue("sync", "vlad_bloodpower_count", {count = bloodpower})
  end
end

function modifier_transfusion_bloodpower:IsHidden()
  return false
end

function modifier_transfusion_bloodpower:IsDebuff()
  return false
end

function modifier_transfusion_bloodpower:RemoveOnDeath()
  return true
end

function modifier_transfusion_bloodpower:GetTexture()
  return "custom/vlad_transfusion2"
end

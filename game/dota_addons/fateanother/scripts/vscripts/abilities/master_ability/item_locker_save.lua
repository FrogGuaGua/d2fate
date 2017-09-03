master_item_locker_save = class({})

if IsClient() then
  return
end

function master_item_locker_save:CastFilterResult()
  return UF_FAIL_CUSTOM
end

function master_item_locker_save:GetCustomCastError()
  local hHero = self:GetCaster():GetPlayerOwner():GetAssignedHero()
  self:StartCooldown(0.5)
  if not hHero.bIsInventoryLocked then 
    self:StartItemLock()
    return "Items' inventory positions successfully locked."
  else    
    self:StopItemLock()
    return "Item lock removed."
  end
end

function master_item_locker_save:StartItemLock()
  local hHero = self:GetCaster():GetPlayerOwner():GetAssignedHero()
  local tItemTable = {}
  for i=0,5 do 
    local hItem = hHero:GetItemInSlot(i)
    if hItem ~= nil then 
      tItemTable[i] = hItem:GetName()
    else 
      tItemTable[i] = nil
    end
  end
  hHero.tLockedInventoryOrder = tItemTable
  hHero.bIsInventoryLocked = true  
end

function master_item_locker_save:StopItemLock()
  local hHero = self:GetCaster():GetPlayerOwner():GetAssignedHero()
  hHero.tLockedInventoryOrder = nil
  hHero.bIsInventoryLocked = false
end
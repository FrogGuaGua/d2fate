--[[
1. Make sure npc_abilities_custom.txt precaches all particles.
2. Edit line 8 and also AlternateParticles:Switch(string) function in line 27.
3. Edit the relevant hero_ability.lua. Example being rider_ability.lua line 272 to 288. 
   Note that Creating/SetParticleControlEnt/Destroying after timer for a given particle choice MUST all be handled within a single if/elif/else condition. 
]]

AlternateParticle = {q = 0, w = 0, e = 0, r = 0, d = 0, f = 0, combo = 0}

function SendChatToPanorama(string)
    local table =
    {
        text = string
    }
    CustomGameEventManager:Send_ServerToAllClients( "player_chat_lua", table )
end


function AlternateParticle:initialise(hero)
  Name = {heroName = PlayerResource:GetSelectedHeroName(hero:GetPlayerOwnerID())}
  setmetatable(Name, self)
  print("Initialize for:", hero:GetName())
  self.__index = self
  return Name
end

function AlternateParticle:Switch(string)
  if string == "-r 0" then
    self.r = 0
  end
  if string == "-r 1" then
    self.r = 1
  end
  if string == "-r ?" then
    SendChatToPanorama("r is now "..tostring(self.r))
  end
  if string == "-combo 0" then
    self.combo = 0
  end
  if string == "-combo 1" then
    self.combo = 1
  end
  if string == "-combo ?" then
    SendChatToPanorama("combo is now "..tostring(self.r))
  end

end


ServantStatistics = {cScroll = 0, bScroll = 0, aScroll = 0, sScroll = 0, exScroll = 0, attr1 = 0, attr2 = 0, attr3 = 0, attr4 = 0, attr5 = 0, shard1 = 0, shard2 = 0, shard3 =0, 
shard4 = 0, damageDealt = 0, damageTaken = 0, damageTakenBR = 0, damageDealtBR = 0, ward = 0, familiar = 0, link = 0, goldWasted = 0, itemValue = 0, qseal = 0, wseal = 0, eseal = 0, rseal = 0, 
kill = 0, tkill=0, death = 0, assist = 0, str = 0, agi = 0, int = 0, atk = 0, armor = 0, hpregen = 0, mpregen = 0, ms = 0, lvl = 1, round = 0, winGame = "Ongoing", radiantWin = 0, direWin = 0}

function ServantStatistics:initialise(hero)
  NameAndID = {heroName = PlayerResource:GetSelectedHeroName(hero:GetPlayerOwnerID()), playerName = PlayerResource:GetPlayerName(hero:GetPlayerOwnerID()), steamId = PlayerResource:GetSteamID(hero:GetPlayerOwnerID())}
  setmetatable(NameAndID, self)
  print("Initialize for:", hero:GetName(), PlayerResource:GetSteamID(hero:GetPlayerOwnerID()) )
  self.__index = self
  return NameAndID
end


function ServantStatistics:useC()
  self.cScroll = self.cScroll + 1
end

function ServantStatistics:useB()
  self.bScroll = self.bScroll + 1
end

function ServantStatistics:useA()
  self.aScroll = self.aScroll + 1
end

function ServantStatistics:useS()
  self.sScroll = self.sScroll + 1
end

function ServantStatistics:useEX()
  self.exScroll = self.exScroll + 1
end

function ServantStatistics:useA1()
  self.attr1 = self.attr1 + 1
end

function ServantStatistics:useA2()
  self.attr2 = self.attr2 + 1
end

function ServantStatistics:useA3()
  self.attr3 = self.attr3 + 1
end

function ServantStatistics:useA4()
  self.attr4 = self.attr4 + 1
end

function ServantStatistics:useA5()
  self.attr5 = self.attr5 + 1
end

function ServantStatistics:addStr()
  self.str = self.str + 1
end

function ServantStatistics:addAgi()
  self.agi = self.agi + 1
end

function ServantStatistics:addInt()
  self.int = self.int + 1
end

function ServantStatistics:addAtk()
  self.atk = self.atk + 1
end

function ServantStatistics:addArmor()
  self.armor = self.armor + 1
end

function ServantStatistics:addHPregen()
  self.hpregen = self.hpregen + 1
end

function ServantStatistics:addMPregen()
  self.mpregen = self.mpregen + 1
end

function ServantStatistics:addMS()
  self.ms = self.ms + 1
end

function ServantStatistics:getS1()
  self.shard1 = self.shard1 + 1
end

function ServantStatistics:getS2()
  self.shard2 = self.shard2 + 1
end

function ServantStatistics:getS3()
  self.shard3 = self.shard3 + 1
end

function ServantStatistics:getS4()
  self.shard4 = self.shard4 + 1
end

function ServantStatistics:useWard()
  self.ward = self.ward + 1
end

function ServantStatistics:useFamiliar()
  self.familiar = self.familiar + 1
end

function ServantStatistics:useLink()
  self.link = self.link + 1
end

function ServantStatistics:trueWorth(gold)
  self.itemValue = self.itemValue + gold
end

function ServantStatistics:wastedGold(gold)
  self.goldWasted = self.goldWasted + gold
end

function ServantStatistics:useQSeal()
  self.qseal = self.qseal + 1
end

function ServantStatistics:useWSeal()
  self.wseal = self.wseal + 1
end

function ServantStatistics:useESeal()
  self.eseal = self.eseal + 1
end

function ServantStatistics:useRSeal()
  self.rseal = self.rseal + 1
end

function ServantStatistics:takeActualDamage(damage)
  self.damageTaken = self.damageTaken + damage
end

function ServantStatistics:doActualDamage(damage)
  self.damageDealt = self.damageDealt + damage
end

function ServantStatistics:takeDamageBeforeReduction(damage)
  self.damageTakenBR = self.damageTakenBR + damage
end

function ServantStatistics:doDamageBeforeReduction(damage)
  self.damageDealtBR = self.damageDealtBR + damage
end

function ServantStatistics:onKill()
  self.kill = self.kill + 1
end

function ServantStatistics:onTeamKill()
  self.tkill = self.tkill + 1
end

function ServantStatistics:onDeath()
  self.death = self.death + 1
end

function ServantStatistics:onAssist()
  self.assist = self.assist + 1
end

function ServantStatistics:getLvl(hero)
  self.lvl = hero:GetLevel()
end

function ServantStatistics:roundNumber(x)
  self.round = x
end

function ServantStatistics:EndOfGame(winloss)
  self.winGame = winloss
end

function ServantStatistics:EndOfRound(radiant,dire)
  self.radiantWin = radiant
  self.direWin = dire
end

function SendChatToPanorama(string)
    local table =
    {
        text = string
    }
    CustomGameEventManager:Send_ServerToAllClients( "player_chat_lua", table )
end

function ServantStatistics:printconsole()
  local heroNames = {
    ["npc_dota_hero_legion_commander"] = "Saber",
    ["npc_dota_hero_phantom_lancer"] = "Lancer(5th)",
    ["npc_dota_hero_spectre"] = "Saber Alter(5th)",
    ["npc_dota_hero_ember_spirit"] = "Archer(5th)",
    ["npc_dota_hero_templar_assassin"] = "Rider(5th)",
    ["npc_dota_hero_doom_bringer"] = "Berserker(5th)",
    ["npc_dota_hero_juggernaut"] = "Assassin(5th)",
    ["npc_dota_hero_bounty_hunter"] = "True Assassin(5th)",
    ["npc_dota_hero_crystal_maiden"] = "Caster(5th)",
    ["npc_dota_hero_skywrath_mage"] = "Archer(4th)",
    ["npc_dota_hero_sven"] = "Berserker(4th)",
    ["npc_dota_hero_vengefulspirit"] = "Avenger",
    ["npc_dota_hero_huskar"] = "Lancer(4th)",
    ["npc_dota_hero_chen"] = "Rider(4th)",
    ["npc_dota_hero_shadow_shaman"] = "Caster(4th)",
    ["npc_dota_hero_lina"] = "Saber(Extra), Nero",
    ["npc_dota_hero_omniknight"] = "Saber(Extra), Gawain",
    ["npc_dota_hero_enchantress"] = "Caster(Extra), Tamamo",
    ["npc_dota_hero_bloodseeker"] = "Assassin(Extra)",
    ["npc_dota_hero_mirana"] = "Ruler(Apocrypha)",
    ["npc_dota_hero_queenofpain"] = "Rider of Black(Apocrypha)",
    ["npc_dota_hero_windrunner"] = "Caster(Extra), N.R",
    ["npc_dota_hero_drow_ranger"] = "Archer of Red(Apocrypha)",
  }


  SendChatToPanorama("------------------------------------------------------------------------------------------------------------------------------------------------------------------")
  SendChatToPanorama("Date / Time / Map / Game Duration in seconds:     "..tostring(GetSystemDate()).."\t"..tostring(GetSystemTime()).."\t"..tostring(GetMapName()).."\t"..tostring(math.ceil(GameRules:GetGameTime())))
  SendChatToPanorama("Player Name:                                      "..tostring(self.playerName))
  SendChatToPanorama("Steam ID:                                         "..tostring(self.steamId))
  SendChatToPanorama("Hero Name:                                        "..tostring(heroNames[tostring(self.heroName)]))
  SendChatToPanorama("Hero Level:                                       "..tostring(self.lvl))
  SendChatToPanorama("Round Number / Good Vs Bad Score / Won Game?:     "..tostring(self.round.."\t"..self.radiantWin.."-"..self.direWin.." "..self.winGame))
  SendChatToPanorama("K / D / A / TeamKill:                             "..tostring(self.kill.."\t"..self.death.."\t"..self.assist.."\t"..self.tkill))
  SendChatToPanorama("Gold Spent / Actual Value / Gold Wasted:          "..tostring(self.itemValue + self.goldWasted.."\t"..self.itemValue.."\t"..self.goldWasted))
  SendChatToPanorama("Damage dealt, Actual / Before Reduction:          "..tostring(self.damageDealt.."\t"..self.damageDealtBR))
  SendChatToPanorama("Damage taken, Actual / Before Reduction:          "..tostring(self.damageTaken.."\t"..self.damageTakenBR))
  SendChatToPanorama("Seal Q / W / E / R:                               "..tostring(self.qseal.."\t"..self.wseal.."\t"..self.eseal.."\t"..self.rseal))
  SendChatToPanorama("C / B / A / S / EX:                               "..tostring(self.cScroll.."\t"..self.bScroll.."\t"..self.aScroll.."\t"..self.sScroll.."\t"..self.exScroll))
  SendChatToPanorama("Ward / Familiar / Link:                           "..tostring(self.ward.."\t"..self.familiar.."\t"..self.link))
  SendChatToPanorama("Str/Agi/Int/Atk/Armor/HPregen/MPregen/MSpeed      "..tostring(self.str.."\t"..self.agi.."\t"..self.int.."\t"..self.atk.."\t"..self.armor.."\t"..self.hpregen.."\t"..self.mpregen.."\t"..self.ms))
  --SendChatToPanorama("(Work in Progress) Attributes taken:             "..tostring(self.attr1.."\t"..self.attr2.."\t"..self.attr3.."\t"..self.attr4.."\t"..self.attr5))
  SendChatToPanorama("Avarice / Anti-Magic / Replenishment / Prosperity:"..tostring(self.shard1.."\t"..self.shard2.."\t"..self.shard3.."\t"..self.shard4))
  SendChatToPanorama("------------------------------------------------------------------------------------------------------------------------------------------------------------------")
end

-- local hero = keys.caster:GetPlayerOwner():GetAssignedHero()
-- hero.ServStat:doDamageBeforeReduction(damage)

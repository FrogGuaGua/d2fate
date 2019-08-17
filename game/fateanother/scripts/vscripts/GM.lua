local GM = {}

GM.parse = function(keys)
	local str = keys.text
	if string.find(str,'-') == 1 then
		print('str ',str)
		str = string.sub(str,2,-1)
	end

	if str == nil then
		return
	end
	print('str[1]',str)

	local args = string.split(str,' ')
	if #args == 0 then
		return
	end

	local funcName = args[1]
	local funcArgs = {}
	for i=2 , #args do
		table.insert(funcArgs,args[i])
	end
	print('gm parse ',funcName)
	
	local player = PlayerInstanceFromIndex(keys.userid)

	if GM[funcName] then
		GM[funcName](player,funcArgs)
	else
		print("[GM]: not find ",funcName)
	end
end

GM.rs = function(player)
	SendToConsole("script_reload")
end

GM.additem = function(player,args)
	local item = player:GetAssignedHero():AddItemByName(args[1])
	print(item)
end

GM.items = function(player,args)
	local hero = player:GetAssignedHero()
	for slot=0,5 do
		local item = hero:GetItemInSlot(slot)
		if item then
			print(item:GetName())
		end
	end
end

GM.unpause = function (player,args)
	local heroList = HeroList:GetAllHeroes()
	for _ , hero in pairs(heroList) do
        hero:RemoveModifierByName("round_pause")
	end
end

require 'FileLib/filelib'

GM.btf = function(player,args)
	local FileLib = GameRules.FileLib
	FileLib.RunBat('behavior\\ai\\generate.bat')
end

GM.cl = function()
	SendToConsole("clear")
end

GM.file = function()
	print(package.path)
	print(package.cpath)

	local info = debug.getinfo(1) -- 第二个参数 "S" 表示仅返回 source,short_src等字段， 其他还可以 "n", "f", "I", "L"等 返回不同的字段信息

	for k,v in pairs(info) do
	        print(k, ":", v)
	end

	local path = info.source

	path = string.sub(path, 2, -1) -- 去掉开头的"@"
	print(path)
	path = string.match(path, "^.*\\") -- 捕获最后一个 "/" 之前的部分 就是我们最终要的目录部分
	print("dir=", path)
end

GM.lvl = function(player,args)
	local heroList = HeroList:GetAllHeroes()
	for _ , hero in pairs(heroList) do
		for lvl=1, 25 do
			hero:HeroLevelUp(false)
		end
	end
end

GM.ai = function(player,args)
	print('args[1] ',args[1])
	local heroList = HeroList:GetAllHeroes()
	for _ , hero in pairs(heroList) do
       if hero:GetName() == args[2] then
			AttachAI(hero,tonumber(args[1]))
       end
	end
end

GM.rai = function(player,args)
	RemoveAI(player:GetAssignedHero())
	local heroList = HeroList:GetAllHeroes()
	for _ , hero in pairs(heroList) do
        RemoveAI(hero)
	end
end

GM.skill = function(player,args)
	local playerHero = player:GetAssignedHero()
	local heroList = HeroList:GetAllHeroes()
	local target = nil
	for _ , hero in pairs(heroList) do
		if hero:GetTeam() ~= playerHero:GetTeam() then
			target = hero
			break
		end
	end

	for _ , hero in pairs(heroList) do
		if hero:GetName() == "npc_dota_hero_spectre" then
			local ability = hero:FindAbilityByName("saber_alter_unleashed_ferocity")
			--ability:CastAbility()
			hero:CastAbilityNoTarget(ability,-1)
		end

		if hero:GetName() == "npc_dota_hero_phantom_lancer" and hero:GetTeam() == playerHero:GetTeam() then
			local aiClass = AIClass[hero:GetName()]
			hero.aiClass = aiClass.new(hero)
			local Q = 'lancer_5th_rune_magic'
			local W1 = 'lancer_5th_rune_of_replenishment'
			local E1 = 'lancer_5th_rune_of_trap'
			hero:SwapAbilities(Q, W1, true, true)
			hero:SwapAbilities(Q, E1, true, true)
			local ability = hero:FindAbilityByName(E1)
			--hero.aiClass:aiCastAbility(target,ability)
			print("ability ",ability:IsHidden())
			hero.aiClass:aiCastAbility(target, ability)
		end
	end
end

GM.getname = function(player,args)
	local heroList = HeroList:GetAllHeroes()
	local playerHero = player:GetAssignedHero()
	
	local hero = nil
	for _ , _hero in pairs(heroList) do
		print('name ',_hero:GetName())

	end
	local playerTeam = playerHero:GetTeam()
	local tb =FindUnitsInRadius(playerTeam,playerHero:GetAbsOrigin(),nil,3000,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,0,false)
	for _ , unit in ipairs(tb) do
		if playerHero:CanEntityBeSeenByMyTeam(unit) then
			local name = unit:GetUnitName()
			print('FindUnitsInRadius',name)
		end

	end
end

GM.fog = function(player,args)
	CDOTABaseGameMode:SetFogOfWarDisabled(true)
end

GM.kill = function(player,args)
	local playerHero = player:GetAssignedHero()
	print('playerHero:IsAlive()',playerHero:IsAlive())
	playerHero:ForceKill(true)
	playerHero:SetContextThink('test', function()
		print('playerHero:IsAlive()',playerHero:IsAlive())
	end, 1)
end

GM.tianfu = function(player,args)
	local playerHero = player:GetAssignedHero()
	local MasterUnit2 = playerHero.MasterUnit2
	print('masterunit2')
	for i=0 , 14 do
		local ability = MasterUnit2:GetAbilityByIndex(i)
		if ability then
			print('ability ',ability:GetName())
			ability:CastAbility()
		end
	end
end

GM.lz = function(player,args)
	local playerHero = player:GetAssignedHero()
	local MasterUnit = playerHero.MasterUnit
	local cmd_seal_2 = MasterUnit:FindAbilityByName("cmd_seal_2")
	cmd_seal_2:CastAbility()
	cmd_seal_2:EndCooldown()
	local mod = playerHero:FindModifierByName('modifier_command_seal_2')
	if mod then
		print(mod)
		playerHero:RemoveModifierByName('modifier_command_seal_2')
	end
end

GM.getpos = function(player,args)
	local playerHero = player:GetAssignedHero()
	local pos = player:GetAbsOrigin()
	print('round ',GameRules.AddonTemplate.nCurrentRound)
	print(pos,'team',playerHero:GetTeam())
end

GM.points = function(player,args)
	local playerHero = player:GetAssignedHero()
	for idx=0 , 14 do
		local ability = playerHero:GetAbilityByIndex(idx)
		if ability then
			for i=1 , 10 do
				playerHero:UpgradeAbility(ability)
			end
		end
	end
end

GM.particle = function(player,args)
	local playerHero = player:GetAssignedHero()
	
	local heroList = HeroList:GetAllHeroes()
	for _ , _hero in pairs(heroList) do
		if _hero:GetName() == 'npc_dota_hero_phantom_lancer' then
			local ability = _hero:FindAbilityByName('lancer_5th_rune_of_trap')
			if ability then
				local range = ability:GetCastRange(_hero:GetAbsOrigin() ,_hero)
				print('range ',range)
			end
		end
	end
	
end

local function loopmana(hero)
	hero:SetMana(hero:GetMaxMana()) 
	hero:SetContextThink('mana', function()
				loopmana(hero) return 1 end, 1)
end

GM.sethp = function(player,args)
	local playerHero = player:GetAssignedHero()

	local heroList = HeroList:GetAllHeroes()
	for _ , _hero in pairs(heroList) do
		--if _hero:GetName() == 'npc_dota_hero_phantom_lancer' then
		--if 0 == _hero:GetPlayerOwnerID() then
			_hero:SetBaseStrength(10000)
			_hero:SetBaseIntellect(25)
			_hero:SetBaseAgility(25)
			--_hero:SetHealth(1000000)
			print('name ',_hero:GetName())
			loopmana(_hero)
		--end
	end
end

GM.attack = function(player,args)
	local target =nil
	local heroList = HeroList:GetAllHeroes()
	for _ , _hero in pairs(heroList) do
		if _hero:GetName() == 'npc_dota_hero_queenofpain' then
			target = _hero
		end
	end

	local playerHero = player:GetAssignedHero()
	playerHero:MoveToTargetToAttack(target)
end
GM.cai = function(player,args)
	local playerHero = player:GetAssignedHero()
	local pos = playerHero:GetAbsOrigin()
	local team = playerHero:GetTeam()
	print('args[1] ',args[1])
	local hero = CreateUnitByName(args[1],pos,true,nil,nil,team == 2 and 3 or 2 )
	AttachAI(hero)
end

GM.mana = function(player,args)
	local heroList = HeroList:GetAllHeroes()
	for _ , _hero in pairs(heroList) do
		_hero.MasterUnit2:SetMaxMana(1000)
		local maxMana = _hero.MasterUnit2:GetMaxMana()
		_hero.MasterUnit2:SetMana(maxMana)
	end
end

GM.master = function(player,args)
	local playerHero = player:GetAssignedHero()
	local heroList = HeroList:GetAllHeroes()

	for _ , _hero in pairs(heroList) do
		_hero.MasterUnit2:SetMaxMana(1000)
		local maxMana = _hero.MasterUnit2:GetMaxMana()
		_hero.MasterUnit2:SetMana(maxMana)
		print('---',_hero:GetName())
		local unit = _hero
		local master2 = unit.MasterUnit2
		print('master2',master2)
		if master2 then
			for idx=0,4 do
				local ability = master2:GetAbilityByIndex(idx)
				if ability then
					local behavior = ability:GetBehavior()
					print("ability",ability:GetName())
					--if bit.band(behavior,DOTA_ABILITY_BEHAVIOR_NO_TARGET) == 1 then
					ability:CastAbility()
					--end
				end
			end
		end
	end

	
end

GM.delhero = function(player,args)
	local playerHero = player:GetAssignedHero()
	local heroList = HeroList:GetAllHeroes()
	for _ , hero in ipairs(heroList) do
		if hero ~= playerHero then
			hero:Destroy()
		end
	end
end
GM.mod = function(player,args)
	local heroList = HeroList:GetAllHeroes()
	for _ , hero in ipairs(heroList) do
		--if hero:GetName() == 'npc_dota_hero_templar_assassin' then
			print('hero',hero:GetName())
			local modCnt = hero:GetModifierCount()
			for i=0 , modCnt-1 do
				local mod = hero:GetModifierNameByIndex(i)
				print('mod',mod)
			end
		--end
	end
end

local function getNoUseAIName()
	local heroList = HeroList:GetAllHeroes()
	for aiName , _ in pairs(AIClass) do
		local ok =true
		for _ , hero in ipairs(heroList) do
			local name = hero:GetName()
			if aiName == name then
				ok = false
				break
			end
		end
		if ok then
			return aiName
		end
	end
end

local leftRespawnPos = Vector(-3190,1185,259)
local rightRespawnPos = Vector(5900,2180,263)

GM.aiall = function(player,args)
	local nCurrentRound = GameRules.AddonTemplate.nCurrentRound

	local teamHeroCnt = 7
	for teamID=2 , 3 do
		local cnt = PlayerResource:GetPlayerCountForTeam(teamID)
		for i=cnt+1 , teamHeroCnt do
			local name = getNoUseAIName()
			if teamID == 2 then
				if math.mod(nCurrentRound,2) == 0 then
					pos = rightRespawnPos
				else
					pos = leftRespawnPos
				end
			else
				if math.mod(nCurrentRound,2) == 0 then
					pos = leftRespawnPos
				else
					pos = rightRespawnPos
				end
			end 
			print('----CreateUnitByName')
			CreateUnitByName(name,pos,true,nil,nil,teamID)
		end
	end
end
GM.addbot = function(player,args)
    AIPrint("addbot |AddBots");
    GameRules.AddonTemplate:AddBots(tonumber(args[1]),tonumber(args[2]))
    Timers:CreateTimer(2,function()
    AIPrint("addbot| AssignBotsTeam");
    GameRules.AddonTemplate:AssignBotsTeam()
    	end)
end

GM.find = function(player,args)
end

GM.bot = function(player,args)
	SendToConsole("dota_create_fake_clients "..6)
	Timers:CreateTimer(2,function()
    	for playerId=0,6 do
    		local fake = PlayerResource:IsFakeClient(playerId)
    		if fake then
    			for teamId = 0,10 do
    				local cnt = PlayerResource:GetPlayerCountForTeam(teamId)
    				if cnt == 0 then
		                PlayerResource:SetCustomTeamAssignment(playerId,teamId)
    				end
    			end
    		end
    	end
    	end)
end

GM.bc = function(player,args)
	local playerId = tonumber(args[1]) 
	PlayerResource:ReplaceHeroWith(playerId, args[2], 3000, 0)
end

GM.test = function(player,args)
	for playerID=0,13 do
		local player = PlayerResource:GetPlayer(playerID)
		local hero = player:GetAssignedHero()
		if PlayerResource:IsFakeClient(playerID) then
			hero:SetControllableByPlayer(-1,true)
		end
	end
end

GM.log = function(player,args)
	local open = args[1] == '1'
	local m = args[2]
	if m == nil then
		for key , _ in pairs(LogOpen) do
			LogOpen[key] = open
		end
	else
		LogOpen[m] = open
	end
end

GM.rf = function(player,args)
	local heroList = HeroList:GetAllHeroes()
	for _ , hero in pairs(heroList) do
		for index=0 , 16 do
			local ability = hero:GetAbilityByIndex(index)
			if ability then
				ability:EndCooldown()
			end
		end
	end
end

GM.cd = function(player,args)
	local hero = player:GetAssignedHero()
	local ability = hero:GetAbilityByIndex(0)
	if args[1] == '1' then
		ability:EndCooldown()
	end

	print("ability cd",ability:GetCooldownTime())
end

GM.bottest = function(player,args)
	 PlayerResource:SetCustomTeamAssignment(tonumber(args[1]),tonumber(args[2]))
end

GameRules.GM = GM
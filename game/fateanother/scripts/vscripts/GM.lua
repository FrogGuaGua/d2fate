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
	--AttachAI(player:GetAssignedHero())
	local playerHero = player:GetAssignedHero()
	local heroList = HeroList:GetAllHeroes()
	for _ , hero in pairs(heroList) do
		print('hero',hero)
		print('hero',hero:GetName())
		if hero ~= playerHero then
			print('-attach')
			AttachAI(hero)
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
	local myHero = nil
	for _ , hero in pairs(heroList) do
		--if hero:GetTeam() ~= playerHero:GetTeam() then
		if hero:GetName() == 'npc_dota_hero_drow_ranger' then
			myHero = hero
		end
		--end
	end

	local target = nil
	for _ , hero in pairs(heroList) do
		if hero:GetTeam() ~= playerHero:GetTeam() then
			target = hero
		end
	end

	local aiClass = AIClass[myHero:GetName()]
	myHero.aiClass = aiClass.new(myHero)
	-- local ability = myHero:FindAbilityByName("atalanta_traps")
	-- myHero.aiClass:aiCastAbility(target,ability)
	ability = myHero:FindAbilityByName("atalanta_celestial_arrow")
	myHero.aiClass:aiCastAbility(target,ability)
	-- ability = myHero:FindAbilityByName("atalanta_traps_close")
	-- myHero.aiClass:aiCastAbility(target,ability)
end

GM.getname = function(player,args)
	local heroList = HeroList:GetAllHeroes()
	local playerHero = player:GetAssignedHero()
	
	local hero = nil
	for _ , _hero in pairs(heroList) do
		print('name ',_hero:GetName())

	end
	local playerTeam = playerHero:GetTeam()
	local tb =FindUnitsInRadius(playerTeam,playerHero:GetAbsOrigin(),nil,500,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,0,false)
	for _ , unit in pairs(tb) do
		print('unit ',unit:GetUnitName())
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

GameRules.GM = GM
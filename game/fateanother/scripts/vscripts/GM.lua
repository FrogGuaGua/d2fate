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

GM.ai = function(player,args)
	print('args[1] ',args[1])
	local heroList = HeroList:GetAllHeroes()
	for _ , hero in pairs(heroList) do
		if hero ~= player:GetAssignedHero() then
	        GameRules.AIHelper.InitEntityAI(hero,args[1])
		end
	end
end

GM.rai = function(player,args)
	local heroList = HeroList:GetAllHeroes()
	for _ , hero in pairs(heroList) do
        GameRules.AIHelper.RemoveAI(hero)
	end
end

GM.skill = function(player,args)
	local hero = player:GetAssignedHero()
	local idx = tonumber(args[1]) 
	local ability
	
	for idx = 0 , 5 do
		local ability = hero:GetAbilityByIndex(idx)
		if ability then
			print('ability ',idx,ability:GetBehavior())
		end

	end

	for idx = 0 , 5 do
		local item = hero:GetItemInSlot(idx)
		if item then
			print('ability ',idx,item:GetBehavior())
		end
	end
	local target = nil
	local heroList = HeroList:GetAllHeroes()
	for _ , _hero in pairs(heroList) do
        if _hero ~= hero then
        	target = _hero
        end
	end
	local ability = getAbilityByVar(hero,'item_s_scroll_ai')
	hero:CastAbilityOnTarget(target, ability, -1)
	local behavior = ability:GetBehavior()
	print(bit.band(behavior,DOTA_ABILITY_BEHAVIOR_POINT))
end

GM.getname = function(player,args)
	local name = player:GetAssignedHero():GetName()
	print('name',name)
end

GameRules.GM = GM
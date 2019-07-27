local FileLib = {}

local mapFolder = 'fateanother' --地图文件夹名字
local dota2Path = '..\\..\\dota_addons\\' --bin\win64\dota2.exe
local scriptPath = '\\scripts\\vscripts\\'

--文件路径
local ProjectPath = string.format("%s%s%s",dota2Path,mapFolder,scriptPath)

function FileLib.RunBat(bat)
	--local cmd = bat
	local cmd = string.format("start %s%s %s",ProjectPath,bat,ProjectPath)
	print('cmd ',cmd)
	local myfile = io.popen(cmd)
	if nil == myfile then
	    print("open file for dir fail")
	end

	print("\n======commond dir result:")
	-- 读取文件内容
	for cnt in myfile:lines() do
	    print(cnt)
	end

	-- 关闭文件
	myfile:close()
end

GameRules.FileLib = FileLib


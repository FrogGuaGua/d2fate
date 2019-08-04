local BTreeCMN = GameRules.BTreeCMN
local res_attribute = BTreeCMN.res_attribute
local BehaviorTreeMgr = BTreeCMN.Class("BehaviorTreeMgr")
local btfName = GameRules.btfName
local RootNode = GameRules.RootNode
function BehaviorTreeMgr:ctor()
	self.m_Trees = {}
end

function BehaviorTreeMgr:LoadAllBtf(force)
	local szDir = res_attribute.szDir
	for _ , fileName in pairs(btfName) do
		print('LoadAllBtf fileName',fileName)
		local Dir = szDir .. fileName .. res_attribute.suffix
		local btfData = dofile(Dir)
		if btfData then
			local root = RootNode.new()
			if root:CreateTree(btfData,force) then
				--BTreeCMN.Print(('------reload btfData!!!')
				self.m_Trees[fileName] = root
			else
				--BTreeCMN.Print(("CreateTree : %s create tree failed!!",fileName)
			end
		end
	end

	--BTreeCMN.Print(("AI || Btf Load End ================")
end

function BehaviorTreeMgr:GetBtf(btf)
	return self.m_Trees[btf]
end

function BehaviorTreeMgr:ReloadBtf(fileName)
	local Dir = szDir .. fileName .. '/' .. res_attribute.suffix
	local _jsonData = BTreeCMN.DecodeJsonFile(Dir)
	if _jsonData then
		local tree = RootNode:CreateTree(_jsonData)
		if tree then
			self.m_Trees[fileName] = tree
			return
		end
	end
	--BTreeCMN.Print(('Reload %s Failed!',fileName)
end

GameRules.G_BehaviorTreeMgr = BehaviorTreeMgr.new()
GameRules.G_BehaviorTreeMgr:LoadAllBtf()
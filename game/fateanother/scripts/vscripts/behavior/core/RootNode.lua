print('RootNode load ..')
local BTreeCMN = GameRules.BTreeCMN
local BaseNode = GameRules.BaseNode
local NodeClassList = BTreeCMN.NodeClassList

local RootNode = BTreeCMN.Class('RootNode',BaseNode)
GameRules.RootNode = RootNode

------BTreeCMN.Print(('BaseNode %s',BaseNode)

function RootNode:ctor()
	self.m_jsonData = {}
	self.super.ctor(self)
	----BTreeCMN.Print(('BaseNode self.super %s',self.super)
end

function RootNode:CreateTree(data,reload)
	local root = data.root.node

	if root == nil then
		return false
	end

	local pChild = self:createNode(root,reload)
	if pChild then
		self:addChild(pChild)
	end

	return true
end

function RootNode:createNode(_jsonData,reload)
	--DeepPrintTable(_jsonData)
	
	local className = _jsonData['class']
	local nodeClass = NodeClassList[className]
	print('createNode ',className)
	if nodeClass == nil then
		----BTreeCMN.Print(("createNode:  not find class %s",className)
		return nil
	end
	----BTreeCMN.Print(('className %s',className)
	local pNode = nodeClass.new()
	pNode:passParam(_jsonData.arg)

	local _jsonData = _jsonData.node
	if _jsonData then
		for i , data in ipairs(_jsonData) do
			local pChild = self:createNode(data)
			if pChild then
				pNode:addChild(pChild)
			else
				----BTreeCMN.Print(('createNode addchild == nil')
			end
		end
	end

	return pNode
end

function RootNode:process(entity)
	self.super.process(self,entity)

	local ret = true
	local m_children = self.m_children
		--BTreeCMN.Print(('m_children %s',#m_children)
	for i=1 ,#m_children do
		--BTreeCMN.Print(('m_children %s',#m_children)
		ret = m_children[i]:process(entity) and ret
	end
	return ret
end


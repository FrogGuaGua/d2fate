local BTreeCMN = GameRules.BTreeCMN
local BaseNode = BTreeCMN.Class('BaseNode')
GameRules.BaseNode = BaseNode

BTreeCMN.NodeClassList['BaseNode'] = BaseNode

function BaseNode:ctor()
	self.m_parent = nil
	self.m_pos = 0
	self.m_children = {}
	self.m_debug = ""
	self.m_debug_open = false
end

function BaseNode:getParent()
	return m_parent
end

function BaseNode:getChild(_n)
	return self.m_children[_n]
end

function BaseNode:getNext()
	if m_parent == nil then
		return
	end

	return m_parent.m_children[m_pos+1]
end

function BaseNode:addChild(_node)
	if _node ~= nil then
		table.insert(self.m_children,_node)
		_node.m_pos = #self.m_children
		_node.m_parent = self
		return true
	end
	return false
end

function BaseNode:clearChildren()
	self.m_children = {}
end

function BaseNode:process(entity)
	--BTreeCMN.Print(('process !!!!!!!!!!!!')
	self:process_debug(entity)
	return true
end

function BaseNode:process_debug(entity)
	----BTreeCMN.Print(('self.m_debug_open %s',self.m_debug_open)
	if self.m_debug_open then
		BTreeCMN.Print('%s',self.m_debug)
	end
	return true
end

function BaseNode:passParam(_jsonData)
	DeepPrintTable(_jsonData)
	for i , data in pairs(_jsonData) do
		----BTreeCMN.Print(('key %s',data['key'])
		if data['key'] == 'debug' then
			self.m_debug = data['value']
		elseif data['key'] == 'debug_open' then
			self.m_debug_open = data['value'] == '1'
			----BTreeCMN.Print(('self.m_debug_open %s',self.m_debug_open)
		end
	end
end

function BaseNode:passParamData(data)
	return data['key'],data['value']
end

return BaseNode
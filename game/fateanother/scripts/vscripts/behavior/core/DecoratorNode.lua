print('ControlNode load ..')
require 'behavior/common/common'

local BTreeCMN = GameRules.BTreeCMN

do 
	local DecoratorNotNode = BTreeCMN.Class('DecoratorNotNode',BaseNode)
	BTreeCMN.NodeClassList['DecoratorNotNode'] = DecoratorNotNode

	function DecoratorNotNode:process(entity)
		self.super.process(self,entity)

		local m_children = self.m_children
		return not m_children[1]:process(entity)
	end
end

do 
	local DecoratorNotNode = BTreeCMN.Class('DecoratorTrueNode',BaseNode)
	BTreeCMN.NodeClassList['DecoratorTrueNode'] = DecoratorTrueNode

	function DecoratorTrueNode:process(entity)
		self.super.process(self,entity)

		local m_children = self.m_children
		m_children[1]:process(entity)
		return true
	end
end

do 
	local DecoratorNotNode = BTreeCMN.Class('DecoratorFalseNode',BaseNode)
	BTreeCMN.NodeClassList['DecoratorFalseNode'] = DecoratorFalseNode

	function DecoratorFalseNode:process(entity)
		self.super.process(self,entity)

		local m_children = self.m_children
		m_children[1]:process(entity)
		return false
	end
end
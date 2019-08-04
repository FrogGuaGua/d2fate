print('ControlNode load ..')
--require 'common/common'

local BTreeCMN = GameRules.BTreeCMN
local BaseNode = GameRules.BaseNode

do 
	local SequenceNode = BTreeCMN.Class('SequenceNode',BaseNode)
	BTreeCMN.NodeClassList['SequenceNode'] = SequenceNode

	function SequenceNode:passParam(_jsonData)
	end

	function SequenceNode:process(entity)
		self.super.process(self,entity)
		--BTreeCMN.Print(('------ SequenceNode %s',#self.m_children)

		local m_children = self.m_children
		print('SequenceNode #m_children',#m_children)
		for i=1 , #m_children do
			local child = m_children[i]
			ret = child:process(entity)
			--BTreeCMN.Print(('------ ret %s ',ret)
			if ret == false then
				return false
			end
		end
		return true
	end
end

do 
	local SelectorNode = BTreeCMN.Class('SelectorNode',BaseNode)
	BTreeCMN.NodeClassList['SelectorNode'] = SelectorNode

	function SelectorNode:passParam(_jsonData)
	end

	function SelectorNode:process(entity)
		self.super.process(self,entity)

		local m_children = self.m_children
		for i=1 , #m_children do
			local child = m_children[i]
			if child:process(entity) == true then
				return true
			end
		end
		return false
	end
end

do 
	local ParallelSeqNode = BTreeCMN.Class('ParallelSeqNode',BaseNode)
	BTreeCMN.NodeClassList['ParallelSeqNode'] = ParallelSeqNode

	function ParallelSeqNode:passParam(_jsonData)
	end

	function ParallelSeqNode:process(entity)
		self.super.process(self,entity)
		

		local m_children = self.m_children
		local ret = false
		for i=1 , #m_children do
			ret = m_children[i]:process(entity) or ret
		end
		return ret
	end
end

do 
	local ParallelSelNode = BTreeCMN.Class('ParallelSelNode',BaseNode)
	BTreeCMN.NodeClassList['ParallelSelNode'] = ParallelSelNode

	function ParallelSelNode:passParam(_jsonData)
	end

	function ParallelSelNode:process(entity)
		self.super.process(self,entity)

		local m_children = self.m_children
		local ret = true
		for i=1 , #m_children do
			ret = m_children[i]:process(entity) and ret 
		end
		return ret
	end
end


do 
	local RandomSequenceNode = BTreeCMN.Class('RandomSequenceNode',BaseNode)
	BTreeCMN.NodeClassList['RandomSequenceNode'] = RandomSequenceNode
	function RandomSequenceNode:ctor()
		self.super.ctor(self)
		self.m_weight = {}
		self.m_totalWeight = 0
	end
	function RandomSequenceNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)

		for i , data in pairs(_jsonData) do
			--BTreeCMN.Print(('key %s',data['key'])
			if data['key'] == 'weight' then
				self.m_weight = SplitStrToNumArr(data['value'])
				for k , v in ipairs(self.m_weight) do
					self.m_totalWeight = self.m_totalWeight + self.m_weight[k]
				end
			end
		end
	end

	function RandomSequenceNode:process(entity)
		self.super.process(self,entity)
		local roll = math.random(0,self.m_totalWeight)
		local m_children = self.m_children
		local weight = 0
		for i=1 , #m_children do
			weight = weight + self.m_weight[i]
			if weight < roll then
				if not m_children[i]:process(entity) then
					return false
				end
			end
		end
		
		return true
	end
end

do 
	local RandomSelectorNode = BTreeCMN.Class('RandomSelectorNode',BaseNode)
	BTreeCMN.NodeClassList['RandomSelectorNode'] = RandomSelectorNode
	function RandomSelectorNode:ctor()
		self.super.ctor(self)
		self.m_weight = {}
		self.m_totalWeight = 0
	end
	function RandomSelectorNode:passParam(_jsonData)
		self.super.passParam(self,_jsonData)

		for i , data in pairs(_jsonData) do
			--BTreeCMN.Print(('key %s',data['key'])
			if data['key'] == 'weight' then
				self.m_weight = SplitStrToNumArr(data['value'])
				for k , v in ipairs(self.m_weight) do
					self.m_totalWeight = self.m_totalWeight + self.m_weight[k]
				end
			end
		end
	end

	function RandomSelectorNode:process(entity)
		self.super.process(self,entity)
		local roll = math.random(0,self.m_totalWeight)
		local m_children = self.m_children
		local weight = 0
		for i=1 , #m_children do
			weight = weight + self.m_weight[i]
			if weight >= roll then
				return m_children[i]:process(entity)
			end
		end
		
		return false
	end
end

do 
	local BranchSelectorNode = BTreeCMN.Class('BranchSelectorNode',BaseNode)
	BTreeCMN.NodeClassList['BranchSelectorNode'] = BranchSelectorNode
	function BranchSelectorNode:ctor()
		self.super.ctor(self)
	end

	function BranchSelectorNode:process(entity)
		self.super.process(self,entity)
		local m_children = self.m_children
		local conFunc = m_children[1]
		local trueFunc = m_children[2]
		local falseFunc = m_children[3]

		if conFunc:process(entity) then
			return trueFunc:process(entity)
		end

		if falseFunc then
			return falseFunc:process(entity)
		end

		return false
	end
end

print('ControlNode load finish')

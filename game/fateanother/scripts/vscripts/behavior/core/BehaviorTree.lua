require "../BehaviorTreeMgr"

local behaviorTree = bTree.Class("BehaviorTree")
bTree.BehaviorTree = behaviorTree

function behaviorTree:ctor()
	self.fileName 		= ""
	self.root			= nil
end

function behaviorTree:Load(jsonData, names)


end
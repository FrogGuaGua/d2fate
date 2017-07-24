UnitVoice = UnitVoice or class({})
DeathVoiceManager = { bIsReady = true }
LinkLuaModifier("modifier_unit_voice", "modifiers/modifier_unit_voice", LUA_MODIFIER_MOTION_NONE)

function UnitVoice:constructor(unit)
	unit.UnitVoice = self
	self.hUnit = unit
	self.bDisabled = false
	self.time = GameRules:GetGameTime() + 10
	
	local tVoiceKV = LoadKeyValues("scripts/npc/voices.txt")
	for k, v in pairs(tVoiceKV) do
		if k == self.hUnit:GetUnitName() then self.tVoiceList = v break end
	end
	
	if not self.tVoiceList then self.bDisabled = true return end
	
	for k, v in pairs(self.tVoiceList) do
		self[k] = {}
		for key, val in pairs(v) do
			table.insert(self[k], val)
		end
	end
	
	self.hUnit:AddNewModifier(self.hUnit, nil, "modifier_unit_voice", { Duration = -1 })
	self:OnSpawn()
end

function UnitVoice:PlayRandomClientSound(iIssuer, tSounds, fMin, fMax)
	if self.bDisabled or self.time > GameRules:GetGameTime() then return end
	
	local hPlayer = PlayerResource:GetPlayer(iIssuer)
	local i = RandomInt(1, #tSounds)
	local sSound = tSounds[i]
	local fDuration = math.ceil( self.hUnit:GetSoundDuration(sSound, "") )
	
	local data = { SoundEvent = sSound }
	CustomGameEventManager:Send_ServerToPlayer(hPlayer, "PlayVoiceSound", data)
	self.time = GameRules:GetGameTime() + fDuration + RandomInt(fMin, fMax)
end

function UnitVoice:OnSpawn()
	if not self.Spawn then return end
	
	local hPlayer = self.hUnit:GetPlayerOwner()
	local i = RandomInt(1, #self.Spawn)
	local sSound = self.Spawn[i]
	
	local data = { SoundEvent = sSound }
	CustomGameEventManager:Send_ServerToPlayer(hPlayer, "PlayVoiceSound", data)
end

function UnitVoice:OnMove(iIssuer)
	if not self.Move then return end
	self:PlayRandomClientSound(iIssuer, self.Move, 1, 3)
end

function UnitVoice:OnAttack(iIssuer)
	if not self.Attack then return end
	self:PlayRandomClientSound(iIssuer, self.Attack, 1, 3)
end

function UnitVoice:OnCast(iIssuer)
	if not self.Cast then return end
	self:PlayRandomClientSound(iIssuer, self.Cast, 1, 3)
end

-- NOTE i've been very lazy here. The hurt sound will always play for the owner of the unit, even if the unit is unselected (same thing happens for spawn/respawn, but thats not as big a deal). Maybe i'll do it better some other day.
function UnitVoice:OnHurt()
	if self.bDisabled or self.time > GameRules:GetGameTime() or not self.Hurt then return end
	local hPlayer = self.hUnit:GetPlayerOwner()
	local i = RandomInt(1, #self.Hurt)
	local sSound = self.Hurt[i]
	
	local data = { SoundEvent = sSound }
	CustomGameEventManager:Send_ServerToPlayer(hPlayer, "PlayVoiceSound", data)
	self.time = GameRules:GetGameTime() + 10
end

function UnitVoice:OnRespawn()
	if self.bDisabled or not self.Respawn then return end
	local hPlayer = self.hUnit:GetPlayerOwner()
	local i = RandomInt(1, #self.Respawn)
	local sSound = self.Respawn[i]
	
	local data = { SoundEvent = sSound }
	CustomGameEventManager:Send_ServerToPlayer(hPlayer, "PlayVoiceSound", data)
	self.time = GameRules:GetGameTime() + 10
end

function UnitVoice:OnDeath(hKiller)
	if self.bDisabled or not self.Death then return end
	
	local hPlayer = self.hUnit:GetPlayerOwner()
	local i = RandomInt(1, #self.Death)
	local sSound = self.Death[i]
	local fDuration = math.ceil( self.hUnit:GetSoundDuration(sSound, "") )

	if DeathVoiceManager:IsReady() then
		DeathVoiceManager:PlayPublicDeath(self.hUnit, hKiller, sSound, fDuration)
		self.time = GameRules:GetGameTime() + 10
		return
	end
	
	if self.time > GameRules:GetGameTime() then return end
	
	local data = { SoundEvent = sSound }
	CustomGameEventManager:Send_ServerToPlayer(hPlayer, "PlayVoiceSound", data)
	self.time = GameRules:GetGameTime() + 10
end

function DeathVoiceManager:IsReady()
	return self.bIsReady
end

function DeathVoiceManager:PlayPublicDeath(hUnit, hKiller, sSound, fDuration)
	if not hUnit.UnitVoice or not hKiller.UnitVoice then return end
	self.bIsReady = false
	Timers:CreateTimer(15, function() self.bIsReady = true end)
	hUnit:EmitSound(sSound)
	
	if hKiller.UnitVoice.tVoiceList.Kill then
		local tKillSounds = hKiller.UnitVoice.Kill
		local i = RandomInt(1, #tKillSounds)
		local sKillSound = tKillSounds[i]
		
		Timers:CreateTimer(fDuration, function()
			hKiller:EmitSound(sKillSound)
		end)
	end
end
_G.AIClass = 
{
	npc_dota_hero_spectre = SpectreAIClass,
	npc_dota_hero_templar_assassin = TaAIClass,
	npc_dota_hero_juggernaut = JuggAIClass,
	npc_dota_hero_bloodseeker = BloodAIClass,
	npc_dota_hero_windrunner = WindRunnerAIClass,
	npc_dota_hero_legion_commander = LCAIClass,
	npc_dota_hero_tidehunter = THAIClass,
	npc_dota_hero_crystal_maiden = CMAIClass,
	npc_dota_hero_lina = LinaAIClass,
	npc_dota_hero_skywrath_mage = SkyWrathAIClass,
	npc_dota_hero_doom_bringer = DoomAIClass,
	npc_dota_hero_phantom_lancer = LancerAIClass,
	npc_dota_hero_huskar = HaskarAIClass,
	npc_dota_hero_drow_ranger = DrowRangerAIClass,
}

_G.HasRandName = {}

function _G.GetAIRandName()
	for name in pairs(AIClass) do
		print('-GetAIRandName ',name)
		if Selection.AvailableHeroes[name] ~= nil then
			if HasRandName[name] == nil then
				HasRandName[name] = true
				return name
			end
		end
	end
end 

_G.AIPICKTIME = 10 --AI选人时间

--AI难度
_G.AILevel = 
{
	[1] = 
	{
		firstRefreshCD = 10, --第一次刷新时间
		secondRefreshCD = 30,--刷新CD
		items = 
		{
			'item_blink_scroll_ai',
			'item_mana_essence_ai', --魔力精华
			'item_a_scroll_ai', --A卷
			'item_b_scroll_ai', --B卷
		},
	},
	[2] = 
	{
		firstRefreshCD = 10, --第一次刷新时间
		secondRefreshCD = 20,--刷新CD
		items = 
		{
			'item_blink_scroll_ai',
			'item_mana_essence_ai', --魔力精华
			'item_a_scroll_ai', --A卷
			'item_b_scroll_ai', --B卷
			'item_c_scroll_ai', --C卷
			'item_s_scroll_ai', --S卷
		},
	},
}

WUMING_BUFF = "modifier_avalon" -- 物免
MOMING_BUFF = "modifier_magic_immunity" --魔免
NIAO = "scout_familiar" --鸟
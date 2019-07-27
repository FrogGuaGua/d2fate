local abilityData = {}
--ability	table: 0x0328f828	item_c_scroll_ai
abilityData.npc_dota_hero_doom_bringer =
{
	--突进
	DashAbilitys = {'item_blink_scroll'},
	--进战前技能
	PreFightAbilitys = {2,},
	Combos = 
	{
		{
			abilitys = {1,'item_s_scroll_ai',5,0,},
			range = {
				item_blink_scroll = {rate = 1.0 },
				[1] = {rate = 0.5},
			},
		},
	},
	FightAbilitys = {0,1,5,'item_c_scroll_ai'}
}

GameRules.abilityData = abilityData
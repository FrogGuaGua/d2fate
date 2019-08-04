local AIData = {}

AIData.aiClass = 
{
	npc_dota_hero_spectre = SpectreAIClass,
}

AIData.aiFileName = 
{
	npc_dota_hero_doom_bringer = 'doom',
	npc_dota_hero_ember_spirit = 'ember_spirit',
	npc_dota_hero_phantom_lancer = 'lancer',
}
AIData.HeroHideAbility = 
{
	npc_dota_hero_spectre = 'saber_alter_max_mana_burst'
}

--隐藏技能
AIData.HideAbilitys = 
{
	saber_alter_max_mana_burst = {
		time=600, --几分钟后开启
		atb = 25, --全属性要求
	},
}

--刷新时间间隔
AIData.AIRefreshCD = 20

GameRules.AIData = AIData
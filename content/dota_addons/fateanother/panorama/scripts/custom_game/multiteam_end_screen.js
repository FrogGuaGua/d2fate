this.g_RadiantScore = CustomNetTables.GetTableValue("score", "CurrentScore").nRadiantScore;
this.g_DireScore = CustomNetTables.GetTableValue("score", "CurrentScore").nDireScore;

(function()
{
	if ( ScoreboardUpdater_InitializeScoreboard === null ) { $.Msg( "WARNING: This file requires shared_scoreboard_updater.js to be included." ); }

	var scoreboardConfig =
	{
		"teamXmlName" : "file://{resources}/layout/custom_game/multiteam_end_screen_team.xml",
		"playerXmlName" : "file://{resources}/layout/custom_game/multiteam_end_screen_player.xml",
	};

	var endScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#TeamsContainer" ) );
	$.GetContextPanel().SetHasClass( "endgame", 1 );
	
	var teamInfoList = ScoreboardUpdater_GetSortedTeamInfoList( endScoreboardHandle );
	var delay = 0.2;
	var delay_per_panel = 1 / teamInfoList.length;

	var winningTeamId = Game.GetGameWinner();

	for ( var teamInfo of teamInfoList )
	{
		var teamPanel = ScoreboardUpdater_GetTeamPanel( endScoreboardHandle, teamInfo.team_id );
		teamPanel.SetHasClass("team_endgame", false);
		var callback = function(panel, team_id) {
			return (function() {
				panel.SetHasClass("team_endgame", 1);
				if (team_id == winningTeamId) {
					panel.SetHasClass("team_winner", 1);
				}
			});
		}(teamPanel, teamInfo.team_id);
		$.Schedule( delay, callback )
		delay += delay_per_panel;
	}
	
	var winningTeamDetails = Game.GetTeamDetails( winningTeamId );
	var endScreenVictory = $( "#EndScreenVictory" );
	if ( endScreenVictory )
	{
		if ($.Localize( winningTeamDetails.team_name) === "The Good")
		{
			endScreenVictory.SetDialogVariable( "winning_team_name", $.Localize( "Red Faction" ) );

			if ( GameUI.CustomUIConfig().team_colors )
			{
				//var teamColor = GameUI.CustomUIConfig().team_colors[ winningTeamId ];
				var teamColor = "#9E0606"
				teamColor = teamColor.replace( ";", "" );
				endScreenVictory.style.color = teamColor + ";";
			}
		}
		else if ($.Localize( winningTeamDetails.team_name) === "The Bad")
		{
			endScreenVictory.SetDialogVariable( "winning_team_name", $.Localize( "Black Faction" ) );

			if ( GameUI.CustomUIConfig().team_colors )
			{
				//var teamColor = GameUI.CustomUIConfig().team_colors[ winningTeamId ];
				var teamColor = "#4C4C4C"
				teamColor = teamColor.replace( ";", "" );
				endScreenVictory.style.color = teamColor + ";";
			}
		}
		else if ( endScreenVictory )
		{
			endScreenVictory.SetDialogVariable( "winning_team_name", $.Localize( winningTeamDetails.team_name ) );

			if ( GameUI.CustomUIConfig().team_colors )
			{
				var teamColor = GameUI.CustomUIConfig().team_colors[ winningTeamId ];
				teamColor = teamColor.replace( ";", "" );
				endScreenVictory.style.color = teamColor + ";";
			}
		}
	}

	var winningTeamLogo = $( "#WinningTeamLogo" );
	if ( winningTeamLogo )
	{
		var logo_xml = GameUI.CustomUIConfig().team_logo_large_xml;
		if ( logo_xml )
		{
			winningTeamLogo.SetAttributeInt( "team_id", winningTeamId );
			winningTeamLogo.BLoadLayout( logo_xml, false, false );
		}
	}
})();

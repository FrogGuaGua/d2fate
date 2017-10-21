"use strict";
var LoadingScreen = (function () {
    function LoadingScreen(panel) {
        var _this = this;
        this.panel = panel;
        this.backgroundImage = $("#Background");
        this.tipLabel = $("#TipLabel");
        this.backgrounds = 8; // Number of backgrounds. Change this to add more or less.
        this.tips = 8; // Number of tips.
        var background = Math.floor((Math.random() * this.backgrounds) + 1);
        this.backgroundImage.style.backgroundImage = "url(\"file://{images}/custom_game/loading_screen/" + background.toString() + ".png\")";
        var tip = Math.floor((Math.random() * this.tips) + 1);
        this.tipLabel.text = $.Localize("#Fate_LoadTip" + tip.toString());
        GameEvents.Subscribe("game_rules_state_change", function (data) { _this.OnFinishLoad(data); });
    }
    LoadingScreen.prototype.OnFinishLoad = function (data) {
        if (Game.GameStateIsAfter(DOTA_GameState.DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD)) {
            $("#BackgroundLogo").SetHasClass("Hidden", true);
            $("#Tip").SetHasClass("Hidden", true);
            this.backgroundImage.SetHasClass("Loaded", true);
        }
    };
    return LoadingScreen;
}());
var loadingScreen = new LoadingScreen($.GetContextPanel());

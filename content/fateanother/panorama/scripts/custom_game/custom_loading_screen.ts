class LoadingScreen{
    panel: Panel;
    backgroundImage: Panel;
    tipLabel: LabelPanel;

    backgrounds: number;
    tips: number;

    constructor(panel: Panel){
        this.panel = panel;
        this.backgroundImage = $("#Background");
        this.tipLabel = <LabelPanel>$("#TipLabel")
        this.backgrounds = 4; // Number of backgrounds. Change this to add more or less.
        this.tips = 8; // Number of tips.

        let background = Math.floor((Math.random() * this.backgrounds) + 1);
        this.backgroundImage.style.backgroundImage = "url(\"file://{images}/custom_game/loading_screen/" + background.toString() + ".png\")";

        let tip = Math.floor((Math.random() * this.tips) + 1);
        this.tipLabel.text = $.Localize("#Fate_LoadTip" + tip.toString());

        GameEvents.Subscribe("game_rules_state_change", (data: object)=>{this.OnFinishLoad(data)});
    }

    OnFinishLoad(data: object){
        if(Game.GameStateIsAfter(DOTA_GameState.DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD)) {
            $("#BackgroundLogo").SetHasClass("Hidden", true);
            $("#Tip").SetHasClass("Hidden", true);
            this.backgroundImage.SetHasClass("Loaded", true);
        }
    }
}

let loadingScreen = new LoadingScreen($.GetContextPanel());
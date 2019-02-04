var g_GameConfig = FindCustomUIRoot($.GetContextPanel());
var transport = null;
var bIsMounted = false;
var bRenderCamera = false;

function OnFateConfigButtonPressed()
{
    var configPanel = $("#FateConfigBoard");
    if (!configPanel)
        return;
    configPanel.visible = !configPanel.visible;

    var buffBar = GameUI.CustomUIConfig().buffBar;
    configPanel.FindChildTraverse("option6").enabled = buffBar.visible;
    if (buffBar.visible) {
        configPanel.FindChildTraverse("option6").checked = buffBar.enabled;
    }
}


function OnCameraDistSubmitted()
{
    var panel = $("#ConfigCameraValue");
    var number = parseFloat(panel.text);
    if (number > 1900)
    {
        number = 1900;
    }
    GameUI.SetCameraDistance(number);
    panel.text = number.toString();
}

function RenderCamera(){
    var oSlider = $("#ConfigCameraSlider");
    var fMin = 1600;
    var fMax = 1900;
    var fDistance = fMin + oSlider.value * (fMax - fMin);

    if (fDistance > fMax){
        fDistance = fMax;
    }

    GameUI.SetCameraDistance(fDistance);

    if(bRenderCamera === true){
        $.Schedule(0.016, RenderCamera);
    }
};

function OnCamSliderIn(){
    bRenderCamera = true;
    RenderCamera();
};

function OnCamSliderOut(){
    bRenderCamera = false;
};

function OnConfig1Toggle()
{
    g_GameConfig.bIsConfig1On = !g_GameConfig.bIsConfig1On;
    GameEvents.SendCustomGameEventToServer("config_option_1_checked", {player: Players.GetLocalPlayer(), bOption: g_GameConfig.bIsConfig1On})
}

function OnConfig2Toggle()
{
    g_GameConfig.bIsConfig2On = !g_GameConfig.bIsConfig2On;
    GameEvents.SendCustomGameEventToServer("config_option_2_checked", {player: Players.GetLocalPlayer(), bOption: g_GameConfig.bIsConfig2On})
}


function OnConfig3Toggle()
{
    g_GameConfig.bIsConfig3On = !g_GameConfig.bIsConfig3On;
}


function OnConfig4Toggle()
{
    g_GameConfig.bIsConfig4On = !g_GameConfig.bIsConfig4On;
    GameEvents.SendCustomGameEventToServer("config_option_4_checked", {player: Players.GetLocalPlayer(), bOption: g_GameConfig.bIsConfig4On})
}

function OnConfig5Toggle()
{
    var panel = GetHUDRootUI().FindChildTraverse("MasterStatusPanel");
    panel.ToggleClass("Hidden");
}

function OnConfig6Toggle() {
    var configPanel = $.GetContextPanel();
    var option6 = configPanel.FindChildTraverse("option6");
    var buffBar = GameUI.CustomUIConfig().buffBar;
    if (option6.checked) {
        buffBar.Enable();
    } else {
        buffBar.Disable();
    }
}

function OnConfig7Toggle(){
    var panel = GetHUDRootUI().FindChildTraverse("MasterBar");
    panel.ToggleClass("Hidden");
}

function PlayerChat(event)
{
    var txt = event.text;
    var id = event.playerid;
    var playerID = Players.GetLocalPlayer();
    $.Msg(txt);
    if (playerID == id)
    {
        if (txt == "-bgmoff" && g_GameConfig.bIsBGMOn) {
            StopBGM();
            g_GameConfig.bIsBGMOn = false;
            $.Msg("BGM off by " + playerID)
        }
        if (txt == "-bgmon" && !g_GameConfig.bIsBGMOn) {
            PlayBGM();
            g_GameConfig.bIsBGMOn = true;
            $.Msg("BGM on by " + playerID)
        }
    }
    //GameEvents.SendCustomGameEventToServer("player_chat_panorama", {pID: playerID, text: txt})
}

function TurnBGMOff(event)
{
    StopBGM();
    g_GameConfig.bIsBGMOn = false;
}

function TurnBGMOn(event)
{
    PlayBGM();
    g_GameConfig.bIsBGMOn = true;
}

function CheckTransportSelection(data)
{
    if (g_GameConfig.bIsConfig3On) { return 0; }
    var playerID = Players.GetLocalPlayer();
    var mainSelected = Players.GetLocalPlayerPortraitUnit();
    var hero = Players.GetPlayerHeroEntityIndex( playerID )

    if (mainSelected == hero && transport && bIsMounted)
    {
        // check if transport is currently carrying Caster inside
        if (Entities.IsAlive( transport ))
        {
            GameUI.SelectUnit(transport, false);
        }
    }

}
function RegisterTransport(data)
{
    transport = data.transport;
}
function UpdateMountStatus(data)
{
    bIsMounted = data.bIsMounted;
    $.Msg(bIsMounted);
}

function RegisterMasterUnit(data) {
    var config = GameUI.CustomUIConfig()
    var hero = data.hero;
    var masterUnit = data.shardUnit;
    config.masterUnits[hero] = masterUnit;
}

function RegisterAllMasterUnits(data) {
    var config = GameUI.CustomUIConfig()
    config.masterUnits = data;
}

(function()
{
   // $("#FateConfigBoard").visible = false;
    $("#FateConfigBGMList").SetSelected(1);
    //GameEvents.Subscribe( "player_chat", PlayerChat);
    GameEvents.Subscribe( "player_bgm_on", TurnBGMOn);
    GameEvents.Subscribe( "player_bgm_off", TurnBGMOff);
    GameEvents.Subscribe( "dota_player_update_selected_unit", CheckTransportSelection );
    GameEvents.Subscribe( "player_summoned_transport", RegisterTransport);
    GameEvents.Subscribe( "player_mount_status_changed", UpdateMountStatus);

    var config = GameUI.CustomUIConfig()
    if (!config.masterUnits) {
        config.masterUnits = {}
    }

    GameEvents.Subscribe( "player_register_master_unit", RegisterMasterUnit);
    GameEvents.Subscribe( "player_register_all_master_units", RegisterAllMasterUnits);
})();

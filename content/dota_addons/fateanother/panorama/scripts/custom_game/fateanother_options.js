function ToggleOptionsPanel(panel){
    var pContext = $.GetContextPanel();
    pOptionsContainer = pContext.FindChildTraverse("OptionsMainContainer");
    pOptionsContainer.bHidden = !pOptionsContainer.bHidden;
    pOptionsContainer.SetHasClass("OptionsContainerHidden", pOptionsContainer.bHidden);

    var pBackground = pContext.FindChildTraverse("OptionsBackground");

    if(!pOptionsContainer.bHidden){
        panel.Activate();
        pBackground.visible = true;
        Game.EmitSound("ui_generic_button_click");
    }
    else{
        pBackground.visible = false;
        Game.EmitSound("ui_settings_slide_out");
    }
};

function BackgroundClose(){
    ToggleOptionsPanel();
};

function Tab(sName, url, bSep){
    this.sName = sName;
    this.url = url;
    this.bSep = bSep;
    this.ConstructPanel();
};

Tab.prototype.ConstructPanel = function(){
    var that = this;
    var pContext = $.GetContextPanel();
    pNavBar = pContext.FindChildTraverse("OptionsNavBar");
    pMain = pContext.FindChildTraverse("OptionsTabContainer");

    var activate = function(){ return that.Activate(); };
    var hover = function(){ return that.Hover(); };

    var pNavContainer = $.CreatePanel("Panel", pNavBar, "");
    pNavContainer.SetHasClass("OptionsNavBarPanel", true);
    pNavContainer.bHover = false;
    that.pNavContainer = pNavContainer;

    pNavContainer.SetPanelEvent("onmouseactivate", activate);
    pNavContainer.SetPanelEvent("onmouseover", hover);
    pNavContainer.SetPanelEvent("onmouseout", hover);

    var lName = $.CreatePanel("Label", pNavContainer, "");
    lName.SetHasClass("OptionsNavBarLabel", true);
    lName.text = that.sName;
    that.lName = lName;

    var pContainer = $.CreatePanel("Panel", pMain, "");
    pContainer.BLoadLayout(that.url, false, false);
    pContainer.SetHasClass("Hidden", true);
    that.pContainer = pContainer;

    if (that.bSep) {
        var lSeperator = $.CreatePanel("Label", pNavBar, "");
        lSeperator.text = " / ";
        lSeperator.SetHasClass("OptionsNavBarLabel", true);
        lSeperator.SetHasClass("OptionsNavBarSeperator", true);
    }
};

Tab.prototype.Activate = function(){
    var that = this;
    var pNavContainer = that.pNavContainer;
    var pContext = $.GetContextPanel();
    var cActiveTab = pContext.cActiveTab;

    if (cActiveTab && cActiveTab != that) {
        cActiveTab.pNavContainer.SetHasClass("OptionsNavBarActive", false);
        cActiveTab.pNavContainer.SetHasClass("OptionsNavBarHover", false);
        cActiveTab.pNavContainer.bHover = false;
        cActiveTab.pContainer.SetHasClass("Hidden", true);
    }

    pNavContainer.bHover = false;
    pNavContainer.SetHasClass("OptionsNavBarHover", false);
    pNavContainer.SetHasClass("OptionsNavBarActive", true);
    pContext.cActiveTab = that;
    that.pContainer.SetHasClass("Hidden", false);
};

Tab.prototype.Hover = function(){
    var that = this;
    if (that.pNavContainer.bActivated) { return };
    that.pNavContainer.bHover = !that.pNavContainer.bHover;
    that.pNavContainer.SetHasClass("OptionsNavBarHover", that.pNavContainer.bHover);
};

(function() {
    var pContext = $.GetContextPanel();
    var bOptionsButton = $.CreatePanel("Button", pContext, "OptionsButton");
    var pOptionsContainer = pContext.FindChildTraverse("OptionsMainContainer");
    var pBackground = pContext.FindChildTraverse("OptionsBackground");
    pOptionsContainer.bHidden = true;
    pContext.cActiveTab = null;
    pBackground.visible = false;

    bOptionsButton.SetPanelEvent("onmouseover", function(){
        $.DispatchEvent("DOTAShowTextTooltip", bOptionsButton, "#FA_Options_tooltip");
        bOptionsButton.style.opacity = "1.0";
    });

    bOptionsButton.SetPanelEvent("onmouseout", function(){
        $.DispatchEvent("DOTAHideTextTooltip", bOptionsButton);
        bOptionsButton.style.opacity = "0.5";
    });

    var config = new Tab("Configuration", "file://{resources}/layout/custom_game/fateanother_configuration.xml", true);
    var fatepedia = new Tab("Fatepedia", "file://{resources}/layout/custom_game/fateanother_fatepedia.xml", true);
    var about = new Tab("About", "file://{resources}/layout/custom_game/fateanother_about.xml", false);

    bOptionsButton.SetPanelEvent("onactivate", function(){
        ToggleOptionsPanel(config);
    });

    config.Activate();
})();
"use strict";
var MasterBar = (function () {
    function MasterBar(panel) {
        var _this = this;
        this.panel = panel;
        GameEvents.Subscribe("player_selected_hero", function (data) { _this.CreateAbilities(data); });
    }
    MasterBar.prototype.CreateAbilities = function (data) {
        for (var i = 0; i < Entities.GetAbilityCount(data.shardUnit); i++) {
            var ability = Entities.GetAbility(data.shardUnit, i);
            var abilityName = Abilities.GetAbilityName(ability);
            var str = "cmd_seal";
            if (abilityName.match(str) != null) {
                var panel = $.CreatePanel("DOTAAbilityPanel", this.panel, "");
                new SealButton(panel, ability, abilityName, data.shardUnit);
            }
        }
    };
    return MasterBar;
}());
var SealButton = (function () {
    function SealButton(panel, ability, name, unit) {
        var _this = this;
        this.panel = panel;
        this.ability = ability;
        this.name = name;
        this.unit = unit;
        var oldAbilityImage = this.panel.FindChildTraverse("AbilityImage");
        //abilityImage.SetImage("raw://resource/flash3/images/spellicons/custom/" + this.name + ".png");
        oldAbilityImage.style.visibility = "collapse";
        var abilityImage = $.CreatePanel("DOTAAbilityImage", this.panel.FindChildTraverse("AbilityButton"), "");
        abilityImage.abilityname = this.name;
        abilityImage.style.margin = "9px";
        this.panel.SetPanelEvent("onactivate", function () { _this.OnClick(); });
        this.panel.SetPanelEvent("onmouseover", function () { _this.OnHover(true); });
        this.panel.SetPanelEvent("onmouseout", function () { _this.OnHover(false); });
    }
    SealButton.prototype.OnClick = function () {
        GameEvents.SendCustomGameEventToServer("player_cast_seal", { iUnit: this.unit, iAbility: this.ability });
    };
    SealButton.prototype.OnHover = function (b) {
        if (b) {
            $.DispatchEvent("DOTAShowAbilityTooltip", this.panel, this.name);
        }
        else {
            $.DispatchEvent("DOTAHideAbilityTooltip", this.panel);
        }
    };
    return SealButton;
}());
var masterBar = new MasterBar($.GetContextPanel());
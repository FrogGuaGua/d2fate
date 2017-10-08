"use strict";
var MasterBar = (function () {
    function MasterBar(panel) {
        var _this = this;
        this.panel = panel;
        GameEvents.Subscribe("player_selected_hero", function (data) {
            _this.CreateAbilities(data);
        });
    }

    MasterBar.prototype.CreateAbilities = function (data) {
        var _this = this;
        for (var i = 0; i < Entities.GetAbilityCount(data.shardUnit); i++) {
            var ability = Entities.GetAbility(data.shardUnit, i);
            var abilityName = Abilities.GetAbilityName(ability);
            var str = "cmd_seal";
            if (abilityName.match(str) != null) {
                var panel = $.CreatePanel("DOTAAbilityPanel", this.panel.FindChildTraverse("MasterBarSeals"), "");
                new SealButton(panel, ability, abilityName, data.shardUnit);
            }
        }
        this.Toggle();
        var button = this.panel.FindChildTraverse("MasterBarButton");
        button.SetPanelEvent("onmouseactivate", function () {
            _this.Toggle();
        });
    };
    MasterBar.prototype.Toggle = function () {
        var b = this.panel.BHasClass("closed");
        this.panel.SetHasClass("closed", !b);
        var string = b ? "#MasterBar_close" : "#MasterBar_open";
        string = $.Localize(string).toUpperCase();
        var label = this.panel.FindChildTraverse("MasterBarButtonLabel");
        label.text = string;
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
        this.panel.overrideentityindex = this.ability;
        this.panel.FindChildTraverse("HotkeyContainer").style.visibility = "collapse";
        this.panel.SetPanelEvent("onactivate", function () {
            _this.OnClick();
        });
        this.panel.SetPanelEvent("onmouseover", function () {
            _this.OnHover(true);
        });
        this.panel.SetPanelEvent("onmouseout", function () {
            _this.OnHover(false);
        });
    }

    SealButton.prototype.OnClick = function () {
        GameEvents.SendCustomGameEventToServer("player_cast_seal", {iUnit: this.unit, iAbility: this.ability});
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

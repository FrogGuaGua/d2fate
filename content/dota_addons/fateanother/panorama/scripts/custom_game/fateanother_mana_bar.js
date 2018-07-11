"use strict";
// Currently just used for Mordred
var ManaBar = /** @class */ (function () {
    function ManaBar() {
        var _this = this;
        var root = GetHUDRootUI();
        this.dota_mana = root.FindChildTraverse("ManaContainer");
        this.BuildCustomMana();
        GameEvents.Subscribe("dota_player_update_selected_unit", function () { _this.EventUpdateSelection(); });
        this.EventUpdateSelection();
    }
    ManaBar.prototype.Update = function () {
        var _this = this;
        var unit = Players.GetLocalPlayerPortraitUnit();
        if (Entities.GetUnitName(unit) === "npc_dota_hero_phantom_assassin") {
            var mana_info = CustomNetTables.GetTableValue("sync", unit + "_mana");
            this.custom_mana_label.text = Math.floor(mana_info.mana) + " / " + Math.floor(mana_info.maxMana);
            this.custom_mana_progress.value = mana_info.mana / mana_info.maxMana;
            $.Schedule(1 / 60, function () {
                _this.Update();
            });
        }
    };
    ManaBar.prototype.EventUpdateSelection = function () {
        var _this = this;
        if (Entities.GetUnitName(Players.GetLocalPlayerPortraitUnit()) === "npc_dota_hero_phantom_assassin") {
            this.SetShowDefaultMana(false);
            $.Schedule(1 / 60, function () {
                _this.Update();
            });
        }
        else {
            this.SetShowDefaultMana(true);
        }
    };
    ManaBar.prototype.SetShowDefaultMana = function (show) {
        this.dota_mana.visible = show;
        this.custom_mana.visible = !show;
    };
    ManaBar.prototype.BuildCustomMana = function () {
        var root = GetHUDRootUI().FindChildTraverse("HealthManaContainer");
        if (root.FindChildTraverse("CustomManaContainer") != null) {
            root.FindChildTraverse("CustomManaContainer").DeleteAsync(0);
        }
        this.custom_mana = $.CreatePanel("Panel", root, "CustomManaContainer");
        this.custom_mana.style.width = "100%";
        this.custom_mana.style.height = "26px";
        this.custom_mana_progress = $.CreatePanel("ProgressBar", this.custom_mana, "CustomManaProgress");
        this.custom_mana_progress.style.height = "100%";
        this.custom_mana_progress.style.width = "100%";
        this.custom_mana_progress.style.borderRadius = "0px";
        this.custom_mana_progress.style.border = "0px";
        this.custom_mana_progress.style.backgroundColor = "none";
        var progress_left = this.custom_mana_progress.FindChildTraverse("CustomManaProgress_Left");
        progress_left.style.borderRadius = "3px";
        progress_left.style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #6E2119 ), color-stop( 0.2, #B5362A ), color-stop( .5, #D13E30), to( #6E2119 ) )";
        var dota_scene_container = $.CreatePanel("Panel", progress_left, "");
        dota_scene_container.SetHasClass("DotaSceneContainer", true);
        dota_scene_container.BCreateChildren("<DOTAScenePanel style=\"width:100%;height:100%;hue-rotation:240deg;opacity:.5;\" map=\"scenes/hud/healthbarburner\" camera=\"camera_1\"/>");
        var progress_right = this.custom_mana_progress.FindChildTraverse("CustomManaProgress_Right");
        progress_right.style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #321814 ), color-stop( 0.2, #47221D ), color-stop( .5, #44201B), to( #321814 ) )";
        this.custom_mana_label = $.CreatePanel("Label", this.custom_mana, "CustomManaLabel");
        this.custom_mana_label.style.verticalAlign = "top";
        this.custom_mana_label.style.horizontalAlign = "center";
        this.custom_mana_label.style.textAlign = "center";
        this.custom_mana_label.style.width = "332px";
        this.custom_mana_label.style.marginTop = "2px";
        this.custom_mana_label.style.fontWeight = "bold";
        this.custom_mana_label.style.fontSize = "18px";
        this.custom_mana_label.style.color = "white";
        this.custom_mana_label.style.textShadow = "1px 1px 0px 2.0 #000000";
        this.custom_mana_label.style.fontFamily = "monospaceNumbersFont";
    };
    return ManaBar;
}());
var mana_bar = new ManaBar();

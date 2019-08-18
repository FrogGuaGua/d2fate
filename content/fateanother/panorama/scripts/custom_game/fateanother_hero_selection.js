function HeroSelection() {
    var that = this;
    this.playerId = Game.GetLocalPlayerID();

    this.timeListener = CustomNetTables.SubscribeNetTableListener("selection", function(table, tableKey, data) {
        if (tableKey == "time") {
            that.time = data.time;
        }
    });

    this.availableListener = CustomNetTables.SubscribeNetTableListener("selection", function(table, tableKey, data) {
        if (tableKey == "available") {
            that.availableHeroes = data;
        }
    });

    this.allListener = CustomNetTables.SubscribeNetTableListener("selection", function(table, tableKey, data) {
        if (tableKey == "all") {
            that.allHeroes = data;
        }
    });

    this.pickedListener = CustomNetTables.SubscribeNetTableListener("selection", function(table, tableKey, data) {
        if (tableKey == "picked") {
            that.picked = data;
        }
    });

    this.allHeroes = CustomNetTables.GetTableValue("selection", "all") || {};
    this.availableHeroes = CustomNetTables.GetTableValue("selection", "available") || {};
    this.picked = CustomNetTables.GetTableValue("selection", "picked") || {};

    var timeTable = CustomNetTables.GetTableValue("selection", "time");
    this.time = timeTable && timeTable.time;

    this.container = $.GetContextPanel().FindChild("container");
    this.statusLabel = this.container.FindChildTraverse("status");
    this.timeLabel = this.container.FindChildTraverse("time");

    //this.container.FindChildTraverse("Normal").text = "Normal";
    //this.container.FindChildTraverse("Hard").text = "Hard(Really Hard)";

    this.heroesPanel = this.container.FindChild("heroes");
    this.easyheroesPanel = this.heroesPanel.FindChild("EasyHero");
    this.normalheroesPanel = this.heroesPanel.FindChild("NormalHero");
    this.hardheroesPanel = this.heroesPanel.FindChild("HardHero");

    //this.heroesPanel.FindChild("EasyHero").FindChild("Easy").SetImage("s2r://panorama/images/custom_game/game_info_kotomine_png.vtex");
}

HeroSelection.prototype.OnHover = function() {
	
}

HeroSelection.prototype.Render = function() {
    var that = this;
    if (this.time !== undefined) {
        this.timeLabel.text = this.time > 60 ? (this.time - 60) : this.time;
        this.statusLabel.text = this.time > 60 ? "PICK PHASE BEGINS IN" : "GAME STARTS IN";
    }

    var hero = Players.GetPlayerHeroEntityIndex(this.playerId);
    var name = Entities.GetUnitName(hero);
    var playerHasPicked = !!this.picked[this.playerId];
    var easyheroclass = new Array("npc_dota_hero_spectre","npc_dota_hero_bounty_hunter","npc_dota_hero_queenofpain","npc_dota_hero_drow_ranger","npc_dota_hero_mirana");
    var normalheroclass = new Array("npc_dota_hero_legion_commander","npc_dota_hero_phantom_lancer","npc_dota_hero_ember_spirit","npc_dota_hero_templar_assassin","npc_dota_hero_doom_bringer","npc_dota_hero_juggernaut","npc_dota_hero_huskar","npc_dota_hero_lina","npc_dota_hero_omniknight","npc_dota_hero_enchantress","npc_dota_hero_bloodseeker","npc_dota_hero_windrunner","npc_dota_hero_crystal_maiden","npc_dota_hero_skywrath_mage","npc_dota_hero_sven","npc_dota_hero_vengefulspirit","npc_dota_hero_shadow_shaman","npc_dota_hero_chen","npc_dota_hero_storm_spirit","npc_dota_hero_tidehunter");
    //var hardheroclass = new Array("npc_dota_hero_crystal_maiden","npc_dota_hero_skywrath_mage","npc_dota_hero_sven","npc_dota_hero_vengefulspirit","npc_dota_hero_shadow_shaman","npc_dota_hero_chen","npc_dota_hero_storm_spirit","npc_dota_hero_tidehunter");

    for (var index in easyheroclass) {
        var heroName = easyheroclass[index];
        var heroPanel = this.easyheroesPanel.FindChild(heroName);
        if (heroPanel == null) {
            heroPanel = $.CreatePanel("Image", this.easyheroesPanel, heroName);
            heroPanel.SetImage("s2r://panorama/images/custom_game/selection/" + heroName + "_png.vtex");
            heroPanel.AddClass("hero");
            this.BindOnActivate(heroPanel, heroName);
        }

        var pickedByPlayer = !!this.picked[this.playerId] && this.picked[this.playerId] === heroName;
        heroPanel.SetHasClass("picked", playerHasPicked);
        heroPanel.SetHasClass("selectedByPlayer", pickedByPlayer);
        heroPanel.SetHasClass("grayscale", this.time > 60 || !this.availableHeroes[heroName] && !pickedByPlayer);
    }

    for (var index in normalheroclass) {
        var heroName = normalheroclass[index];
        var heroPanel = this.normalheroesPanel.FindChild(heroName);
        if (heroPanel == null) {
            heroPanel = $.CreatePanel("Image", this.normalheroesPanel, heroName);
            heroPanel.SetImage("s2r://panorama/images/custom_game/selection/" + heroName + "_png.vtex");
            heroPanel.AddClass("hero");
            this.BindOnActivate(heroPanel, heroName);
        }

        var pickedByPlayer = !!this.picked[this.playerId] && this.picked[this.playerId] === heroName;
        heroPanel.SetHasClass("picked", playerHasPicked);
        heroPanel.SetHasClass("selectedByPlayer", pickedByPlayer);
        heroPanel.SetHasClass("grayscale", this.time > 60 || !this.availableHeroes[heroName] && !pickedByPlayer);
    }



    var RecPanel1 = this.easyheroesPanel.FindChild("recommend1");
    if (RecPanel1 == null)
    {
        RecPanel1 = $.CreatePanel("Image",this.easyheroesPanel, "recommend1");
        RecPanel1.SetImage("s2r://panorama/images/custom_game/game_info_kotomine_png.vtex");
        RecPanel1.AddClass("Easy");

    }
    /*for (var index in hardheroclass) {
        var heroName = hardheroclass[index];
        var heroPanel = this.hardheroesPanel.FindChild(heroName);
        if (heroPanel == null) {
            heroPanel = $.CreatePanel("Image", this.hardheroesPanel, heroName);
            heroPanel.SetImage("s2r://panorama/images/custom_game/selection/" + heroName + "_png.vtex");
            heroPanel.AddClass("hero");
            this.BindOnActivate(heroPanel, heroName);
        }

        var pickedByPlayer = !!this.picked[this.playerId] && this.picked[this.playerId] === heroName;
        heroPanel.SetHasClass("picked", playerHasPicked);
        heroPanel.SetHasClass("selectedByPlayer", pickedByPlayer);
        heroPanel.SetHasClass("grayscale", this.time > 60 || !this.availableHeroes[heroName] && !pickedByPlayer);
    }*/

    var randomPanel = this.normalheroesPanel.FindChild("random");
    if (randomPanel == null) {
        randomPanel = $.CreatePanel("Image",this.normalheroesPanel, "random");
        randomPanel.SetImage("s2r://panorama/images/custom_game/selection/random_png.vtex");
        randomPanel.AddClass("hero");
        randomPanel.SetPanelEvent(
            "onactivate",
            function() {
                GameEvents.SendCustomGameEventToServer("selection_hero_random", {
                    playerId: that.playerId,
                });
            }
        );
    }
    randomPanel.SetHasClass("grayscale", this.time > 60);
    randomPanel.SetHasClass("picked", playerHasPicked);

    var hero = Players.GetPlayerHeroEntityIndex(this.playerId);
    this.container.SetHasClass("Hidden", this.time == undefined || hero == -1);
}

HeroSelection.prototype.BindOnActivate = function(panel, hero) {
    var that = this;

    panel.SetPanelEvent(
        "onactivate",
        function() {
            GameEvents.SendCustomGameEventToServer("selection_hero_click", {
                playerId: that.playerId,
                hero: hero,
            });
        }
    );
}

HeroSelection.prototype.Update = function() {
    var that = this;

    var hero = Players.GetPlayerHeroEntityIndex(this.playerId);
    var name = Entities.GetUnitName(hero);

    if (this.time <= 0 && (Players.IsSpectator(this.playerId) || hero !== -1 && name !== "npc_dota_hero_wisp")) {
        this.End();
        return;
    }

    this.Render();

    $.Schedule(0.1, function() {
       that.Update();
    })
}

HeroSelection.prototype.End = function() {
    CustomNetTables.UnsubscribeNetTableListener(this.timeListener);
    CustomNetTables.UnsubscribeNetTableListener(this.availableListener);
    CustomNetTables.UnsubscribeNetTableListener(this.allListener);
    CustomNetTables.UnsubscribeNetTableListener(this.pickedListener);

    this.container.AddClass("Hidden");
}

var selection = new HeroSelection();
selection.Update();

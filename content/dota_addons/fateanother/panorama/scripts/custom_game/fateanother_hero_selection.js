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
    this.heroesPanel = this.container.FindChild("heroes");
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

    for (var heroName in this.allHeroes) {
        var heroPanel = this.heroesPanel.FindChild(heroName);
        if (heroPanel == null) {
            heroPanel = $.CreatePanel("Image", this.heroesPanel, heroName);
            heroPanel.SetImage("s2r://panorama/images/custom_game/selection/" + heroName + "_png.vtex");
            heroPanel.AddClass("hero");
            this.BindOnActivate(heroPanel, heroName);
        }

        var pickedByPlayer = !!this.picked[this.playerId] && this.picked[this.playerId] === heroName;
        heroPanel.SetHasClass("picked", playerHasPicked);
        heroPanel.SetHasClass("selectedByPlayer", pickedByPlayer);
        heroPanel.SetHasClass("grayscale", this.time > 60 || !this.availableHeroes[heroName] && !pickedByPlayer);
    }

    var randomPanel = this.heroesPanel.FindChild("random");
    if (randomPanel == null) {
        randomPanel = $.CreatePanel("Image", this.heroesPanel, "random");
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
    this.container.SetHasClass("Hidden", this.time === undefined || hero === -1);
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

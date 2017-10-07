interface PlayerSelectedHeroEvent{
    masterUnit: number;
    shardUnit: number;
}

class MasterBar{
    panel: Panel;

    constructor(panel: Panel){
        this.panel = panel;
        GameEvents.Subscribe( "player_selected_hero", (data: PlayerSelectedHeroEvent)=>{this.CreateAbilities(data);});
    }

    CreateAbilities(data: PlayerSelectedHeroEvent){
        for(let i = 0; i < Entities.GetAbilityCount(data.shardUnit); i++) {
            let ability: abilityID = Entities.GetAbility(data.shardUnit, i)
            let abilityName: string = Abilities.GetAbilityName(ability);
            let str: string = "cmd_seal";
            if(abilityName.match(str) != null){
                let panel = $.CreatePanel("DOTAAbilityPanel", this.panel.FindChildTraverse("MasterBarSeals"), "");
                new SealButton(panel, ability, abilityName, data.shardUnit);
            }
        }
    }
}

class SealButton{
    panel: Panel;
    ability: abilityID;
    name: string;
    unit: entityID;

    constructor(panel: Panel, ability: abilityID, name: string, unit: entityID){
        this.panel = panel;
        this.ability = ability;
        this.name = name;
        this.unit = unit;
        this.panel.overrideentityindex = this.ability;
        this.panel.FindChildTraverse("HotkeyContainer").style.visibility = "collapse";

        this.panel.SetPanelEvent("onactivate", ()=>{this.OnClick();});
        this.panel.SetPanelEvent("onmouseover", ()=>{this.OnHover(true);});
        this.panel.SetPanelEvent("onmouseout", ()=>{this.OnHover(false);});
    }

    OnClick(){
        GameEvents.SendCustomGameEventToServer("player_cast_seal",{iUnit: this.unit, iAbility: this.ability});
    }

    OnHover(b: boolean){
        if(b){
            $.DispatchEvent("DOTAShowAbilityTooltip", this.panel, this.name);
        }
        else{
            $.DispatchEvent("DOTAHideAbilityTooltip", this.panel);
        }
    }
}

let masterBar = new MasterBar($.GetContextPanel());
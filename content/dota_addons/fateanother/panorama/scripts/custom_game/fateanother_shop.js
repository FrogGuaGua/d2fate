var items = [
    "item_mana_essence",
    "item_ward_familiar",
    "item_scout_familiar",
    "item_berserk_scroll",
    "item_gem_of_speed",
    "item_spirit_link",
    "item_healing_scroll",
    "item_tp_scroll"
]
for(var i = 0; i < items.length; i++){
    Game.AddCommand("purchase_" + items[i], ConsolePurchase(i), "", 0);
}

function ConsolePurchase(i){
    return function() {
        GameEvents.SendCustomGameEventToServer("hotkey_purchase_item", {"item" : items[i]});
        Game.EmitSound("General.Buy");
    }
}
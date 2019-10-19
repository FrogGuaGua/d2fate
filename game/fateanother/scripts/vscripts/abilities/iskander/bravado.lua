
model={}
model["npc_dota_hero_legion_commander"] = "models/saber/saber.vmdl"
model["npc_dota_hero_phantom_lancer"] = "models/lancer/lancer2.vmdl"
model["npc_dota_hero_spectre"] = "models/saber_alter/sbr_alter.vmdl"
model["npc_dota_hero_ember_spirit"] = "models/archer/archertest.vmdl"
model["npc_dota_hero_templar_assassin"] = "models/rider/rider.vmdl"
model["npc_dota_hero_doom_bringer"] = "models/berserker/berserker.vmdl"
model["npc_dota_hero_juggernaut"] = "models/assassin/asn.vmdl"
model["npc_dota_hero_bounty_hunter"] = "models/true_assassin/ta.vmdl"
model["npc_dota_hero_crystal_maiden"] = "models/caster/caster.vmdl"
model["npc_dota_hero_skywrath_mage"] = "models/gilgamesh/gilgamesh.vmdl"
model["npc_dota_hero_sven"] = "models/lancelot/lancelot.vmdl"
model["npc_dota_hero_vengefulspirit"] = "models/avenger/avenger.vmdl"
model["npc_dota_hero_huskar"] = "models/diarmuid/diarmuid2.vmdl"
model["npc_dota_hero_chen"] = "models/iskander/iskander.vmdl"
model["npc_dota_hero_shadow_shaman"] = "models/zc/gille.vmdl"
model["npc_dota_hero_lina"] = "models/nero/nero.vmdl"
model["npc_dota_hero_omniknight"] = "models/gawain/gawain.vmdl"
model["npc_dota_hero_enchantress"] = "models/tamamo/tamamo.vmdl"
model["npc_dota_hero_bloodseeker"] = "models/lishuen/lishuen.vmdl"
model["npc_dota_hero_mirana"] = "models/jeanne/jeanne.vmdl"
model["npc_dota_hero_queenofpain"] = "models/astolfo/astolfo.vmdl"
model["npc_dota_hero_storm_spirit"] = "models/jack/jack.vmdl"
model["npc_dota_hero_axe"] = "models/lvbu/lvbu.vmdl"

qq = "iskander_strategy_operational_research"
qw = "iskander_strategy_bravado"
qe = "iskander_strategy_ambush"
qr = "iskander_strategy_forward"
qf = "iskander_strategy_close_spellbook"

q = "iskander_strategy_open_spellbook"
w = "iskander_cypriot"
e = "iskander_gordius_wheel"
r = "iskander_army_of_the_king"
f = "iskander_charisma"


function OnBravadoStart(keys)
    local target = keys.target
    local caster = keys.caster
    keys.ability:ApplyDataDrivenModifier(caster,target, "iskander_strategy_bravado_invis", {})
    --keys.ability:ApplyDataDrivenModifier(caster,caster, "iskander_strategy_bravado_model", {})
    --if caster:GetModelName() == "models/iskander/iskander_chariot.vmdl" then return end
    --modelname = target:GetName()
    --modelname = model[modelname]
    --caster:SetModel(modelname)
    --caster:SetOriginalModel(modelname)  
    StrategyClose(caster)  
    if caster.IsStrategyImproved then
        caster:FindAbilityByName(q):StartCooldown(1)
    else
        caster:FindAbilityByName(q):StartCooldown(30)
    end   
end

function OnBMInit(keys)
    
end


function OnBMDestroy(keys)
    local caster = keys.caster
    if caster:GetModelName() == "models/iskander/iskander_chariot.vmdl" then return end
    caster:SetModel("models/iskander/iskander.vmdl")
    caster:SetOriginalModel("models/iskander/iskander.vmdl")  
end

function OnBravadoRemoveA(keys)
    local target = keys.target
    target:RemoveModifierByName("iskander_strategy_bravado_invis")
end
function OnBravadoRemoveB(keys)
    local target = keys.unit
    target:RemoveModifierByName("iskander_strategy_bravado_invis")
end


function OnBravadoRemoveC(keys)
    local target = keys.attacker
    target:RemoveModifierByName("iskander_strategy_bravado_invis")
end


function OnBMRemoveB(keys)
    local caster=keys.caster
    caster:RemoveModifierByName("iskander_strategy_bravado_model")
    if caster:GetModelName() == "models/iskander/iskander_chariot.vmdl" then return end
    caster:SetModel("models/iskander/iskander.vmdl")
    caster:SetOriginalModel("models/iskander/iskander.vmdl")  
end


function OnBMRemoveC(keys)
    local caster=keys.caster
    caster:RemoveModifierByName("iskander_strategy_bravado_model")
    if caster:GetModelName() == "models/iskander/iskander_chariot.vmdl" then return end
    caster:SetModel("models/iskander/iskander.vmdl")
    caster:SetOriginalModel("models/iskander/iskander.vmdl")  
end


function StrategyClose(caster)
    caster:SwapAbilities(q, qq, true, false) 
	caster:SwapAbilities(w, qw, true, false) 
    caster:SwapAbilities(e, qe, true, false)
	if caster:HasModifier("modifier_gordius_wheel") then
		caster:SwapAbilities("iskander_via_expugnatio", qr, true, false) 
    else
        caster:SwapAbilities(r, qr, true, false) 
    end
	caster:SwapAbilities(f, qf, true, false) 
end


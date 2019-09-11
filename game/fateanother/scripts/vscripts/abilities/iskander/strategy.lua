

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
function StrategyOpen(keys)
    local caster = keys.caster
    if keys.ability:GetLevel() <=2 then caster:FindAbilityByName(qw):SetActivated(false) end
    if keys.ability:GetLevel() <=3 then caster:FindAbilityByName(qe):SetActivated(false) end
    if keys.ability:GetLevel() <=4 then caster:FindAbilityByName(qr):SetActivated(false) end
    caster:SwapAbilities(qq, q, true, false) 
	caster:SwapAbilities(qw, w, true, false) 
    caster:SwapAbilities(qe, e, true, false)

	if caster:HasModifier("modifier_gordius_wheel") then
		caster:SwapAbilities(qr,"iskander_via_expugnatio", true, false) 	
    else
        caster:SwapAbilities(qr, r, true, false) 
    end
	caster:SwapAbilities(qf, f, true, false) 
end



function StrategyClose(keys)
    local caster = keys.caster
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


function StrategyLevelUp(keys)
    local caster = keys.caster
    local lv=keys.ability:GetLevel()
    caster:FindAbilityByName(qq):SetLevel(lv)
    if keys.ability:GetLevel() ==3 then caster:FindAbilityByName(qw):SetActivated(true) end
    if keys.ability:GetLevel() ==4 then caster:FindAbilityByName(qe):SetActivated(true) end
    if keys.ability:GetLevel() ==5 then caster:FindAbilityByName(qr):SetActivated(true) end
end
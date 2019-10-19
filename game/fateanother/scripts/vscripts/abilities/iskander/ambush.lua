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

function OnAmbushStart(keys)
    local  caster = keys.caster
    local targetpoint = keys.target_points[1]
    local trap = CreateUnitByName("iskander_ambush_trap",targetpoint,true, nil, nil, keys.caster:GetTeamNumber())
    trap:AddNewModifier(keys.caster, nil, "modifier_kill", {duration = keys.duration})
    trap:FindAbilityByName("iskander_ambush_trap_passive"):SetLevel(1)
    trap:FindAbilityByName("soldier_passive"):SetLevel(1)
    trap:SetOwner(keys.caster)
    StrategyClose(caster)
    if caster.IsStrategyImproved then
        caster:FindAbilityByName(q):StartCooldown(1)
    else
        caster:FindAbilityByName(q):StartCooldown(30)
    end   
end

function OnAmbushThink(keys)
    local caster = keys.caster
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    local targets = FindUnitsInRadius(hero:GetTeam(), caster:GetAbsOrigin(), nil, 200
    , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
    if targets[1] ~= nil then
        local pos = targets[1]:GetAbsOrigin()
        for k,v in pairs(targets) do
            DoDamage(hero , v , 100, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
            v:AddNewModifier(caster, nil, "modifier_silence", {duration=2.0})
        end
        for i =1 , 5 do
            local ambush = CreateUnitByName("iskander_ambush",pos,true, nil, nil, keys.caster:GetTeamNumber())
            ambush:AddNewModifier(hero, nil, "modifier_kill", {duration = 5.0})
            FindClearSpaceForUnit(ambush, pos, true)
            ambush:SetOwner(hero)
            ambush:SetForwardVector((pos - ambush:GetAbsOrigin()):Normalized())
            ExecuteOrderFromTable({
                UnitIndex = ambush:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = targets[1]:entindex(),
            })
        end 
        caster:ForceKill(true) 
    end  
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
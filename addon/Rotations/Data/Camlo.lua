local tonumber, GetSpellInfo, IsUsableSpell, IsSpellKnown, IsActiveBattlefieldArena, UnitInBattleground, GetZoneText, IsSpellInRange = tonumber, GetSpellInfo, IsUsableSpell, IsSpellKnown, IsActiveBattlefieldArena, UnitInBattleground, GetZoneText, IsSpellInRange
local lastSpell, lastGuid, lastTime = "", "", 0;
local camlo = {};
local melespells = {47486, 46924, 23881, 47498, 12809, 48827, 35395, 53385, 20066, 48666, 51690, 13877, 13750, 48660, 55262, 49203, 55268, 51411, 55271, 51533, 30823, 17364, 48566, 48564};
local healerspells = {48825, 53007, 10060, 33206, 18562, 61301, 51866, 34861};
local rangespells = {44781, 55360, 42950, 42945, 44572, 59164, 47843, 59672, 59172, 47847, 59159, 16166, 19577, 34490, 53209, 60053, 49012, 53201, 61384}
local braided = {26989, 53308, 42917, 23694, 13809, 45524};
local t4ddpal = {29071, 29072, 29073, 29074, 29075, 100455, 100456, 100457, 100458, 100459, 101355, 101356, 101357, 101358, 101359};
--- Эта функция для милишников, по типу воина, роги, друида и их мили заклинаний
camlo.spellusable = function(id, stutter)
    if tonumber(id) == nil then
        id = ni.spell.id(id)
    end
    local result = false
    if not ni.player.isstunned()
        and ni.spell.available(id, stutter)
        and IsUsableSpell(GetSpellInfo(id)) then
        result = true
    end
    return result
end;
camlo.TTDChecker = function(t, valueTime, valueTTD, hp)
    valueTime = valueTime or 0
    valueTTD = valueTTD or 0
    hp = hp or 0
    if ni.vars.combat.time ~= 0
        and GetTime() - ni.vars.combat.time > valueTime
        and ni.unit.ttd(t) > valueTTD
        and ni.unit.hp(t) >= hp then
        return true;
    end
    return false;
end;
camlo.BossOrCD = function(t, valueTime, valueTTD, hp, enabled)
    if ni.vars.combat.cd then
        return true;
    end;
    local isboss = false;
    if enabled then
        isboss = ni.unit.isboss(t);
        if not isboss then
            return false;
        end
    end
    if camlo.TTDChecker(t, valueTime, valueTTD, hp) then
        if enabled then
            if isboss then
                return true;
            end
            return true;
        end
    end
    return false;
end;
camlo.instance = function()
    return InstanceType == "party";
end;
camlo.inraid = function()
    return InstanceType == "raid";
end;
camlo.CombatStart = function(value)
    if ni.vars.combat.time ~= 0
        and GetTime() - ni.vars.combat.time > value then
        return true;
    end
    return false;
end;
camlo.CombatEnded = function(value)
    if ni.vars.combat.time == 0
        and GetTime() - ni.vars.combat.ended > value then
        return true;
    end
    return false;
end;
camlo.braided = function(t)
    if ni.unit.exists(t) then
        for i, v in ipairs(braided) do
            if ni.unit.debuff(t, v) then
                return true;
            end
        end
    end
end;
--- Эта функция уже для кастеров, так как проверяет наличие сала
camlo.spellusablesilence = function(id, stutter)
    if tonumber(id) == nil then
        id = ni.spell.id(id)
    end
    local result = false
    if not ni.player.isstunned()
        and not ni.player.issilenced()
        and ni.spell.available(id, stutter)
        and IsUsableSpell(GetSpellInfo(id)) then
        result = true
    end
    return result
end;
--- Знаем ли мы заклинание, более прокачаная функция чем стандартная.
camlo.spellisknown = function(id)
    if tonumber(id) == nil then
        id = ni.spell.id(id)
    end
    local result = false
    if id ~= nil
        and id ~= 0
        and IsSpellKnown(id) then
        local name = GetSpellInfo(id)
        if name then
            result = true
        end
    end
    return result
end;
-- проверка на арену
camlo.arena = function()
    local isArena, isRegistered = IsActiveBattlefieldArena();
    if IsActiveBattlefieldArena(isArena) then
        return true;
    end
    return false;
end;
--- проверка на бг
camlo.battleground = function()
    local position = UnitInBattleground("player")
    if UnitInBattleground("player") then
        return true;
    end;
    return false
end;
--- Получение ренжи без проверки ресурсов, используется там где не подходит ni.spell.valid
camlo.getrange = function(t, id)
    if tonumber(id) == nil then
        id = ni.spell.id(id)
    end
    if ni.player.isfacing(t)
        and ni.player.los(t)
        and IsSpellInRange(GetSpellInfo(id), t) == 1 then
        return true;
    end
    return false;
end;
camlo.valid = function(t1, t2)
    local openworld = 0x10 + 0x100000;
    local battleground = 0x10 + 0x100000 + 0x1;
    if not camlo.arena()
        and ni.unit.los(t1, t2, openworld) then
        return true;
    end
    if camlo.arena()
        and ni.unit.los(t1, t2, battleground) then
        return true;
    end;
    return false;
end;
camlo.sirusserver = function()
    local realm_names = {"Scourge", "Legacy", "Sirus", "Algalon", "ОБТ"};
    local realm = GetRealmName();
    local result = false;
    for i = 1, #realm_names do
        local name = realm_names[i];
        if strfind(realm, name) then
            result = true;
        end
    end
    return result
end;
return camlo;

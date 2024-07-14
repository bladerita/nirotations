local select, GetSpellInfo, ipairs, pairs, GetZoneText, GetInstanceInfo, GetTime, tonumber, IsUsableSpell, IsSpellKnown, IsSpellInRange, UnitExists, UnitCanAttack, GetTotemInfo, wipe, IsMounted, UnitInVehicle, UnitIsDeadOrGhost, UnitChannelInfo, UnitCastingInfo, IsCurrentSpell, GetWeaponEnchantInfo, GetInventoryItemID, BindEnchant, GetItemInfo, IsEquippedItemType, GetItemSpell, GetActionInfo, GetTotemTimeLeft, UnitName, UnitIsEnemy = select, GetSpellInfo, ipairs, pairs, GetZoneText, GetInstanceInfo, GetTime, tonumber, IsUsableSpell, IsSpellKnown, IsSpellInRange, UnitExists, UnitCanAttack, GetTotemInfo, wipe, IsMounted, UnitInVehicle, UnitIsDeadOrGhost, UnitChannelInfo, UnitCastingInfo, IsCurrentSpell, GetWeaponEnchantInfo, GetInventoryItemID, BindEnchant, GetItemInfo, IsEquippedItemType, GetItemSpell, GetActionInfo, GetTotemTimeLeft, UnitName, UnitIsEnemy
local spellCast, spellValid, spellInstant, playerHP, playerPow, playerBuff, playerBuffSta, playerDistance, playerSlot, playerInventory, playerItemR, playerUseIt, unitDebuff, unitDebuffRem, unitBuffType, unitEnemiesRange, unitDistance, unitBoss, drTrack = ni.spell.cast, ni.spell.valid, ni.spell.isinstant, ni.player.hp, ni.player.power, ni.player.buff, ni.player.buffstacks, ni.player.distance, ni.player.slotusable, ni.player.useinventoryitem, ni.player.itemready, ni.player.useitem, ni.unit.debuff, ni.unit.debuffremaining, ni.unit.bufftype, ni.unit.enemiesinrange, ni.unit.distance, ni.unit.isboss, ni.drtracker.get;
local camlo = ni.utils.require("Camlo") or ni.utils.require("Camlo.enc");
local enemies = {};
local lowesenemies = {};
local BombTargets = {};
local firsttime = true;
local wotlk = ni.vars.build == 30300 or false;
if wotlk and camlo then
    local targets = {};
    local items = {
        settingsfile = "WorldPvP_Fire.json",
        {type = "title", text = "World PvP Fire by |cff00ccffCamlo"},
        {type = "separator"},
        {type = "entry", text = ni.spell.icon(2139, 22, 22) .. "Антимагия", enabled = true, key = "autointerrupt", y = 45},
        {type = "separator"},
        {type = "entry", text = ni.spell.icon(55362, 22, 22) .. "Живая бомба (игроки)", enabled = true, key = "LivingBombPlayer", y = 75},
        {type = "entry", text = ni.spell.icon(55362, 22, 22) .. "Живая бомба (питомцы)", enabled = true, key = "LivingBombPet", y = 105},
        {type = "separator"},
        {type = "entry", text = ni.spell.icon(12523, 22, 22) .. "Огненая глыба", enabled = true, key = "pyroblast", y = 140},
        {type = "separator"},
        {type = "entry", text = ni.player.itemicon(5512, 22, 22) .. "Камень здоровья", enabled = true, value = 45, min = 25, max = 65, step = 1, width = 40, key = "healthstoneuse", y = 175},
        {type = "entry", text = ni.spell.icon(45438, 22, 22) .. "Глыба", enabled = true, value = 35, min = 25, max = 100, step = 1, width = 40, key = "gl", y = 200},
        {type = "separator"},
        {type = "entry", text = ni.spell.icon(42985, 22, 22) .. "Кристалл маны", tooltip = "Использовать кристалл маны если |cff0082FFMP|r < %.", enabled = true, value = 25, min = 15, max = 65, step = 1, width = 40, key = "managemuse", y = 235},
    };
    -- Get Setting from GUI --
    local function GetSetting(name)
        for k, v in ipairs(items) do
            if v.type == "entry"
                and v.key ~= nil
                and v.key == name then
                return v.value, v.enabled;
            end
            if v.type == "dropdown"
                and v.key ~= nil
                and v.key == name then
                for k2, v2 in pairs(v.menu) do
                    if v2.selected then
                        return v2.value;
                    end
                end
            end
            if v.type == "input"
                and v.key ~= nil
                and v.key == name then
                return v.value;
            end
        end
    end;
    local LastReset = 0;
    local spells = {
        Antimagic = GetSpellInfo(2139);
        Pyroblast = GetSpellInfo(12523);
        LivingBomb = GetSpellInfo(55362);
        ManaGem = GetSpellInfo(42985);

    };
    local cache = {
        IsMoving = false,
        PlayerCombat = false,
        UnitAttackable = false,
        PlayerControled = false,
        ActiveEnemies = 0,
    };
    local function OnLoad()
        ni.GUI.AddFrame("WorldPvP_Fire", items);
    end;
    -- Unload GUI / Wipe Cache --
    local function OnUnLoad()
        ni.GUI.DestroyFrame("WorldPvP_Fire");
    end;
    local queue = {
        "Cache",
        "Test",
        "Mirror",
        "Blink",
        "Universal Pause",
        "Healthstone (Use)",
        "ManaGem (Use)",
        "Gl",
        "Antimagic (Interrupt)",
        "Pyro Blast",
        "Living Bomb (Player)",
        "Living Bomb (Pet)",

    };
    local abilities = {
        ["Cache"] = function()
            cache.IsMoving = ni.player.ismoving() or false;
            cache.PlayerCombat = ni.player.incombat() or false;
            cache.UnitAttackable = (UnitExists("target") and UnitCanAttack("player", "target")) or false;
            cache.PlayerControled = (ni.player.isstunned() or ni.player.isconfused() or ni.player.isfleeing()) or false;
            cache.ActiveEnemies = #unitEnemiesRange("player", 8) or 0;
            if cache.PlayerCombat
                and (GetTime() - LastReset >= 15) then
                wipe(enemies);
                wipe(lowesenemies)
                wipe(BombTargets)
                LastReset = GetTime();
            end
            SLASH_bl1 = "/bl"
            SlashCmdList.bl = function()
            if ni.spell.cd(1953) == 0 then
                bl = true;
            end
        end
            SLASH_mirror1 = "/mirror"
            SlashCmdList.mirror = function()
            if ni.spell.cd(55342) == 0 then
                mirror = true;
            end
            end
        end;
        ["Mirror"] = function()
            if cache.PlayerControled then
                return false;
            end
            if mirror then
                if camlo.spellusablesilence(55342) then
                    spellCast(55342)
                    mirror = false;
                    return true;
                end
            end
        end,
        ["Blink"] = function()
            if cache.PlayerControled or not camlo.spellusablesilence(1953) then
                return false;
            end
            if bl then
                spellCast(1953)
                bl = false;
                return true;
            end
        end,
        ["Universal Pause"] = function()
            if IsMounted()
                or UnitInVehicle("player")
                or UnitIsDeadOrGhost("player")
                or UnitChannelInfo("player")
                or UnitCastingInfo("player")
                or ni.player.islooting() then
                return true;
            end
            ni.vars.debug = select(2, GetSetting("Debug"));
        end,
        ["Antimagic (Interrupt)"] = function()
            local _, enabled = GetSetting("autointerrupt");
            if not enabled then
                return false;
            end
            local asd = 0x10 + 0x100000;
            local css = 0x10 + 0x100000 + 0x1;
            local noninterrupt = {
                14295, 58434, 42650
            };
            if camlo.spellusablesilence(spells.Antimagic) then
                local AntimagicRange = select(9, GetSpellInfo(spells.Antimagic));
                local enemies = ni.player.enemiesinrange(AntimagicRange);
                for i = 1, #enemies do
                    local InterruptTargets = enemies[i].guid;
                    for i, v in ipairs(noninterrupt) do
                        if not camlo.arena() then
                            if (((UnitCastingInfo(InterruptTargets) == GetSpellInfo(v)) or (UnitChannelInfo(InterruptTargets) == GetSpellInfo(v)))
                            or (ni.unit.buff(InterruptTargets, 42650) or ni.unit.buff(InterruptTargets, 642) or ni.unit.buff(InterruptTargets, 31821))) then
                            return false;
                        end
                        if ni.unit.isplayer(InterruptTargets)
                            and (ni.unit.iscasting(InterruptTargets) or ni.unit.ischanneling(InterruptTargets))
                            and ni.unit.los("player", InterruptTargets, asd)
                            and (ni.unit.castingpercent(InterruptTargets) >= 25 or ni.unit.channelpercent(InterruptTargets) >= 30) then
                            spellCast(spells.Antimagic, InterruptTargets)
                            return true;
                        end
                    end
                end
                if camlo.arena() then
                    if (((UnitCastingInfo(InterruptTargets) == GetSpellInfo(v)) or (UnitChannelInfo(InterruptTargets) == GetSpellInfo(v)))
                    or (ni.unit.buff(InterruptTargets, 42650) or ni.unit.buff(InterruptTargets, 642) or ni.unit.buff(InterruptTargets, 31821))) then
                    return false;
                end
                if ni.unit.isplayer(InterruptTargets)
                    and (not ni.unit.buff(InterruptTargets, 42650) or not ni.unit.buff(InterruptTargets, 642) or not ni.unit.buff(InterruptTargets, 31821))
                    and (ni.unit.iscasting(InterruptTargets) or ni.unit.ischanneling(InterruptTargets))
                    and ni.unit.los("player", InterruptTargets, css)
                    and (ni.unit.castingpercent(InterruptTargets) >= 25 or ni.unit.channelpercent(InterruptTargets) >= 30) then
                    spellCast(spells.Antimagic, InterruptTargets)
                    return true;
                end
            end
        end
    end
end,
["Healthstone (Use)"] = function()
    local value, enabled = GetSetting("healthstoneuse");
    local hstones = {36894, 36893, 36892, 36891, 36890, 36889, 22105, 22104, 22103, 19013, 19012, 9421, 19011, 19010, 5510, 19009, 19008, 5509, 19007, 19006, 5511, 19005, 19004, 5512}
    if enabled
        and ni.player.hp() < value
        and not ni.player.debuff(30843)
        and UnitAffectingCombat("player") then
        for i = 1, #hstones do
            if ni.player.hasitem(hstones[i])
                and ni.player.itemcd(hstones[i]) == 0 then
                ni.player.useitem(hstones[i])
            end
        end
    end
end,
["ManaGem (Use)"] = function()
    local mpVal, enabled = GetSetting("managemuse");
    if not enabled then
        return false;
    end
    if ni.player.power() <= mpVal
        and ni.player.itemcd(33312) == 0
        and ni.player.hasitem(33312) then
        ni.player.useitem(33312)
        return true;
    end
end,
["Gl"] = function()
    local hpval, enabled = GetSetting("gl")
    if not enabled then
        return false;
    end
    if ni.player.hp() <= hpval
        and camlo.spellusablesilence(45438) then
        ni.spell.cast(45438)
    end
end,
["Pyro Blast"] = function()
    local _, enabled = GetSetting("pyroblast")
    if not enabled then
        return false;
    end
    if camlo.spellusablesilence(spells.Pyroblast) then
        local asd = 0x10 + 0x100000;
        local css = 0x10 + 0x100000 + 0x1;
        local enemies = ni.player.enemiesinrange(41);

        -- Удалите мертвые цели из таблицы
        for i = #lowesenemies, 1, -1 do
            if UnitIsDeadOrGhost(lowesenemies[i].lowes) then
                table.remove(lowesenemies, i)
            end
        end

        -- Обновите таблицу с текущими целями
        for i = 1, #enemies do
            local PyroTargets = enemies[i].guid;

            if (ni.unit.hp(PyroTargets) <= 100 and not UnitIsDeadOrGhost(PyroTargets))
                and ni.unit.los("player", PyroTargets, asd)
                and ni.player.buff(44448)
                and not camlo.arena()
                and ni.unit.isplayer(PyroTargets)
                and not ni.unit.buffs(PyroTargets, "48707||23920||19263||31224||45438||642||33786||48514||65544||59725")
                and not ni.unit.debuff(PyroTargets, 33786)
                and ni.unit.isfacing("player", PyroTargets) then
                local found = false
                for j = 1, #lowesenemies do
                    if lowesenemies[j].lowes == PyroTargets then
                        found = true
                        lowesenemies[j].health = ni.unit.hp(PyroTargets)
                        break
                    end
                end
                if not found then
                    table.insert(lowesenemies, {lowes = PyroTargets, health = ni.unit.hp(PyroTargets)})
                end
            end
        end
        table.sort(lowesenemies, function(a, b) return a.health < b.health end)

        for i, targetInfo in ipairs(lowesenemies) do
            if ni.player.buff(44448) then
                ni.spell.cast(spells.Pyroblast, targetInfo.lowes)
                return true;
            end
        end
        local enemies = ni.player.enemiesinrange(41);

        for i = #lowesenemies, 1, -1 do
            if UnitIsDeadOrGhost(lowesenemies[i].lowes) then
                table.remove(lowesenemies, i)
            end
        end

        for i = 1, #enemies do
            local PyroTargets = enemies[i].guid;

            if (ni.unit.hp(PyroTargets) <= 100 and not UnitIsDeadOrGhost(PyroTargets))
                and ni.unit.los("player", PyroTargets, css)
                and ni.player.buff(44448)
                and camlo.arena()
                and ni.unit.isplayer(PyroTargets)
                and not ni.unit.buffs(PyroTargets, "48707||23920||19263||31224||45438||642||33786||48514||65544||59725")
                and not ni.unit.debuff(PyroTargets, 33786)
                and ni.unit.isfacing("player", PyroTargets) then
                local found = false
                for j = 1, #lowesenemies do
                    if lowesenemies[j].lowes == PyroTargets then
                        found = true
                        lowesenemies[j].health = ni.unit.hp(PyroTargets)
                        break
                    end
                end
                if not found then
                    table.insert(lowesenemies, {lowes = PyroTargets, health = ni.unit.hp(PyroTargets)})
                end
            end
        end
        table.sort(lowesenemies, function(a, b) return a.health < b.health end)
        for i, targetInfo in ipairs(lowesenemies) do
            if ni.player.buff(44448) then
                ni.spell.cast(spells.Pyroblast, targetInfo.lowes)
                return true;
            end
        end
    end
end,
["Living Bomb (Player)"] = function()
    local _, enabled = GetSetting("LivingBombPlayer");
    if not enabled then
        return false;
    end
    local asd = 0x10 + 0x100000;
    local css = 0x10 + 0x100000 + 0x1;
    local LivingBombRange = select(9, GetSpellInfo(spells.LivingBomb));
    local enemies = ni.player.enemiesinrange(LivingBombRange)
    for i = 1, #enemies do
        local BombTargets = enemies[i].guid;
        if not ni.unit.debuff(BombTargets, spells.LivingBomb, "player")
            and camlo.spellusablesilence(spells.LivingBomb)
            and not camlo.arena()
            and ni.unit.isplayer(BombTargets)
            and not ni.spell.gcd(spells.LivingBomb)
            and not ni.unit.buffs(BombTargets, "48707||23920||19263||31224||45438||642||33786||48514||59725")
            and not ni.unit.debuff(BombTargets, 33786)
            and ni.unit.los("player", BombTargets, asd) then
            spellCast(spells.LivingBomb, BombTargets)
            return true;
        end
        if not ni.unit.debuff(BombTargets, spells.LivingBomb, "player")
            and camlo.spellusablesilence(spells.LivingBomb)
            and ni.unit.isplayer(BombTargets)
            and camlo.arena()
            and not ni.spell.gcd(spells.LivingBomb)
            and not ni.unit.buffs(BombTargets, "48707||23920||19263||31224||45438||642||33786||48514||59725")
            and not ni.unit.debuff(BombTargets, 33786)
            and ni.unit.los("player", BombTargets, css) then
            spellCast(spells.LivingBomb, BombTargets)

        end
    end
end,
["Living Bomb (Pet)"] = function()
    local _, enabled = GetSetting("LivingBombPet")
    if not enabled then
        return false;
    end
    local asd = 0x10 + 0x100000;
    local css = 0x10 + 0x100000 + 0x1;
    local LivingBombRange = select(9, GetSpellInfo(spells.LivingBomb));
    local enemies = ni.player.enemiesinrange(LivingBombRange)
    for i = 1, #enemies do
        local BombTargets = enemies[i].guid;
        if ni.unit.isplayer(BombTargets) then
            local creations = ni.unit.creations(BombTargets);
            for i = 1, #creations do
                local pet = creations[i].guid
                local type = ni.unit.creaturetype(pet)
                if (type == 1 or type == 3 or type == 6) and ni.unit.id(pet) ~= 24207 then
                    if not ni.unit.debuff(pet, spells.LivingBomb, "player")
                        and not ni.unit.debuff(pet, 33786)
                        and not ni.spell.gcd(spells.LivingBomb)
                        and not camlo.arena()
                        and ni.unit.los("player", pet, asd) then
                        spellCast(spells.LivingBomb, pet)
                        return true;
                    end
                end
                if (type == 1 or type == 3 or type == 6) and ni.unit.id(pet) ~= 24207 then
                    if not ni.unit.debuff(pet, spells.LivingBomb, "player")
                        and not ni.unit.debuff(pet, 33786)
                        and not ni.spell.gcd(spells.LivingBomb)
                        and camlo.arena()
                        and ni.unit.los("player", pet, css) then
                        spellCast(spells.LivingBomb, pet)
                        return true;
                    end
                end
            end
        end
    end
end,
}
ni.bootstrap.profile("WorldPvP_Fire", queue, abilities, OnLoad, OnUnLoad);
else
local queue = {
    "Error",
};
local abilities = {
    ["Error"] = function()
        ni.vars.profiles.enabled = false;
        if not wotlk then
            ni.frames.floatingtext:message("This profile for WotLk!")
        end
    end,
};
ni.bootstrap.profile("WorldPvP_Fire", queue, abilities);
end;

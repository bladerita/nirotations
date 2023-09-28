local build = select(4, GetBuildInfo());
local wotlk = build == 30300 or false;
if wotlk then
	local spells = {
		corruption = { id = 47813, name = GetSpellInfo(47813), icon = select(3, GetSpellInfo(47813)) },
		curseofagony = { id = 47864, name = GetSpellInfo(47864), icon = select(3, GetSpellInfo(47864)) },
		drainlife = { id = 47857, name = GetSpellInfo(47857), icon = select(3, GetSpellInfo(47857)) },
		drainsoul = { id = 47855, name = GetSpellInfo(47855), icon = select(3, GetSpellInfo(47855)) },
		fear = { id = 6215, name = GetSpellInfo(6215), icon = select(3, GetSpellInfo(6215)) },
		haunt = { id = 59164, name = GetSpellInfo(59164), icon = select(3, GetSpellInfo(59164)) },
		lifetap = { id = 57946, name = GetSpellInfo(57946), icon = select(3, GetSpellInfo(57946)) },
		seed = { id = 47836, name = GetSpellInfo(47836), icon = select(3, GetSpellInfo(47836)) },
		soulstone = { id = 47884, name = GetSpellInfo(47884), icon = select(3, GetSpellInfo(47884)) },
		spellstone = { id = 47884, name = GetSpellInfo(47884), icon = select(3, GetSpellInfo(47884)) },
		summonfelhunter = { id = 47884, name = GetSpellInfo(47884), icon = select(3, GetSpellInfo(47884)) },
		soulshatter = { id = 29858, name = GetSpellInfo(29858), icon = select(3, GetSpellInfo(29858)) },
		felarmor = { id = 47893, name = GetSpellInfo(47893), icon = select(3, GetSpellInfo(47893)) },
		shadowflame = { id = 61290, name = GetSpellInfo(61290), icon = select(3, GetSpellInfo(61290)) },
		shadowbolt = { id = 47809, name = GetSpellInfo(47809), icon = select(3, GetSpellInfo(47809)) },
		createhealthstone = { id = 47878, name = GetSpellInfo(47878), icon = select(3, GetSpellInfo(47878)) },
		unstableaffliction = { id = 47843, name = GetSpellInfo(47843), icon = select(3, GetSpellInfo(47843)) },
		agony = { id = 47864, name = GetSpellInfo(47864), icon = select(3, GetSpellInfo(47864)) },
	}
	local queue = {
		"Cache",
		"Healthstone",
		"Usehealthstone",
		"Spellstone",
		"DemonicSoulstone",
		"Felarmor",
		"Pause",
		"Soulshatter",
		"lifetapbuff",
		"SeedAOE",
		"CorruptionAOE",
		"Haunt",
		"UnstableAffliction", -- Only one target
		-- "Doom",
		"Agony",
		"Corruption",
		"DrainSoul",
		"ShadowBolt",
		"Lifetap",
	}

	local enemies = {

	}


	local lastSpell, lastTarget = "", ""

	local function DoubleCast(spell, tar)
		if lastSpell == spell
				and lastTarget == UnitGUID(tar) then
			return true
		end
		return false
	end

	local function FacingLosCast(spell, tar)
		if ni.player.isfacing(tar, 145) and ni.player.los(tar) and IsSpellInRange(spell, tar) == 1 then
			ni.spell.cast(spell, tar)
			lastSpell = spell
			lastTarget = UnitGUID(tar)
			return true
		end
		return false
	end


	local function ValidUsable(id, tar)
		if ni.spell.available(id) and ni.spell.valid(tar, id, true, true) then
			return true
		end
		return false
	end
	local enemies = {}

	local function ActiveEnemies()
		table.wipe(enemies)
		enemies = ni.player.enemiesinrange(40)
		for k, v in ipairs(enemies) do
			if ni.player.threat(v.guid) == -1 then
				table.remove(enemies, k)
			end
		end
		return #enemies
	end
	local cache = {
		targets = nil,
		moving = ni.player.ismoving(),
		curchannel = nil,
		iscasting = nil
	}
	local _targetTTD = 0
	local t, p = "target", "player"
	local abilities = {
		["Cache"] = function()
			cache.moving = ni.player.ismoving()
			cache.curchannel = UnitChannelInfo(p)
			cache.iscasting = UnitCastingInfo(p)
			cache.targets = ni.unit.enemiesinrange(p, 40)
			ActiveEnemies()
		end,
		["Healthstone"] = function()
			if not ni.player.hasitem(36892)
					and not UnitAffectingCombat(p)
			then
				ni.spell.cast(spells.createhealthstone.id)
				print("Healthstone")
			end
		end,
		["Usehealthstone"] = function()
			if ni.player.hasitem(36892)
					and UnitAffectingCombat(p)
					and ni.player.hp() < 20
			then
				ni.player.useitem(36892)
			end
		end,
		-- ["Spellstone"] = function()
		-- 	if	 ni.player.hasitem(41993)
		-- 	and not UnitAffectingCombat(p)
		-- 	then
		-- end,
		["DemonicSoulstone"] = function()
			if not ni.player.hasitem(36895)
					and not UnitAffectingCombat(p)
			then
				ni.spell.cast(spells.soulstone.id)
			end
		end,
		["Felarmor"] = function()
			if ni.player.buffremaining(47893) < 3
			then
				ni.spell.cast(spells.felarmor.id)
			end
		end,
		["Pause"] = function()
			if IsMounted()
					or UnitIsDeadOrGhost(p)
					or not UnitExists(t)
					and not UnitAffectingCombat(p)
					or UnitIsDeadOrGhost(t)
					or (UnitExists(t) and not UnitCanAttack(p, t))
			then
				return true
			end
			if UnitChannelInfo(p) == spells.drainsoul.name
			then
				return true
			end
		end,

		["Soulshatter"] = function()
			if ni.spell.available(spells.soulshatter.id)
					and ni.unit.isboss(t)
					and (UnitGUID(p) == UnitGUID("playertargettarget"))
			then
				ni.spell.cast(spells.soulshatter.id)
			end
		end,

		["lifetapbuff"] = function()
			if ni.spell.available(spells.lifetap.id)
					and ni.player.buffremaining(63321) < 3
			then
				ni.spell.cast(spells.lifetap.id)
			end
		end,
		["SeedAOE"] = function()
			if ni.vars.combat.aoe then
				if #cache.targets > 3
						and not cache.moving then
					for i = 1, #cache.targets do
						local target = cache.targets[i]
						-- if ni.player.threat(target.guid) ~= -1 then
						if not DoubleCast(spells.seed.name, target.name)
								and ni.spell.available(spells.seed.id)
								and not ni.unit.debuff(target.guid, spells.seed.id, p)
						then
							FacingLosCast(spells.seed.name, target.guid)
							-- print(spells.seed.name .. " " .. target.name)
						end
					end
				end
			end
		end,
		["CorruptionAOE"] = function()
			if ni.vars.combat.aoe then
				if #cache.targets > 1
						and #cache.targets < 4 then
					for i = 1, #cache.targets do
						local target = cache.targets[i]
						-- if ni.player.threat(target.guid) ~= -1 then
						if not DoubleCast(spells.corruption.name, target.name)
								and ni.spell.available(spells.corruption.id)
								and not ni.unit.debuff(target.guid, spells.corruption.id, p)
						then
							FacingLosCast(spells.corruption.name, target.guid)
							-- print(spells.seed.name .. " " .. target.name)
						end
					end
				end
			end
		end,
		["UnstableAffliction"] = function()
			if not cache.moving
					and ni.spell.available(spells.unstableaffliction.id)
					and not ni.spell.lastcast(spells.unstableaffliction.id)
					and ni.unit.debuffremaining(t, spells.unstableaffliction.id, p) < 1
					and not DoubleCast(spells.unstableaffliction.name, t)
			then
				FacingLosCast(spells.unstableaffliction.name, t)
			end
		end,
		["Haunt"] = function()
			if not cache.moving
					-- and ni.spell.available(spells.haunt.id)
					-- and not ni.spell.lastcast(spells.haunt.id, 3)
					and ni.spell.cd(spells.haunt.id) == 0
					and ni.unit.debuffremaining(t, spells.haunt.id, p) < 1
			-- and not DoubleCast(spells.haunt.name, t)
			then
				FacingLosCast(spells.haunt.name, t)
			end
		end,
		["Agony"] = function()
			if ni.spell.available(spells.agony.id)
					and not ni.unit.debuff(t, spells.agony.id, p)
					and not DoubleCast(spells.agony.name, t)
			then
				FacingLosCast(spells.agony.name, t)
			end
		end,
		["Corruption"] = function()
			if not ni.unit.debuff(t, spells.corruption.id, p)
			then
				FacingLosCast(spells.corruption.name, t)
			end
		end,

		["ShadowBolt"] = function()
			if not cache.moving
					and ni.spell.available(spells.shadowbolt.id)
					and (ni.unit.debuffremaining(t, spells.haunt.id, p) > 1
						or ni.spell.lastcast(spells.haunt.id))
					and (ni.unit.debuffremaining(t, spells.unstableaffliction.id, p) > 1
						or ni.spell.lastcast(spells.unstableaffliction.id))
			then
				FacingLosCast(spells.shadowbolt.name, t)
			end
		end,
		["Lifetap"] = function()
			if ni.player.power() < 7
					and ni.player.hp() > 20
			then
				ni.spell.cast(spells.lifetap.id)
			else
				if ni.player.power() < 90
						and cache.moving
				then
					ni.spell.cast(spells.lifetap.id)
				end
			end
		end

	}
	ni.bootstrap.profile("Dalvae Affli - Wrath", queue, abilities, onload, onunload)
end

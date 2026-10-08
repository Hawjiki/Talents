local AIO = AIO or require("AIO")

local enableItem = false
local itemRequired = 4540
local amountRequired = 1
local IsNpc = false
local npcEntry = 50252
-- Keep this equal to the client setting.
local SPEC_TALENTS_PER_ROW = 5

local talentHandler = AIO.AddHandlers("TALENT_SERVER", {})
local TalentCache = { tabs = {}, talents = {}, allowed = {} }

local function LoadTalentConfig()
    TalentCache.tabs = {}
    TalentCache.talents = {}
    TalentCache.allowed = {}

    local tabResult = WorldDBQuery("SELECT class_id, tab_id, name, tp, max_active_spells, icon, background FROM felskorn_talent_tabs WHERE enabled=1 ORDER BY class_id, tab_id")
    if tabResult then
        repeat
            local classId = tabResult:GetUInt32(0)
            local tabId = tabResult:GetUInt32(1)
            TalentCache.tabs[classId] = TalentCache.tabs[classId] or {}
            TalentCache.tabs[classId][tabId] = { id = tabId, name = tabResult:GetString(2), TP = tabResult:GetUInt32(3), maxActiveSpells = tabResult:GetUInt32(4), icon = tabResult:GetString(5), background = tabResult:GetString(6) }
        until not tabResult:NextRow()
    end

    local talentResult = WorldDBQuery("SELECT class_id, tab_id, spell_id, item_type, row_pos, column_pos, talent_type, required_spell_1, required_spell_2, required_spell_3, node_style, node_height FROM felskorn_talents WHERE enabled=1 ORDER BY class_id, tab_id, row_pos, column_pos, spell_id")
    if talentResult then
        repeat
            local classId = talentResult:GetUInt32(0)
            local tabId = talentResult:GetUInt32(1)
            local spellId = talentResult:GetUInt32(2)
            local itemType = talentResult:GetString(3)
            TalentCache.talents[classId] = TalentCache.talents[classId] or {}
            TalentCache.talents[classId][tabId] = TalentCache.talents[classId][tabId] or {}
            table.insert(TalentCache.talents[classId][tabId], { id = spellId, itemType = itemType, row = talentResult:GetUInt32(4), column = talentResult:GetUInt32(5), TT = talentResult:GetString(6), RSp1 = talentResult:GetUInt32(7), RSp2 = talentResult:GetUInt32(8), RSp3 = talentResult:GetUInt32(9), NSx = talentResult:GetUInt32(10), NHx = talentResult:GetUInt32(11) })
            TalentCache.allowed[classId] = TalentCache.allowed[classId] or {}
            TalentCache.allowed[classId][spellId] = itemType
        until not talentResult:NextRow()
    end

    local rankResult = WorldDBQuery("SELECT class_id, tab_id, talent_spell_id, rank_no, spell_id FROM felskorn_talent_ranks ORDER BY class_id, tab_id, talent_spell_id, rank_no")
    if rankResult then
        repeat
            local classId, tabId, root = rankResult:GetUInt32(0), rankResult:GetUInt32(1), rankResult:GetUInt32(2)
            local rank, spellId = rankResult:GetUInt32(3), rankResult:GetUInt32(4)
            for _, talent in ipairs((TalentCache.talents[classId] or {})[tabId] or {}) do
                if talent.id == root and talent.TT == "spec" and talent.itemType == "spell" then
                    talent.ranks = talent.ranks or {}
                    talent.ranks[rank] = spellId
                end
            end
        until not rankResult:NextRow()
    end

    -- Glyph tab appearance and enabled state come from felskorn_talent_tabs.
    -- Keep its database name as "Glyphs" so it can be identified.
    local glyphTabs = {}
    for classId, tabs in pairs(TalentCache.tabs) do
        for tabId, tab in pairs(tabs) do
            if tab.name == "Glyphs" then
                glyphTabs[classId] = tabId
                TalentCache.talents[classId] = TalentCache.talents[classId] or {}
                TalentCache.talents[classId][tabId] = TalentCache.talents[classId][tabId] or {}
                break
            end
        end
    end
    local glyphResult = WorldDBQuery("SELECT class_id, spell_id, talent_type, required_item, row_pos, column_pos, visual_style FROM felskorn_talents_glyphs WHERE enabled=1 ORDER BY class_id, talent_type, row_pos, column_pos")
    if glyphResult then
        repeat
            local classId = glyphResult:GetUInt32(0)
            local tabId = glyphTabs[classId]
            if tabId then
                local kind = glyphResult:GetString(2)
                if kind == "glyph_major" or kind == "glyph_minor" then
                    table.insert(TalentCache.talents[classId][tabId], {
                        id=glyphResult:GetUInt32(1), itemType="spell", TT=kind,
                        visualStyle=glyphResult:GetString(6), requiredItem=glyphResult:GetUInt32(3), row=glyphResult:GetUInt32(4),
                        column=glyphResult:GetUInt32(5), RSp1=0, RSp2=0, RSp3=0, NSx=0, NHx=0})
                end
            end
        until not glyphResult:NextRow()
    end

    local tabCount = 0
    local talentCount = 0
    for _, classTabs in pairs(TalentCache.tabs) do for _ in pairs(classTabs) do tabCount = tabCount + 1 end end
    for _, classTalents in pairs(TalentCache.talents) do for _, tabTalents in pairs(classTalents) do talentCount = talentCount + #tabTalents end end
    print("[FelskornTalents] Loaded " .. tabCount .. " tabs and " .. talentCount .. " talents from the world database.")
end

local EnsureBuild, SendBuildState, EnforcePointLimits, SendPointLimits, PointBudgets

local function SendTalentConfig(player)
    if not EnsureBuild(player) then return end
    EnforcePointLimits(player)
    SendBuildState(player)
    SendPointLimits(player)
    local classId = player:GetClass()
    AIO.Handle(player, "TALENT_CLIENT", "ReceiveConfig", TalentCache.tabs[classId] or {}, TalentCache.talents[classId] or {})
end

local function IsConfiguredTalent(player, spellId, itemType)
    local classTalents = TalentCache.allowed[player:GetClass()]
    if not classTalents then return false end
    return classTalents[tonumber(spellId) or 0] == itemType
end

local function IsTalentBlockedByCombat(player)
    return player:IsInCombat()
end

local function hasRequiredItem(player)
    if not enableItem then return true end
    return player:HasItem(itemRequired, amountRequired)
end

local function consumeRequiredItem(player)
    if enableItem then player:RemoveItem(itemRequired, amountRequired) end
end

function talentHandler.RequestConfig(player)
    SendTalentConfig(player)
end

function talentHandler.talentualHasIt(player, spellId)
    spellId = tonumber(spellId) or 0
    if not IsConfiguredTalent(player, spellId, "spell") then return end
    if player:HasSpell(spellId) then AIO.Handle(player, "TALENT_CLIENT", "returntrue", spellId) end
end

local function RankOf(player, talent, overrideTalent, overrideRank)
    if talent == overrideTalent then return overrideRank end
    if talent.ranks then
        for rank = #talent.ranks, 1, -1 do
            if player:HasSpell(talent.ranks[rank]) then return rank end
        end
        return 0
    end
    if talent.itemType == "item" then return player:HasItem(talent.id) and 1 or 0 end
    return player:HasSpell(talent.id) and 1 or 0
end

local function SpecAllowed(player, tab, talent, overrideTalent, overrideRank)
    local spent = 0
    local parent = talent.RSp1 + talent.RSp2 + talent.RSp3 == 0
    for _, other in ipairs(tab) do
        local rank = RankOf(player, other, overrideTalent, overrideRank)
        if other.TT == "spec" and other.row < talent.row then spent = spent + rank end
        for _, required in ipairs({talent.RSp1, talent.RSp2, talent.RSp3}) do
            if required > 0 then
                if other.id == required and rank > 0 then parent = true end
                for index, spell in ipairs(other.ranks or {}) do
                    if required == spell and rank >= index then parent = true end
                end
            end
        end
    end
    return parent and spent >= math.max(0, talent.row - 1) * SPEC_TALENTS_PER_ROW
end

function talentHandler.ChangeRank(player, tabId, rootId, direction)
    tabId, rootId, direction = tonumber(tabId), tonumber(rootId), tonumber(direction)
    if direction ~= 1 and direction ~= -1 then return false end
    if IsTalentBlockedByCombat(player) then return false end
    local tabs = TalentCache.talents[player:GetClass()] or {}
    local tab = tabs[tabId] or {}
    local target
    for _, talent in ipairs(tab) do if talent.id == rootId and talent.TT == "spec" and talent.ranks then target = talent end end
    if not target then return false end
    local current = RankOf(player, target)
    local nextRank = current + direction
    if nextRank < 0 or nextRank > #target.ranks then return false end
    if direction == 1 then
        local budget = PointBudgets(player).spec
        local spent = 0
        for _, tree in pairs(tabs) do
            for _, talent in ipairs(tree) do if talent.TT == "spec" then spent = spent + RankOf(player, talent) end end
        end
        if spent >= budget or not SpecAllowed(player, tab, target) then return false end
    else
        if not hasRequiredItem(player) then return false end
        for _, talent in ipairs(tab) do
            if talent.TT == "spec" and RankOf(player, talent, target, nextRank) > 0 and
               not SpecAllowed(player, tab, talent, target, nextRank) then
                player:SendBroadcastMessage("Remove dependent talents before refunding this rank.")
                return false
            end
        end
    end
    -- Remove the old rank before learning its replacement to avoid stacking bonuses.
    for index = #target.ranks, 1, -1 do
        if player:HasSpell(target.ranks[index]) then player:RemoveSpell(target.ranks[index]) end
    end
    if nextRank > 0 then player:LearnSpell(target.ranks[nextRank]) end
    if direction == -1 then consumeRequiredItem(player) end
    player:SaveToDB()
end

local function IsRankedRoot(player, spellId)
    for _, tab in pairs(TalentCache.talents[player:GetClass()] or {}) do
        for _, talent in ipairs(tab) do
            if talent.id == spellId and talent.ranks then return true end
        end
    end
    return false
end

local function FindGlyph(player, spellId)
    for _, tab in pairs(TalentCache.talents[player:GetClass()] or {}) do
        for _, talent in ipairs(tab) do
            if talent.id == spellId and (talent.TT == "glyph_major" or talent.TT == "glyph_minor") then return talent end
        end
    end
end

function talentHandler.ToggleGlyph(player, spellId, activate)
    spellId = tonumber(spellId) or 0
    if activate ~= true and activate ~= false then return false end
    local glyph = FindGlyph(player, spellId)
    if not glyph or IsTalentBlockedByCombat(player) then return false end
    if activate then
        if player:HasSpell(spellId) then return false end
        if glyph.requiredItem == 0 or not player:HasItem(glyph.requiredItem, 1) then
            player:SendBroadcastMessage("You need the required glyph item in your inventory.")
            return false
        end
        local count, counted = 0, {}
        for _, tab in pairs(TalentCache.talents[player:GetClass()] or {}) do
            for _, other in ipairs(tab) do
                if other.TT == glyph.TT and not counted[other.id] then
                    counted[other.id] = true
                    if player:HasSpell(other.id) then count = count + 1 end
                end
            end
        end
        if count >= PointBudgets(player)[glyph.TT] then
            player:SendBroadcastMessage("You have reached the glyph point limit for this type.")
            return false
        end
        player:LearnSpell(spellId)
        player:CastSpell(player, spellId, true)
    else
        player:RemoveAura(spellId)
        player:RemoveSpell(spellId)
    end
    player:SaveToDB()
end

function talentHandler.talentualActivate(player, spellId, itemType)
    spellId = tonumber(spellId) or 0
    itemType = tostring(itemType or "")
    if IsRankedRoot(player, spellId) then return false end
    if IsTalentBlockedByCombat(player) then
        player:SendBroadcastMessage("|cff00ff00[World]|r |cffff0000You can't use talentual while in combat!")
        return false
    end
    if not IsConfiguredTalent(player, spellId, itemType) then
        player:SendBroadcastMessage("|cff00ff00[World]|r |cffff0000Invalid talent.")
        return false
    end
    if itemType == "spell" then
        if player:HasSpell(spellId) then
            player:SendBroadcastMessage("|cff00ff00[World]|r |cffff0000You already have this talentual!")
            return false
        end
        player:LearnSpell(spellId)
    elseif itemType == "item" then
        if player:HasItem(spellId) then
            player:SendBroadcastMessage("|cff00ff00[World]|r |cffff0000You already have this talentual item!")
            return false
        end
        player:AddItem(spellId, 1)
    else
        return false
    end
    player:SaveToDB()
end

function talentHandler.talentualDeactivate(player, spellId, itemType)
    spellId = tonumber(spellId) or 0
    itemType = tostring(itemType or "")
    if IsRankedRoot(player, spellId) then return false end
    if IsTalentBlockedByCombat(player) then
        player:SendBroadcastMessage("|cff00ff00[World]|r |cffff0000You can't use talentual while in combat!")
        return false
    end
    if not IsConfiguredTalent(player, spellId, itemType) then
        player:SendBroadcastMessage("|cff00ff00[World]|r |cffff0000Invalid talent.")
        return false
    end
    if not hasRequiredItem(player) then
        player:SendBroadcastMessage("|cff00ff00[World]|r |cffff0000You don't have |cff00ff00" .. GetItemLink(itemRequired) .. "|cffff0000 in your inventory!")
        return false
    end
    if itemType == "spell" then player:RemoveSpell(spellId) elseif itemType == "item" then player:RemoveItem(spellId, 1) end
    consumeRequiredItem(player)
    player:SaveToDB()
end

function talentHandler.unLearnAllTalentuals(player, spellId, itemType)
    spellId = tonumber(spellId) or 0
    itemType = tostring(itemType or "")
    if IsRankedRoot(player, spellId) then return false end
    if IsTalentBlockedByCombat(player) then
        player:SendBroadcastMessage("|cff00ff00[World]|r |cffff0000You can't use talentual while in combat!")
        return false
    end
    if not IsConfiguredTalent(player, spellId, itemType) then return false end
    if not hasRequiredItem(player) then
        player:SendBroadcastMessage("|cff00ff00[World]|r |cffff0000You don't have |cff00ff00" .. GetItemLink(itemRequired) .. "|cffff0000 in your inventory!")
        return false
    end
    if itemType == "spell" then
        player:RemoveSpell(spellId)
    elseif itemType == "item" then
        player:RemoveItem(spellId, 1)
        player:SendBroadcastMessage("|cff00ff00[World]|r |cffff0000You removed " .. GetItemLink(spellId) .. "|cffff0000.")
    end
    consumeRequiredItem(player)
    player:SaveToDB()
end


-- Two custom builds. This does not use Blizzard's native dual-spec slots.
local BuildCache = {}
local function ConfiguredSpells(player)
    local spells = {}
    for _, tab in pairs(TalentCache.talents[player:GetClass()] or {}) do
        for _, talent in ipairs(tab) do
            if talent.itemType == "spell" then
                if talent.ranks then
                    for _, spell in ipairs(talent.ranks) do spells[spell] = talent end
                else
                    spells[talent.id] = talent
                end
            end
        end
    end
    return spells
end

local function SnapshotBuild(player, previous)
    local spells = {}
    -- Preserve stored selections even if their config has since been disabled.
    for spell in pairs(previous or {}) do
        if player:HasSpell(spell) then spells[spell] = true end
    end
    for _, tab in pairs(TalentCache.talents[player:GetClass()] or {}) do
        for _, talent in ipairs(tab) do
            if talent.itemType == "spell" then
                if talent.ranks then
                    for _, spell in ipairs(talent.ranks) do spells[spell] = nil end
                    for rank = #talent.ranks, 1, -1 do
                        local spell = talent.ranks[rank]
                        if player:HasSpell(spell) then spells[spell] = true; break end
                    end
                elseif player:HasSpell(talent.id) then spells[talent.id] = true end
            end
        end
    end
    return spells
end

local function SaveBuild(player, state)
    local guid = player:GetGUIDLow()
    state.builds[state.active] = SnapshotBuild(player, state.builds[state.active])
    local statements = {string.format("DELETE FROM felskorn_talent_build_spells WHERE guid=%u AND build_id=%u", guid, state.active)}
    for spell in pairs(state.builds[state.active]) do
        statements[#statements + 1] = string.format("INSERT INTO felskorn_talent_build_spells (guid,build_id,spell_id) VALUES (%u,%u,%u)", guid, state.active, spell)
    end
    -- Character DB statements are queued in order; each edit also saves the player.
    for _, statement in ipairs(statements) do CharDBExecute(statement) end
end

EnsureBuild = function(player)
    local guid = player:GetGUIDLow()
    if BuildCache[guid] then return BuildCache[guid] end
    if not CharDBQuery("SELECT COUNT(*) FROM felskorn_talent_builds") or
       not CharDBQuery("SELECT COUNT(*) FROM felskorn_talent_build_spells") then
        player:SendBroadcastMessage("[Felskorn Talents] Install talent_builds.sql in the characters database first.")
        return nil
    end
    local result = CharDBQuery(string.format("SELECT active_build FROM felskorn_talent_builds WHERE guid=%u", guid))
    local state = {active = result and result:GetUInt32(0) or 1, revision = 1, builds = {{}, {}}}
    if state.active ~= 1 and state.active ~= 2 then state.active = 1 end
    if result then
        local rows = CharDBQuery(string.format("SELECT build_id,spell_id FROM felskorn_talent_build_spells WHERE guid=%u", guid))
        if rows then repeat
            local build, spell = rows:GetUInt32(0), rows:GetUInt32(1)
            if state.builds[build] then state.builds[build][spell] = true end
        until not rows:NextRow() end
    else
        CharDBExecute(string.format("INSERT INTO felskorn_talent_builds (guid,active_build) VALUES (%u,1)", guid))
        SaveBuild(player, state) -- Import existing selections into Main exactly once.
    end
    BuildCache[guid] = state
    return state
end

SendBuildState = function(player)
    local state = EnsureBuild(player)
    if state then AIO.Handle(player, "TALENT_CLIENT", "BuildState", state.active, state.revision) end
end

function talentHandler.SwitchBuild(player, build, revision)
    local state = EnsureBuild(player)
    build = tonumber(build)
    if not state or tonumber(revision) ~= state.revision or (build ~= 1 and build ~= 2) or build == state.active then return false end
    if player:IsInCombat() or player:IsDead() then
        player:SendBroadcastMessage("[Felskorn Talents] You cannot switch builds while in combat or dead.")
        SendBuildState(player)
        return false
    end
    -- Item rewards cannot be safely withdrawn/recreated as build selections.
    for _, tab in pairs(TalentCache.talents[player:GetClass()] or {}) do
        for _, talent in ipairs(tab) do
            if talent.itemType == "item" then
                player:SendBroadcastMessage("[Felskorn Talents] Build switching requires spell talents; this class has item talents configured.")
                SendBuildState(player)
                return false
            end
        end
    end
    EnforcePointLimits(player)
    SaveBuild(player, state)
    local outgoing = state.builds[state.active]
    local configured = ConfiguredSpells(player)
    local remove = {}
    for spell in pairs(outgoing) do
        remove[spell] = true
        local talent = configured[spell]
        if talent and talent.ranks then
            for _, rankSpell in ipairs(talent.ranks) do remove[rankSpell] = true end
        end
    end
    for spell in pairs(remove) do
        player:RemoveAura(spell)
        player:RemoveSpell(spell)
    end
    state.active = build
    state.revision = state.revision + 1
    for spell in pairs(state.builds[build]) do
        player:LearnSpell(spell)
        local talent = configured[spell]
        if talent and (talent.TT == "glyph_major" or talent.TT == "glyph_minor") then
            player:CastSpell(player, spell, true)
        end
    end
    player:SaveToDB()
    CharDBExecute(string.format("UPDATE felskorn_talent_builds SET active_build=%u WHERE guid=%u", build, player:GetGUIDLow()))
    EnforcePointLimits(player)
    SendBuildState(player)
    player:SendBroadcastMessage("[Felskorn Talents] " .. (build == 1 and "Main" or "Secondary") .. " build activated.")
end

-- Point budgets are server-owned. Values at level 60+ can be edited here.
local MAX_LEVEL_POINTS = {class=11, spec=71, heroic=15, glyph_major=3, glyph_minor=3}
PointBudgets = function(player)
    local level = player:GetLevel()
    if level >= 60 then return MAX_LEVEL_POINTS end
    return {
        class=level >= 10 and 1 + math.floor((level - 9) / 2) or 0,
        spec=level >= 11 and math.floor((level - 9) / 2) or 0,
        heroic=0, glyph_major=3, glyph_minor=3
    }
end
local function PointPool(talent)
    if talent.TT == "class" or talent.TT == "spec" or
       talent.TT == "glyph_major" or talent.TT == "glyph_minor" then return talent.TT end
    return "heroic"
end
local function AllPointTalents(player)
    local list, seen = {}, {}
    for tabId, tab in pairs(TalentCache.talents[player:GetClass()] or {}) do
        for _, talent in ipairs(tab) do
            local key = talent.itemType .. ":" .. talent.id
            if not seen[key] then
                seen[key] = true
                list[#list+1] = {talent=talent, tab=tab, tabId=tabId}
            end
        end
    end
    table.sort(list, function(a,b)
        if a.talent.row ~= b.talent.row then return a.talent.row < b.talent.row end
        if a.tabId ~= b.tabId then return a.tabId < b.tabId end
        return a.talent.id < b.talent.id
    end)
    return list
end
local function SpentPoints(player, pool)
    local spent = 0
    for _, entry in ipairs(AllPointTalents(player)) do
        if PointPool(entry.talent) == pool then spent = spent + RankOf(player, entry.talent) end
    end
    return spent
end
local function ParentAllowed(player, talent, tab)
    if talent.RSp1 + talent.RSp2 + talent.RSp3 == 0 then return true end
    for _, parent in ipairs(tab) do
        local rank = RankOf(player, parent)
        for _, required in ipairs({talent.RSp1,talent.RSp2,talent.RSp3}) do
            if required > 0 then
                if parent.id == required and rank > 0 then return true end
                for index, spell in ipairs(parent.ranks or {}) do
                    if spell == required and rank >= index then return true end
                end
            end
        end
    end
    return false
end
local function SetTalentRank(player, talent, rank)
    if talent.itemType == "item" then
        if rank == 0 then player:RemoveItem(talent.id,1) end
        return
    end
    for _, spell in ipairs(talent.ranks or {talent.id}) do
        player:RemoveAura(spell)
        player:RemoveSpell(spell)
    end
    if rank > 0 then player:LearnSpell(talent.ranks and talent.ranks[rank] or talent.id) end
end
SendPointLimits = function(player)
    AIO.Handle(player,"TALENT_CLIENT","PointLimits",PointBudgets(player))
end
EnforcePointLimits = function(player)
    local state = EnsureBuild(player)
    if not state then return end
    local limits, list, changed = PointBudgets(player), AllPointTalents(player), false
    for pool, limit in pairs(limits) do
        local excess = SpentPoints(player,pool) - limit
        for i = #list, 1, -1 do
            local talent = list[i].talent
            if excess > 0 and PointPool(talent) == pool then
                local rank = RankOf(player,talent)
                local removed = math.min(rank,excess)
                if removed > 0 then
                    SetTalentRank(player,talent,rank-removed)
                    excess, changed = excess-removed, true
                end
            end
        end
    end
    -- Cascading prerequisites may have been invalidated by trimming points.
    if changed then
        local again = true
        while again do
            again = false
            for _, entry in ipairs(list) do
                local talent, pool = entry.talent, PointPool(entry.talent)
                if RankOf(player,talent) > 0 and pool ~= "glyph_major" and pool ~= "glyph_minor" then
                    local valid = pool == "spec" and SpecAllowed(player,entry.tab,talent) or
                        (pool ~= "spec" and ParentAllowed(player,talent,entry.tab))
                    if not valid then SetTalentRank(player,talent,0); again = true end
                end
            end
        end
        player:SaveToDB()
        SaveBuild(player,state)
        player:SendBroadcastMessage("[Felskorn Talents] Your build exceeded its level point limits. Excess ranks and dependent talents were refunded.")
    end
    SendPointLimits(player)
end

-- Version every mutation so delayed clicks cannot edit the newly activated build.
for _, name in ipairs({"ChangeRank", "ToggleGlyph", "talentualActivate", "talentualDeactivate", "unLearnAllTalentuals"}) do
    local original = talentHandler[name]
    talentHandler[name] = function(player, a, b, c, revision)
        -- Two-argument actions send their revision in c; ChangeRank sends it last.
        local token = name == "ChangeRank" and revision or c
        local state = EnsureBuild(player)
        if not state or tonumber(token) ~= state.revision then return false end
        EnforcePointLimits(player)
        local buying = name == "talentualActivate" or (name == "ChangeRank" and tonumber(c) == 1) or
            (name == "ToggleGlyph" and b == true)
        if buying then
            local target, tree
            for tabId, tab in pairs(TalentCache.talents[player:GetClass()] or {}) do
                for _, talent in ipairs(tab) do
                    if (name == "ChangeRank" and tabId == tonumber(a) and talent.id == tonumber(b)) or
                       (name ~= "ChangeRank" and talent.id == tonumber(a) and
                        (name == "ToggleGlyph" or talent.itemType == b)) then target, tree = talent, tab end
                end
            end
            if not target then return false end
            local pool, limits = PointPool(target), PointBudgets(player)
            if SpentPoints(player,pool) >= limits[pool] then
                player:SendBroadcastMessage("[Felskorn Talents] No free " .. pool .. " points remain.")
                return false
            end
            if pool ~= "glyph_major" and pool ~= "glyph_minor" then
                if not ParentAllowed(player,target,tree) or (pool == "spec" and not SpecAllowed(player,tree,target)) then return false end
            end
        end
        local result = original(player, a, b, c)
        EnforcePointLimits(player)
        SaveBuild(player, state)
        return result
    end
end
RegisterPlayerEvent(3, function(event,player) EnforcePointLimits(player) end)
RegisterPlayerEvent(13, function(event,player) EnforcePointLimits(player) end)
RegisterPlayerEvent(4, function(event, player) BuildCache[player:GetGUIDLow()] = nil end)

if IsNpc then
    local CREATURE_EVENT_ON_MOVE_IN_LOS = 27
    local CREATURE_EVENT_ON_SPAWN = 5
    local GOSSIP_EVENT_ON_HELLO = 1
    local openWindows = {}

    local function creatureOnSpawn(event, creature)
        creature:SetNPCFlags(3)
    end

    local function creatureOnMoveInLos(event, creature, object)
        if object:GetObjectType() ~= "Player" then return end
        local guid = object:GetGUIDLow()
        if object:GetDistance(creature) < 2 then
            if object:IsMounted() then object:Dismount() end
            return false
        end
        if object:GetDistance(creature) > 2 and openWindows[guid] then
            AIO.Handle(object, "TALENT_CLIENT", "talentualCloseUI")
            openWindows[guid] = nil
        end
        return false
    end

    local function helloOnVendor(event, player, object)
        if IsTalentBlockedByCombat(player) then
            player:SendBroadcastMessage("|cff00ff00[World]|r |cffff0000You can't use talentual while in combat!")
            return false
        end
        AIO.Handle(player, "TALENT_CLIENT", "talentualOpenUI")
        openWindows[player:GetGUIDLow()] = true
    end

    RegisterCreatureEvent(npcEntry, CREATURE_EVENT_ON_MOVE_IN_LOS, creatureOnMoveInLos)
    RegisterCreatureEvent(npcEntry, CREATURE_EVENT_ON_SPAWN, creatureOnSpawn)
    RegisterCreatureGossipEvent(npcEntry, GOSSIP_EVENT_ON_HELLO, helloOnVendor)
end

local function OnCommand(event, player, command)
    if command == "rc" then
        AIO.Handle(player, "TALENT_CLIENT", "talentualOpenUI")
        return false
    end
    if command == "talents reload" then
        if player:GetGMRank() == 0 then
            player:SendBroadcastMessage("|cffff0000[Felskorn Talents]|r You do not have permission to use this command.")
            return false
        end
        LoadTalentConfig()
        player:SendBroadcastMessage("|cff00ff00[Felskorn Talents]|r Configuration reloaded from the world database.")
        SendTalentConfig(player)
        return false
    end
end

LoadTalentConfig()
RegisterPlayerEvent(42, OnCommand)

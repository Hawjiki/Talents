local AIO = AIO or require("AIO")
if AIO.AddAddon() then return end

local talentsremaining
local HeroTalentsRemaining
local ClassTalentsRemaining

local HeroTalentPoints = 0
local ClassTalentsPoints = 0
local serverPointLimits
local function updatetalentpoints()
    local level = UnitLevel("player")
    local limits = serverPointLimits or (level >= 60 and
        {class=11,spec=71,heroic=15,glyph_major=3,glyph_minor=3} or
        {class=level >= 10 and 1 + math.floor((level-9)/2) or 0,
         spec=level >= 11 and math.floor((level-9)/2) or 0,heroic=0,glyph_major=3,glyph_minor=3})
    ClassTalentsPoints, HeroTalentPoints = limits.class, limits.heroic
    return limits.spec
end

local isWorldIconOn = true
local isCOmmandsOn = true
local customTalentual = {
    talentualButtons = {},
    worldPortIcon = "achievement_dungeon_ulduar77_normal",
    tableCommands = {"/customtalentual", "/tc", "/talentualchange", "/talentualswitch", "/talents"},
    tabInfo = {},
    talentualSpells = {}
}

local function TalentRank(talent)
    if talent.TT == "spec" and talent.ranks then
        for rank = #talent.ranks, 1, -1 do
            if IsSpellKnown(talent.ranks[rank]) then return rank end
        end
        return 0
    end
    if talent.itemType == "item" then return GetItemCount(talent.id) > 0 and 1 or 0 end
    return IsSpellKnown(talent.id) and 1 or 0
end

local function GlyphPoints(kind)
    local used, counted = 0, {}
    for _, tab in pairs(customTalentual.talentualSpells) do
        for _, glyph in ipairs(tab) do
            if glyph.TT == kind and not counted[glyph.id] then
                counted[glyph.id] = true
                if IsSpellKnown(glyph.id) then used = used + 1 end
            end
        end
    end
    return math.max(0, (serverPointLimits and serverPointLimits[kind] or 3) - used)
end

-- Change this value to adjust the Specialization row requirement.
-- Each selected talent counts as one point: row 2 needs 5, row 3 needs 10, etc.
local SPEC_TALENTS_PER_ROW = 5

-- Class/Heroic use parent links; Specialization also requires earlier-row points.
function CheckRequisites(tabId, row, requiredT1, requiredT2, requiredT3, id, TT)
    if TT == "spec" then
        local requiredPoints = math.max(0, row - 1) * SPEC_TALENTS_PER_ROW
        local spentPoints = 0
        local counted = {}
        for _, talent in ipairs(customTalentual.talentualSpells[tabId] or {}) do
            if talent.TT == "spec" and talent.row < row and not counted[talent.id] then
                counted[talent.id] = true
                local selected
                if talent.itemType == "item" then
                    selected = GetItemCount(talent.id) > 0
                else
                    selected = IsSpellKnown(talent.id)
                end
                spentPoints = spentPoints + TalentRank(talent)
            end
        end
        if spentPoints < requiredPoints then return false end
    end

    if TT == "glyph_major" or TT == "glyph_minor" then return true end

    -- Root talents are available without a prerequisite.
    if requiredT1 + requiredT2 + requiredT3 == 0 then
        return true
    end

    -- Any one of the configured parents in this tab unlocks the talent.
    for _, talent in ipairs(customTalentual.talentualSpells[tabId] or {}) do
        if (requiredT1 > 0 and talent.id == requiredT1) or
           (requiredT2 > 0 and talent.id == requiredT2) or
           (requiredT3 > 0 and talent.id == requiredT3) then
            if talent.itemType == "item" then
                if GetItemCount(talent.id) > 0 then return true end
            elseif TalentRank(talent) > 0 then
                return true
            end
        end
    end
    return false
end

-- Define a handler function for the "TALENT_CLIENT" addon

local talentHandler = AIO.AddHandlers("TALENT_CLIENT", {})
function talentHandler.PointLimits(player,limits)
    serverPointLimits = limits
end
local activeBuild, buildRevision = 1, nil
local buildPauseUntil = 0
local buildButton
local function SendTalentAction(action, ...)
    if not buildRevision or GetTime() < buildPauseUntil then return end
    local args = {...}
    args[#args + 1] = buildRevision
    AIO.Handle("TALENT_SERVER", action, unpack(args))
end
function talentHandler.BuildState(player, active, revision)
    activeBuild, buildRevision = active, revision
    buildPauseUntil = GetTime() + 1
    if buildButton then
        buildButton:SetText(activeBuild == 1 and "Main (Active)" or "Secondary (Active)")
    end
end
local talentUIInitialized = false
local pendingOpen = false
local openWindow
local initializeTalentUI

local function requestTalentConfig()
    AIO.Handle("TALENT_SERVER", "RequestConfig")
end

function talentHandler.ReceiveConfig(player, tabs, talents)
    customTalentual.tabInfo = tabs or {}
    customTalentual.talentualSpells = talents or {}
    if talentUIInitialized then
        ReloadUI()
        return
    end
    if not next(customTalentual.tabInfo) then
        print("[Felskorn Talents] No enabled tabs received for your class. Check felskorn_talent_tabs.")
        return
    end
    local ok, err = pcall(initializeTalentUI)
    if not ok then
        print("[Felskorn Talents] UI initialization failed: " .. tostring(err))
        return
    end
    if pendingOpen and openWindow then
        pendingOpen = false
        openWindow()
    end
end

function talentHandler.talentualOpenUI()
    if openWindow then
        openWindow()
    else
        pendingOpen = true
        requestTalentConfig()
    end
end

function talentHandler.talentualCloseUI()
    local frame = _G["customTalentualFrame"]
    if frame and frame:IsShown() then
        PlaySound("igSpellBookClose")
        frame:Hide()
    end
end

ToggleTalentFrame = function()
    if openWindow then
        openWindow()
    else
        pendingOpen = true
        requestTalentConfig()
    end
end

initializeTalentUI = function()
    if talentUIInitialized then return end
    talentUIInitialized = true


--function talentHandler.returntrue(player, spellId)
--	returnboolean[spellId] = true
--end

local scaleMulti = 0.85
-- Helpers --

-- This function converts pixel coordinates to texture coordinates
-- size: the size of the texture
-- xTop, yTop: the top-left pixel coordinates of the region to be converted
-- xBottom, yBottom: the bottom-right pixel coordinates of the region to be converted
local function CoordsToTexCoords(size, xTop, yTop, xBottom, yBottom)
    -- Calculate the magic number
    local magic = (1 / size) / 2
    -- Calculate the top and left texture coordinates
    local Top = (yTop / size) + magic
    local Left = (xTop / size) + magic
    -- Calculate the bottom and right texture coordinates
    local Bottom = (yBottom / size) - magic
    local Right = (xBottom / size) - magic

    -- Return the texture coordinates
    return Left, Right, Top, Bottom
end

local function Clamp(value, min, max) -- clamp a value between a min and max might use later
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end




-------------------------------
-- [xXx]
-------------------------------

local itemTooltip = CreateFrame("GameTooltip", "CustomTalentualTooltip", UIParent,
    "GameTooltipTemplate")
itemTooltip:SetScale(1)
itemTooltip:SetClampedToScreen(true)
itemTooltip:SetFrameStrata("TOOLTIP")
itemTooltip:SetOwner(UIParent, "ANCHOR_NONE")
itemTooltip:Hide()

-- local mainFrame = CreateFrame("Frame", "customTalentualFrame", UIParent, "UIPanelDialogTemplate")
local mainFrame = CreateFrame("Frame", "customTalentualFrame", UIParent)
mainFrame:SetSize(800, 500)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame:SetBackdropColor(0, 0, 0, 1)
mainFrame:Hide()

--movable frame
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
mainFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)


-- Background texture
mainFrame.Background = mainFrame:CreateTexture(nil, "BACKGROUND")
mainFrame.Background:SetSize(mainFrame:GetSize())
mainFrame.Background:SetPoint("CENTER", mainFrame, "CENTER")
mainFrame.Background:SetTexture("Interface/Talentual_UI/StoreFrame_Main")
mainFrame.Background:SetTexCoord(CoordsToTexCoords(1024, 0, 0, 1024, 658))

-- Title--
mainFrame.Title = mainFrame:CreateFontString()
mainFrame.Title:SetFont("Fonts\\FRIZQT__.TTF", 14)
mainFrame.Title:SetShadowOffset(1, -1)
mainFrame.Title:SetPoint("TOP", mainFrame, "TOP", 0, -3)
-- mainFrame.Title:SetText("|cffedd100Custom Talentual UI|r")
--  blue text
mainFrame.Title:SetText("|cff00ccffClass Talents|r")

tinsert(UISpecialFrames, mainFrame:GetName()) -- allows frame to be closed with escape key

mainFrame.CloseButton = CreateFrame("Button", nil, mainFrame)
mainFrame.CloseButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -5, 0)
mainFrame.CloseButton:SetScript("OnClick", function() mainFrame:Hide() end)
mainFrame.CloseButton.texture = mainFrame.CloseButton:CreateTexture(nil,
    "BACKGROUND")
-- mainFrame.CloseButton.texture:SetTexture("Interface/Talentual_UI/TitanLogo")
mainFrame.CloseButton.texture:SetTexture("Interface/Talentual_UI/Transmogrify")
mainFrame.CloseButton.texture:SetTexCoord(CoordsToTexCoords(512, 485, 85, 511, 115))
mainFrame.CloseButton.texture:SetAllPoints(mainFrame.CloseButton)

-- One control displays the active build and toggles to the other build.
buildButton = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
buildButton:SetSize(178, 22)
buildButton:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 10, 26)
buildButton:SetText(activeBuild == 1 and "Main (Active)" or "Secondary (Active)")
buildButton:SetScript("OnClick", function()
    if buildRevision and GetTime() >= buildPauseUntil then
        buildPauseUntil = GetTime() + 1
        AIO.Handle("TALENT_SERVER", "SwitchBuild", activeBuild == 1 and 2 or 1, buildRevision)
    end
end)
buildButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Click to switch to " .. (activeBuild == 1 and "Secondary" or "Main"), 1, 1, 1)
    GameTooltip:Show()
end)
buildButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
mainFrame.CloseButton:SetSize(20, 20)
mainFrame.CloseButton:SetNormalTexture(mainFrame.CloseButton.texture)
-- set alpha to 0.5 when mouse is over button
mainFrame.CloseButton:SetScript("OnEnter",
    function(self) self.texture:SetAlpha(0.5) end)
-- set alpha to 1 when mouse leaves button
mainFrame.CloseButton:SetScript("OnLeave",
    function(self) self.texture:SetAlpha(1) end)


-------------------------------
-- [tab window for categories]
-------------------------------
local categoryList = CreateFrame("Frame", nil, mainFrame)
categoryList:SetSize(150, 300)
categoryList:SetPoint("TOPLEFT", 15, -35)

categoryList:SetBackdropColor(0, 0, 0, 0.8)

local itemList = CreateFrame("Frame", nil, mainFrame)
itemList:SetSize(600, 435)
itemList:SetPoint("TOPRIGHT", -15, -45)

itemList:SetBackdropColor(0, 0, 0, 0.8)

local scrollFrame = CreateFrame("ScrollFrame", "CustomTalentual_ScrollFrame",
    itemList, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", itemList, "TOPLEFT", 10, -10)
scrollFrame:SetPoint("BOTTOMRIGHT", itemList, "BOTTOMRIGHT", -30, 10)

itemList.scrollFrame = scrollFrame

local contentFrame = CreateFrame("Frame", "contentFrame", scrollFrame)

scrollFrame:SetScrollChild(contentFrame)

scrollFrame:EnableMouse(true)

itemList.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local currentValue =
        _G[itemList.scrollFrame:GetName() .. "ScrollBar"]:GetValue()
    local newValue = currentValue - (delta * 30)   -- Change '30' to adjust the scroll speed
    -- local contentHeight = itemList.contentFrame:GetHeight() -- Get the content height from itemList.contentFrame
    local contentHeight = contentFrame:GetHeight() -- Get the content height from itemList.contentFrame
    _G[itemList.scrollFrame:GetName() .. "ScrollBar"]:SetValue(math.min(
        math.max(
            newValue,
            0),
        math.max(0,
            contentHeight -
            itemList.scrollFrame:GetHeight())) -- Clamp(newValue, 0, math.max(0, contentHeight - itemList.scrollFrame:GetHeight()))
    )
end)

itemList.contentFrame = contentFrame

local tabButtonsScrollFrame = CreateFrame("ScrollFrame",
    "CustomShop_TabButtonsScrollFrame",
    categoryList)

tabButtonsScrollFrame:SetSize(200, 385)
tabButtonsScrollFrame:SetPoint("TOPLEFT", categoryList, "TOPRIGHT", -150, -30)

local tabButtonsContentFrame = CreateFrame("Frame", nil, tabButtonsScrollFrame)
tabButtonsScrollFrame:SetScrollChild(tabButtonsContentFrame)

local tabInfo = customTalentual.tabInfo
local contentHeightTab = #tabInfo * 35 -- assuming each tab button is 40 pixels high
tabButtonsContentFrame:SetSize(200, contentHeightTab)

local tabButtonsScrollBar = CreateFrame("Slider", nil, tabButtonsScrollFrame,
    "UIPanelScrollBarTemplate")
tabButtonsScrollBar:SetPoint("TOPLEFT", categoryList, "TOPRIGHT", 0, -40)
tabButtonsScrollBar:SetPoint("BOTTOMLEFT", categoryList, "BOTTOMRIGHT", 0, -100)
-- tabButtonsScrollBar:SetMinMaxValues(0, 0) calculate the length of the content frame and set the max value

-- local contentHeightTab = tabButtonsContentFrame:GetHeight() * 2
local contentHeightTab = tabButtonsContentFrame:GetHeight()
tabButtonsScrollBar:SetMinMaxValues(0, contentHeightTab)
tabButtonsScrollBar:SetValueStep(1)
tabButtonsScrollBar:SetValue(0)
tabButtonsScrollBar:SetWidth(16)
tabButtonsScrollFrame:EnableMouseWheel(true)

local function onScroll(self, delta)
    -- create a way to use mouse wheel to scroll the tab buttons frame
    local currentValue = tabButtonsScrollBar:GetValue()
    local newValue = currentValue - (delta * 30) -- Change '30' to adjust the scroll speed
    -- local contentHeightTab = tabButtonsContentFrame:GetHeight() -- Get the content height from itemList.contentFrame
    tabButtonsScrollBar:SetValue(math.min(math.max(newValue, 0),
        math.max(0, contentHeightTab)))
end

tabButtonsScrollBar:SetScript("OnValueChanged", function(self, value)
    tabButtonsScrollFrame:SetVerticalScroll(value)
end)

local function UpdateTabButtonsScrollBarVisibility()
    -- hide if if less then 15 tabinfo is active and show if more then 15 tabinfo is active
    if #customTalentual.tabInfo > 10 then
        tabButtonsScrollBar:Show()
        tabButtonsScrollFrame:SetScript("OnMouseWheel", onScroll)
    else
        tabButtonsScrollBar:Hide()
    end
end

UpdateTabButtonsScrollBarVisibility()


local function computetalentsintab(tabid)
local talentsintab = 0
    for k, v in pairs(customTalentual.talentualSpells) do
		if v == tabid then
			for numSpells, spell in pairs(v) do
				if TalentRank(spell) > 0 then
					talentsintab = talentsintab + 1
				end
			end
		end
	end
return talentsintab
end
-- Setups the tabs to the left side.
local function createTabButton(id, text, icon, TP, onClick, OnEnter, OnLeave, displayIndex)
--print(tostring(id)) 
 -- local button = CreateFrame("Button", nil, tabButtonsContentFrame, "UIPanelButtonTemplate")
    local button = CreateFrame("Button", nil, tabButtonsContentFrame)
    -- Main button
    local size = 175
    button:SetSize(size * scaleMulti, (size / 4) * scaleMulti)
    -- button:SetText(text)
    button:SetPoint("TOPLEFT", 0, -(displayIndex - 1) * 35)
    -- Set tab textures
    button:SetNormalTexture("Interface/Talentual_UI/StoreFrame_Main")
    button:SetHighlightTexture("Interface/Talentual_UI/StoreFrame_Main")
    button:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, 770, 900, 1024, 960))
    button:GetHighlightTexture():SetTexCoord(CoordsToTexCoords(1024, 770, 960, 1024, 1024))

    -- Set Category name
    button.Name = button:CreateFontString()
    button.Name:SetFont("Fonts\\FRIZQT__.TTF", 14)
    button.Name:SetShadowOffset(1, -1)
    button.Name:SetPoint("CENTER", button, "CENTER", 5, 0)
    button.Name:SetText(text)

	--Set TP spent
	button.TP = button:CreateFontString()
	button.TP:SetFont("Fonts\\FRIZQT__.TTF", 14)
    button.TP:SetShadowOffset(1, -1)
    button.TP:SetPoint("CENTER", button, "RIGHT", -15, 0)
    button.TP:SetText(TP)

    -- Set Icon
    button.Icon = button:CreateTexture(nil, "BACKGROUND")
    button.Icon:SetSize(31, 31)
    button.Icon:SetPoint("LEFT", button, "LEFT", 2, 0)
    button.Icon:SetTexture("Interface/Icons/" .. icon)

    -- if click tab then
    button:SetScript("OnClick", onClick)

    -- if mouse over tab
    button:SetScript("OnEnter", OnEnter)

    -- if mouse leave tab
    button:SetScript("OnLeave", OnLeave)

	button:SetScript("OnUpdate", function()
		TP = 0
		for k, v in pairs(customTalentual.talentualSpells) do
--		print(tostring(k))
--		print(tostring(id))
			if k == id then
				for numSpells, spell in pairs(v) do
--				if numSpells == id then
					if TalentRank(spell) > 0 then
						TP = TP + TalentRank(spell)
					end
				end
--				end
			end
		end
		button.TP:SetText(TP)
	end)

    return button
end

-- Create a text and numers to display active talentual spells
local selectedTalentTab = 1
local activeTalentualText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
activeTalentualText:SetPoint("TOPLEFT", 280, -30)
activeTalentualText:SetText("Unspent Specialization Talent Points: ")

local activeTalentualNumber = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
activeTalentualNumber:SetPoint("TOPLEFT", activeTalentualText, "TOPRIGHT", 0, 0)

local activeTalentualClassText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
activeTalentualClassText:SetPoint("TOPLEFT", 20, -30)
activeTalentualClassText:SetText("Unspent Class Talent Points: ")

local activeTalentualClassNumber = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
activeTalentualClassNumber:SetPoint("TOPLEFT", activeTalentualClassText, "TOPRIGHT", 0, 0)

local activeTalentualHeroText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
activeTalentualHeroText:SetPoint("TOPLEFT", 580, -30)
activeTalentualHeroText:SetText("Unspent Heroic Talent Points: ")

local activeTalentualHeroNumber = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
activeTalentualHeroNumber:SetPoint("TOPLEFT", activeTalentualHeroText, "TOPRIGHT", 0, 0)

--  show the text on how many is active.
local function activeTalentualSpells()
	talentsremaining = updatetalentpoints()
	HeroTalentsRemaining = HeroTalentPoints
	ClassTalentsRemaining = ClassTalentsPoints
    local count = 0
	local countHeroic = 0
	local countClass = 0
    for k, v in pairs(customTalentual.talentualSpells) do
        for numSpells, spell in pairs(v) do
            if TalentRank(spell) > 0 then
				if spell.TT == "spec" then
					count = count + TalentRank(spell)
				elseif spell.TT == "glyph_major" or spell.TT == "glyph_minor" then
                    -- Glyphs use their own budgets.
                elseif spell.TT == "class" then
					countClass = countClass +1
				else
					countHeroic = countHeroic + 1
				end
            end
        end
    end
	ClassTalentsRemaining = ClassTalentsRemaining -countClass
	talentsremaining = math.max(0, talentsremaining - count)
	HeroTalentsRemaining = math.max(0, HeroTalentsRemaining - countHeroic)
    activeTalentualNumber:SetText(talentsremaining)
	activeTalentualHeroNumber:SetText(HeroTalentsRemaining)
	activeTalentualClassNumber:SetText(ClassTalentsRemaining)
    local tab = customTalentual.tabInfo[selectedTalentTab]
    local isGlyphTab = tab and tab.name == "Glyphs"
    activeTalentualText:SetText(isGlyphTab and "Unspent Minor Glyph Points: " or "Unspent Specialization Talent Points: ")
    activeTalentualClassText:SetText(isGlyphTab and "Unspent Major Glyph Points: " or "Unspent Class Talent Points: ")
    activeTalentualHeroText:SetText(isGlyphTab and "" or "Unspent Heroic Talent Points: ")
    if isGlyphTab then
        activeTalentualNumber:SetText(GlyphPoints("glyph_minor"))
        activeTalentualClassNumber:SetText(GlyphPoints("glyph_major"))
        activeTalentualHeroNumber:SetText("")
    end

end


mainFrame:SetScript("OnUpdate", function()
    activeTalentualSpells()
end)




-- -- Button for the spells it create

local function createItemButtonTalent(parent, index, id, text, icon, onClick, itemType, row, column, requiredT1, requiredT2, requiredT3, catId, NSx, NHx, TT)--, costType, cost)
    -- isPassive = IsPassiveSpell(index, "bookType") or IsPassiveSpell("name")	
	local learnable = CheckRequisites(catId, row, requiredT1, requiredT2, requiredT3, id, TT)
    local talentInfo
    for _, candidate in ipairs(customTalentual.talentualSpells[catId] or {}) do
        if candidate.id == id then talentInfo = candidate; break end
    end
    local ranks = TT == "spec" and talentInfo and talentInfo.ranks
    local isGlyph = TT == "glyph_major" or TT == "glyph_minor"
    local visualType = isGlyph and (talentInfo.visualStyle or "Hero") or TT
    -- Circular node sizes: adjust frame/icon independently for each style.
    local keyStyles = {
        Key = { frame = 42, icon = 39 },
        KeyMinor = { frame = 36, icon = 34 }, --
    }
    local keyStyle = keyStyles[visualType]

    local button = CreateFrame("Button", nil, parent)
--    button:SetSize(120, 25)
if keyStyle then
	button:SetSize(keyStyle.frame, keyStyle.frame)
else
	button:SetSize(35, 35)
end
    local function CurrentRank() return talentInfo and TalentRank(talentInfo) or 0 end
    local function DisplaySpell()
        if ranks then return ranks[math.min(CurrentRank() + 1, #ranks)] end
        return id
    end
    button:EnableMouse(true)
	local isActive-- = isLearned(id)
    -- button:SetPoint("TOPLEFT", 0, -5 - (index - 1) * 35)
    local numColumns = 9
    local xIndex = (column - 1) % numColumns
--    local yIndex = math.floor((row - 1) / numColumns)
	local yIndex = row - 1

    local xOffset = xIndex * 65 - 5
    -- local xOffset = xIndex * 130
    local yOffset = -15 - yIndex * 65
if keyStyle then
	xOffset = xOffset - (keyStyle.frame - 35) / 2 - 1.5
	yOffset = yOffset + (keyStyle.frame - 35) / 2 - 0.5
end
    button:SetPoint("TOPLEFT", xOffset + 10, yOffset)
    -- cet so it goes left to right and then down

    local iconTexture = button:CreateTexture(nil, "ARTWORK")
if keyStyle then
    -- Anchor for the circular spell icon and its frame.
    iconTexture:SetSize(keyStyle.icon, keyStyle.icon)
else
    iconTexture:SetSize(34, 34)
end
    iconTexture:SetTexture(icon)
--	iconTexture:SetTexture("Interface/Talentual_UI/Icon_Paladin_Templar")
    if keyStyle then
        iconTexture:SetPoint("CENTER", button, "CENTER", 0, 0)
    else
        iconTexture:SetPoint("LEFT", 0, 0)
    end

    if keyStyle then
        -- WotLK-compatible circular clipping: draw narrow cropped strips.
        -- No opaque corner cover, so any tab background remains visible.
        iconTexture:SetAlpha(0)
        local diameter = keyStyle.icon
        local radius = diameter / 2
        local strips = 64
        local stripHeight = diameter / strips
        button.circularIconTextures = {}
        for strip = 1, strips do
            local top = -radius + (strip - 1) * stripHeight
            local bottom = top + stripHeight
            -- Use the edge farthest from the center to keep every corner inside.
            local edge = math.max(math.abs(top), math.abs(bottom))
            local halfWidth = math.sqrt(math.max(0, radius * radius - edge * edge))
            if halfWidth > 0 then
                local texture = button:CreateTexture(nil, "ARTWORK")
                texture:SetTexture(icon)
                texture:SetSize(halfWidth * 2, stripHeight)
                texture:SetPoint("TOPLEFT", button, "CENTER", -halfWidth, -top + 2)
                texture:SetTexCoord(0.5 - halfWidth / diameter, 0.5 + halfWidth / diameter,
                    (top + radius) / diameter, (bottom + radius) / diameter)
                table.insert(button.circularIconTextures, texture)
            end
        end
    end

    local costLabel = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    costLabel:SetText(cost)

    button:EnableMouse(true)

    -- -- Comment out the second OnEnter function
    button:SetScript("OnEnter", function(self)
        local success, result = pcall(function()
            itemTooltip:SetOwner(self, "ANCHOR_CURSOR")
            if itemType == "spell" then
                local spellName, _, spellIcon = GetSpellInfo(id)
                itemTooltip:SetHyperlink("spell:" .. DisplaySpell())
                if ranks then itemTooltip:AddLine("Rank " .. CurrentRank() .. "/" .. #ranks, 1, 1, 1) end
            else
                itemTooltip:SetText("Invalid item type: " .. tostring(itemType), 1,
                    1, 1, 1, true)
            end
            if isGlyph then
                local itemId = talentInfo.requiredItem
                itemTooltip:AddLine(TT == "glyph_major" and "Major Glyph" or "Minor Glyph", 1, 0.82, 0)
                itemTooltip:AddLine("Requires: " .. (GetItemInfo(itemId) or ("Item " .. itemId)), 1, 1, 1)
                itemTooltip:AddLine("Item is not consumed. Right click to deactivate.", 1, 1, 1)
            end
            if ranks and CurrentRank() < #ranks and learnable and (talentsremaining or 0) > 0 then
                itemTooltip:AddLine("Left click to learn the next rank", 1, 1, 1)
            end
            if ranks and CurrentRank() > 0 then
                itemTooltip:AddLine("Right click to refund one rank", 1, 1, 1)
            end
            if self.active then
                itemTooltip:AddLine("This spell is active", 0, 1, 0)
            else
                itemTooltip:AddLine("This spell is not active", 1, 0, 0)
				if learnable == true then
					itemTooltip:AddLine("Left click to learn", 1, 1, 1)
				end
            end
            itemTooltip:Show()
        end)
        if not success then
            print("Error: " .. result)
        end
    end)

    button:SetScript("OnLeave", function() itemTooltip:Hide() end)

    button:SetScript("OnMouseUp", function(self, button)
        if isGlyph then
            if tostring(button) == "LeftButton" and not IsSpellKnown(id) and
               GlyphPoints(TT) > 0 and GetItemCount(talentInfo.requiredItem) > 0 then
                SendTalentAction("ToggleGlyph", id, true)
            elseif tostring(button) == "RightButton" and IsSpellKnown(id) then
                SendTalentAction("ToggleGlyph", id, false)
            end
            self:GetScript("OnEnter")(self)
            return
        end
        if ranks then
            if tostring(button) == "LeftButton" and learnable and CurrentRank() < #ranks and (talentsremaining or 0) > 0 then
                SendTalentAction("ChangeRank", catId, id, 1)
            elseif tostring(button) == "RightButton" and CurrentRank() > 0 then
                SendTalentAction("ChangeRank", catId, id, -1)
            end
            self:GetScript("OnEnter")(self)
            return
        end
        -- Determine the category of the spell
		local categoryId = catId
        -- Initialize a variable to keep track of the maximum number of active spells
        local maxActive = 0
		if tostring(button) == "LeftButton" then
			if learnable == true then
				-- Check if the talentual spell is currently active
				if not self.active then
					-- Activate the talentual spell and set the active flag to true
					SendTalentAction("talentualActivate", id, itemType)
					self.active = true
					-- Add the spell ID to the customTalentual.activeTalentualSpells table
					--table.insert(customTalentual.activeTalentualSpells, id)
				end
			end
		elseif tostring(button) == "RightButton" then
			if self.active then
					-- Deactivate the current talentual spell and set the active flag to false
				SendTalentAction("talentualDeactivate", id, itemType)
				self.active = false
			end

		end
		self:GetScript("OnEnter")(self)
    end)

    button:SetScript("OnMouseDown", function(self, button)
        if IsShiftKeyDown() then
            local spellName = GetSpellInfo(ranks and ranks[math.max(1, CurrentRank())] or id)
            PickupSpell(spellName)
		self:GetScript("OnEnter")(self)
		end
    end)

    button:SetScript("OnUpdate", function(self, elapsed, ...)
		self.active = false
		isActive = talentInfo and TalentRank(talentInfo) > 0 or IsSpellKnown(id)

		learnable = CheckRequisites(catId, row, requiredT1, requiredT2, requiredT3, id, TT)
        self.active = isActive
        if ranks and (CurrentRank() >= #ranks or (talentsremaining or 0) <= 0) then learnable = false end
		if not ranks and not isGlyph and self.active == true and learnable == false then
		    SendTalentAction("talentualDeactivate", id, itemType)
            self.active = false
		elseif self.active == false and learnable == true then
if TT == "spec" then
			if (talentsremaining or 0) <= 0 then
				learnable = false
			end
elseif TT == "class"	then
			if ClassTalentsRemaining == 0 then
				learnable = false
			end
else
			if HeroTalentsRemaining == 0 then
				learnable = false
			end
end
		end
        if isGlyph then
            learnable = GlyphPoints(TT) > 0 and GetItemCount(talentInfo.requiredItem) > 0
        end
		if self.active == true then
			self:SetAlpha(1)
		elseif learnable == true then
			self:SetAlpha(1)
		else
			self:SetAlpha(0.75)
		end
--        self:SetAlpha(isActive and 1 or 0.5)
--		if NSx > 0 then
			local startX = 0
			local startY = 0
			local height = 0
			local width = 	0
			local widthH = 0
			local horX = 0
			local horY = 0
			if NSx > 0 then
				startX = 10
				startY = 15
				height = 84
				width = 210
			end	
			if NHx > 0 then
				horX = 179
				horY = 168
				height = 84
				widthH = 210				
			end
			if NHx == 2 then
				horY = horY + 84
			elseif NHx == 3 then
				horY = horY + 168
			end			
			if NSx == 2 then
				startY = startY +((NSx - 1) * height)			
			elseif NSx == 3 then
				startY = startY +((NSx - 1) * height)
			elseif NSx == 4 then
				startY = startY +((NSx - 1) * height)
			elseif NSx == 5 then
				startY = startY +((NSx - 1) * height)
			elseif NSx == 6 then
				startY = startY +((NSx - 1) * height)
			elseif NSx == 7 then
				startX = 175
			end
			if not self.background then
					self.background = self:CreateTexture(nil, "BACKGROUND")
					self.background:SetTexture("Interface/Talentual_UI/TalentArrows")
					self.background:SetTexCoord(CoordsToTexCoords(512, startX , startY, startX + width+15, startY + height-5))
					self.background:SetWidth(169)
					self.background:SetHeight(55)
					self.background:SetPoint("CENTER", iconTexture, "CENTER",13, -25)
					
					self.background2 = self:CreateTexture(nil, "BACKGROUND")
					self.background2:SetTexture("Interface/Talentual_UI/TalentArrows")
					self.background2:SetTexCoord(CoordsToTexCoords(512, horX , horY, horX + widthH+25, horY + 84))
					self.background2:SetWidth(169)
					self.background2:SetHeight(55)
					self.background2:SetPoint("CENTER", iconTexture, "CENTER", -13, -16)
			else
				if isActive then
					self.background:SetDesaturated(false)
					self.background:SetTexCoord(CoordsToTexCoords(512, startX , startY, startX + width+15, startY + height-5))
					self.background2:SetDesaturated(false)
					self.background2:SetTexCoord(CoordsToTexCoords(512, horX , horY, horX + widthH+25, horY + 84))					
				else
					self.background:SetDesaturated(true)
					self.background:SetTexCoord(CoordsToTexCoords(512, startX , startY, startX + width+15, startY + height-5))	
					self.background2:SetDesaturated(true)
					self.background2:SetTexCoord(CoordsToTexCoords(512, horX , horY, horX + widthH+25, horY + 84))					
				end
			end
			if keyStyle then
				if isActive and not self.overlay then
					self:SetAlpha(1)
					self.overlay = self:CreateTexture(nil, "OVERLAY")
					self.overlay:SetTexture("Interface/Talentual_UI/RoundOverlayGreen")
					self.overlay:SetWidth(keyStyle.frame)
					self.overlay:SetHeight(keyStyle.frame)
					self.overlay:SetPoint("CENTER", iconTexture, "CENTER", 0, 0)
					self.overlay:SetDesaturated(false)				
				elseif not isActive and not self.overlay then
					self:SetAlpha(0.75)
					self.overlay = self:CreateTexture(nil, "OVERLAY")
					self.overlay:SetTexture("Interface/Talentual_UI/RoundOverlayRed")
					self.overlay:SetWidth(keyStyle.frame)
					self.overlay:SetHeight(keyStyle.frame)
					self.overlay:SetPoint("CENTER", iconTexture, "CENTER", 0, 0)
					self.overlay:SetDesaturated(false)					
				elseif isActive then	
					self.overlay:SetTexture("Interface/Talentual_UI/RoundOverlayGreen")	
					self.overlay:SetDesaturated(false)
					self:SetAlpha(1)
				else
					if learnable == true then
						self.overlay:SetTexture("Interface/Talentual_UI/RoundOverlayGold")
						self.overlay:SetDesaturated(false)
						self:SetAlpha(1)
					else
						self.overlay:SetTexture("Interface/Talentual_UI/RoundOverlayRed")
						self:SetAlpha(0.75)
						self.overlay:SetDesaturated(true)
					end
				end
			else
				if isActive and not self.overlay then
					self.overlay = self:CreateTexture(nil, "OVERLAY")
					self.overlay:SetTexture("Interface/Talentual_UI/DressingRoom")
					self.overlay:SetTexCoord(CoordsToTexCoords(512, 358, 42, 399, 84))
					self.overlay:SetWidth(32)
					self.overlay:SetHeight(32)
					self.overlay:SetPoint("CENTER", iconTexture, "CENTER", 0, 0)
					self.overlay:SetDesaturated(false)
				elseif not isActive and not self.overlay then
					self.overlay = self:CreateTexture(nil, "OVERLAY")
					self.overlay:SetTexture("Interface/Talentual_UI/DressingRoom")
					self.overlay:SetTexCoord(CoordsToTexCoords(512, 441, 0, 483, 42))
					self.overlay:SetWidth(32)
					self.overlay:SetHeight(32)
					self.overlay:SetPoint("CENTER", iconTexture, "CENTER", 0, 0)
					if TT == "spec" then
						if (talentsremaining or 0) <= 0 then
							self.overlay:SetDesaturated(true)
						end
					elseif TT == "class" then
						if ClassTalentsRemaining == 0 then
							self.overlay:SetDesaturated(true)
						end						
					else 
						if HeroTalentsRemaining == 0 then
							self.overlay:SetDesaturated(true)
						end
					end
				elseif isActive then
					self.overlay:SetTexture("Interface/Talentual_UI/DressingRoom")
					self.overlay:SetTexCoord(CoordsToTexCoords(512, 358, 42, 399, 84))
					self.overlay:SetDesaturated(false)
				else
					if learnable == true then
						self.overlay:SetTexture("Interface/Talentual_UI/DressingRoom")
						self.overlay:SetTexCoord(CoordsToTexCoords(512, 399, 84, 441, 126))
						self.overlay:SetDesaturated(false)
					else
						self.overlay:SetTexture("Interface/Talentual_UI/DressingRoom")
						self.overlay:SetTexCoord(CoordsToTexCoords(512, 441, 0, 483, 42))
						self.overlay:SetDesaturated(false)
						if TT == "spec" then
							if (talentsremaining or 0) <= 0 then
								self.overlay:SetDesaturated(true)
							end
						elseif TT == "class" then
							if ClassTalentsRemaining == 0 then
								self.overlay:SetDesaturated(true)
							end						
						else 
							if HeroTalentsRemaining == 0 then
								self.overlay:SetDesaturated(true)
							end
						end
					end
				end
			end
		
    end)

	button:SetAttribute("itemType", itemType)

    table.insert(customTalentual.talentualButtons, button)

    button.costLabel = costLabel
    return button, costLabel
end

-- adds all the talentual spells to the list
local function populateList(categoryId)
    local tab = customTalentual.tabInfo[categoryId]
    if not tab then return end
    selectedTalentTab = categoryId
    if tab.background and tab.background ~= "" then
        mainFrame.Background:SetTexture(tab.background)
    end
    local fakeName = {} -- This is a workaround for the GetItemInfo() function
    -- Reset the scrollbar position
    itemList.scrollFrame:SetVerticalScroll(0)
    -- Calculate the required height of the contentFrame based on the number of items
    local items = customTalentual.talentualSpells[categoryId] or {}
    local contentHeight2 = math.ceil(#items / 2)
    itemList.contentFrame:SetSize(itemList.scrollFrame:GetWidth(),
        contentHeight2)
    -- Update the contentFrame's height
    -- Update the scrollbar's values based on the content frame's height
    local slider = _G[itemList.scrollFrame:GetName() .. "ScrollBar"]
    slider:SetMinMaxValues(0, math.max(0, contentHeight2 -
        itemList.scrollFrame:GetHeight()))
    slider:SetValue(0)
    -- mousewheel scrolling
    itemList.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = slider:GetValue()
        local min, max = slider:GetMinMaxValues()
        if delta < 0 then
            if current < max then slider:SetValue(current + 35) end
        else
            if current > min then slider:SetValue(current - 35) end
        end
    end)
    -- Show the scrollbar only if the contentHeight is greater than the scrollFrame's height
    if contentHeight2 > itemList.scrollFrame:GetHeight() then
        slider:Show()
    else
        slider:Hide()
    end

    -- Remove existing item buttons
    for _, child in ipairs({ itemList.contentFrame:GetChildren() }) do
        child:Hide()
    end
    -- Create new item buttons
    if items then
        for i, item in ipairs(items) do
            local icon, fakeName
            if item.itemType == "spell" then
                icon = select(3, GetSpellInfo(item.id))
                fakeName = GetSpellInfo(item.id) or "Unknown Spell"
            end
			local button = createItemButtonTalent(itemList.contentFrame, i, item.id, fakeName, icon, ItemButton_OnClick,item.itemType, item.row, item.column, item.RSp1, item.RSp2, item.RSp3, categoryId, item.NSx, item.NHx, item.TT)--, item.CostType, item.cost)
            table.insert(customTalentual.talentualButtons, button)
        end
    end
end


-- load first tab
local orderedTabIds = {}
for tabId in pairs(customTalentual.tabInfo) do table.insert(orderedTabIds, tabId) end
table.sort(orderedTabIds)
if orderedTabIds[1] then populateList(orderedTabIds[1]) end

local tabButtons = {}
local function TabButton_OnClick(self)
    local tabID = self:GetID()

    --    if there is no item in tab then return
    if not customTalentual.talentualSpells[tabID] then
        return print("No items in tabID: " .. tabID)
    end



    -- :UnlockHighlight()
    -- :LockHighlight()

    -- Deactivate all tab buttons
    for i = 1, #tabButtons do tabButtons[i]:UnlockHighlight() end

    -- Activate the clicked tab button
    self:LockHighlight()

    -- Handle tab click, e.g., fetch items from server or update UI
    populateList(tabID)
end

local function TabButton_OnEnter(self)
    -- Handle mouse entering the tab button
    local tabID = self:GetID()


    local text = customTalentual.tabInfo[tabID].name --.. " tab"

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(text, 1, 1, 1)
    GameTooltip:Show()
end

local function TabButton_OnLeave(self)
    -- Handle mouse leaving the tab button
    -- print("TabButton_OnLeave")
    GameTooltip:Hide()
end

for displayIndex, tabId in ipairs(orderedTabIds) do
    local tab = customTalentual.tabInfo[tabId]
    local button = createTabButton(tab.id, tab.name, tab.icon, tab.TP, TabButton_OnClick, TabButton_OnEnter, TabButton_OnLeave, displayIndex)
    button:SetID(tab.id)
    table.insert(tabButtons, button)
end




-- function to open the window
openWindow = function()
    if mainFrame:IsShown() then
        mainFrame:Hide()
        PlaySound("igSpellBookClose")
    else
        mainFrame:Show()
        PlaySound("igSpellBookOpen")
    end
end


-- handle the /commands
if isCOmmandsOn then
    -- add slash commands
    for i, command in ipairs(customTalentual.tableCommands) do
        _G["SLASH_CUSTOMTALENTUAL" .. i] = command
    end

    SlashCmdList["CUSTOMTALENTUAL"] = function() openWindow() end
end

-- World Port Icon
if isWorldIconOn then
    -- add icon on worldframe for easy access
    local icon = CreateFrame("Button", nil, WorldFrame)
    icon:SetSize(32, 32)
    icon:SetPoint("BOTTOMLEFT", WorldFrame, "BOTTOMLEFT", 0, 0)

    -- icon:SetNormalTexture("Interface\\Icons\\wowtoken")
    -- set a talentual icon
    icon:SetNormalTexture("Interface/Icons/" .. customTalentual.worldPortIcon)
    -- icon:SetHighlightTexture("Interface/Icons/" .. customTalentual.worldPortIcon)
    -- icon:SetPushedTexture("Interface/Icons/" .. customTalentual.worldPortIcon)

    SetPortraitToTexture(icon:GetNormalTexture(),
        "Interface/Icons/" .. customTalentual.worldPortIcon)
    icon:SetAlpha(1)
    local tex = icon:CreateFontString(nil, "OVERLAY")
    tex:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    tex:SetPoint("CENTER", icon, "BOTTOM", 0, -5)
    tex:SetText("Talents")
    icon:SetFrameStrata("HIGH")
    icon:SetClampedToScreen(true)
    icon:SetScript("OnClick", function(self, button, down) openWindow() end)
    icon:SetScript("OnEnter", function(self)
        icon:SetAlpha(1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click to open the Talent Tab")
        GameTooltip:Show()
    end)
    icon:SetScript("OnLeave", function(self)
        icon:SetAlpha(1)
        GameTooltip:Hide()
    end)
    -- drag able
    icon:SetMovable(true)
    icon:EnableMouse(true)
    icon:RegisterForDrag("LeftButton")
    icon:SetScript("OnDragStart", function(self) self:StartMoving() end)
    icon:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    if not icon:IsVisible() then
        icon:ClearAllPoints()
        icon:SetPoint("BOTTOMLEFT", WorldFrame, "BOTTOMLEFT", 0, 0)
    end
end

-- Function to unlearn spells and clear the active state
local function resetSpells()
    for tabIndex, spellList in ipairs(customTalentual.talentualSpells) do
        for _, spellInfo in ipairs(spellList) do
--            IsTotalMaxActive()
--            customTalentual.activeTalentualSpells = {}
            -- check if "spell is known". If spell itemType "item" then check if item is in bag
            if spellInfo.itemType == "spell" then
                if IsSpellKnown(spellInfo.id) then
                    SendTalentAction("unLearnAllTalentuals", spellInfo.id, spellInfo.itemType)
                end
            end

            -- if IsSpellKnown(spellInfo.id) then
            -- Unlearn the spell (assuming you have a function to unlearn spells, replace with the actual function)

            -- Clear the active state for the button associated with this spell
            local button = customTalentual.talentualButtons[tabIndex][spellInfo.id]
            if button then
                button.active = false
                button:SetAlpha(0.5)
                if button.overlay then
                    button.overlay:Hide()
                end
                -- end
            end
        end
    end
end
-- Create the reset button
--local resetButton = CreateFrame("Button", nil, mainFrame,
 --   "UIPanelButtonTemplate")
--resetButton:SetSize(175, 20)
--resetButton:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 10, 26)

--resetButton:SetNormalTexture("Interface/Talentual_UI/StoreFrame_Main")
--resetButton:SetHighlightTexture("Interface/Talentual_UI/StoreFrame_Main")
--resetButton:SetPushedTexture("Interface/Talentual_UI/StoreFrame_Main")
--resetButton:GetNormalTexture():SetTexCoord(
--    CoordsToTexCoords(1024, 709, 849, 837, 873))
--resetButton:GetHighlightTexture():SetTexCoord(
--    CoordsToTexCoords(1024, 709, 849, 837, 873))
--resetButton:GetPushedTexture():SetTexCoord(
--    CoordsToTexCoords(1024, 709, 873, 837, 897))

-- Buy now button text
--resetButton.ButtonText = resetButton:CreateFontString()
--resetButton.ButtonText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
--resetButton.ButtonText:SetPoint("CENTER", resetButton, 0, 0)
--resetButton.ButtonText:SetText("Reset All")

-- Set the OnClick script for the reset button to call the resetSpells function
--resetButton:SetScript("OnClick", function(self) resetSpells() end)




----

end

function FelskornToggleTalentFrame()
    talentHandler.talentualOpenUI()
end

local function ReplaceBlizzardTalentFrame()
    ToggleTalentFrame = function()
        FelskornToggleTalentFrame()
    end

    if PlayerTalentFrame and PlayerTalentFrame:IsShown() then
        PlayerTalentFrame:Hide()
    end
end

ReplaceBlizzardTalentFrame()

local blocker = CreateFrame("Frame")
blocker:RegisterEvent("ADDON_LOADED")
blocker:SetScript("OnEvent", function(self, event, addon)
    if addon == "Blizzard_TalentUI" then
        ReplaceBlizzardTalentFrame()
    end
end)

requestTalentConfig()
-- 
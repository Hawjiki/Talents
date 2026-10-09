# Display Active Abilities Before Passive Spells

This change displays active abilities first and passive spells afterward in the spellbook, preserving the existing order within each group.

These instructions apply to the custom WotLK 3.3.5a `SpellBookFrame.lua` containing `spellbookCustomRender` and `SpellBookFrame_UpdateSpellRender()`.

## 1. Add the sorting function

Open `Interface\FrameXML\SpellBookFrame.lua`.

Immediately after `spellbookCustomRender = {}`, add:

```lua
local function SpellBook_SortActiveFirst(spells)
    local activeSpells = {}
    local passiveSpells = {}

    for _, data in ipairs(spells) do
        local spellName = GetSpellInfo(data.spellID)

        if spellName and IsPassiveSpell(spellName) then
            table.insert(passiveSpells, data)
        else
            table.insert(activeSpells, data)
        end
    end

    for index = #spells, 1, -1 do
        spells[index] = nil
    end

    for _, data in ipairs(activeSpells) do
        table.insert(spells, data)
    end

    for _, data in ipairs(passiveSpells) do
        table.insert(spells, data)
    end
end
```

## 2. Apply the sorting function

Inside `SpellBookFrame_UpdateSpellRender()`, find:

```lua
SpellBookFrame.selectedSkillLineOffset[i] = 1
SpellBookFrame.selectedSkillLineNumSpells[i] = #spellbookCustomRender[i]
```

Replace those two lines with:

```lua
if SpellBookFrame.bookType == BOOKTYPE_SPELL then
    SpellBook_SortActiveFirst(spellbookCustomRender[i])
end

SpellBookFrame.selectedSkillLineOffset[i] = 1
SpellBookFrame.selectedSkillLineNumSpells[i] = #spellbookCustomRender[i]
```

## 3. Restart the client

Save the file and restart the client to load the change.

--[[

This file contains the base class for an EffTable.

--]]

local dr = {}

local mw = require('mw')

local txt = require('Wikilib-strings')  -- luacheck: no unused
local tab = require('Wikilib-tables')   -- luacheck: no unused
local list = require('Wikilib-lists')
local oop = require('Wikilib-oop')
local multigen = require('Wikilib-multigen')
local w = require('Wikilib')
local box = require('Box')
local css = require('Css')
local abilData = require("PokéAbil-data")
local pokes = require("Poké-data")

--[[

This class represents a table of type effectiveness. It holds inforations
about the effectiveness of types against a Pokémon, or an alternative
form. This is the same as having data about effectivenes of types against
a types-abilities combination. Furthermore, it has footer lines, as a
list of FooterLine instances, and a list of forms sharing the same
effectiveness data.

--]]
dr.EffTable = oop.makeClass(list.Labelled)

-- ======================= STATIC FIELDS/METHODS ======================
-- Utility strings
dr.EffTable.strings = {
    -- Wikicode for the beginning of a box (Weaknesses, Resistances, etc)
    BOX_INIT = [=[<div style="padding: 0.5em 0;"><span class="inline-block align-middle text-center width-xl-30 width-xs-100" style="padding: 0.3em;">'''${text}'''</span><div class="inline-block align-middle width-xl-70 width-xs-100" style="padding: 0;">]=],

    -- Wikicode for an effextiveness line
    BOX_LINE = [=[<div class="flex flex-row flex-wrap flex-items-stretch width-xl-100" style="padding: 0.1em;"><div class="roundy vert-middle width-xl-5 width-md-10 width-xs-100" style="padding: 0 0.2em; background: #FFF;"><span>${eff}&times;</span></div><div class="text-left text-center-xs width-xl-95 width-md-90 width-xs-100" style="padding-left: 0.2em;">${types}</div></div>]=],

    -- Footer container string
    FOOTER_CONTAINER = [=[<div class="black-text text-left text-small" style="padding: 0.5em 0; margin: 0;">${lines}</div>]=],

    -- EffTable container string
    EFFTABLE_CONTAINER = [[<div class="roundy pull-center text-center overflow-auto width-xl-80 width-md-100" style="padding: 0.5ex; padding-bottom: 0.01ex; ${bg}">${effBoxes}${foot}</div>]],

    -- Container of an EffTable when there are multiple labels
    MULTILABEL_CONTAINER = [[==== ${title} ====
<div class="${collapse}">
${effTab}
</div>]],
}

--[[

All possible effectiveness values, considering abilities. Therefore,
triple resistances are taken in account, as well as abilities like
Filtro, Solidroccia and Pellearsa.

-- ]]
dr.EffTable.allEff = {
    0, 0.25, 0.5, 1, 2, 4, -- Standard
    -- 0.125, -- Triple resistance (useless for the time being)
    -- 0.3125, 0.625, 1.25, 2.5, 5, -- Pellearsa (useless for the time being)
    1.5, 3 -- Filtro/Solidroccia
}

-- Dedicated effectiveness representations
dr.EffTable.effStrings = {
    [0.5] = '½',
    [0.25] = '¼'
}

-- Classes and styles for type boxes
dr.EffTable.typeBoxStyles = {
    classes = {'roundy', 'text-center', 'inline-block', 'width-xl-15',
        'width-md-20', 'width-sm-35', 'width-xs-45'},
    styles = {['margin'] = '0.3ex', ['padding'] = '0.3ex 0',
        ['line-height'] = '3ex', ['font-weight'] = 'bold'}
}

--[[

Returns true whether a MAYBE footer line should be added, given abilities and
types. This happens only if the ability doesn't modify the types immunities.

--]]
dr.EffTable.shouldAddMaybe = function(abil, types, et)
    local abilMod = et.modTypesAbil[abil]
    local immType1 = et.typesHaveImm[types.type1]
    local immType2 = et.typesHaveImm[types.type2]

    -- Ability doesn't modify any type
    if not abilMod then
        return false
    end

    -- Types don't have immunities
    if not (immType1 or immType2) then
        return true
    end

    return table.all(abilMod, function(type)
            return immType1 and not table.search(immType1, type)
                    or immType2 and not table.search(immType2, type)
        end)
end

--[[
    Returns a dedicated representation of the effectiveness value, if any.
    Otherwise it just prints it using the comma as decimal separator
--]]
dr.EffTable.displayEff = function(eff)
    return dr.EffTable.effStrings[eff] or (tostring(eff):gsub('%.', ','))
end

-- Used to sort effectiveness boxes by ascending effectiveness
dr.EffTable.greatestEffFirst = function(line0, line1)
    return line0.eff > line1.eff
end

-- Prints a list of types as Boxes
dr.EffTable.printTypes = function(types)
    return box.listTipoLua(types, nil, dr.EffTable.typeBoxStyles.classes,
        dr.EffTable.typeBoxStyles.styles)
end

-- Prints a single lines of types having the same effectiveness
dr.EffTable.printEffLine = function(data)
    return string.interp(dr.EffTable.strings.BOX_LINE,
        {
            eff = dr.EffTable.displayEff(data.eff),
            types = dr.EffTable.printTypes(data.types),
        })
end

-- Prints a single effectiveness box (Weaknesses, Std, etc...)
dr.EffTable.printSingleBox = function(boxData)
    -- Only effectiveness list have numbers as keys
    local effData = table.filter(boxData, function(_, key)
            return type(key) == 'number' end)
    local allLines = w.mapAndConcat(effData, dr.EffTable.printEffLine)

    return string.interp(table.concat{dr.EffTable.strings.BOX_INIT,
            allLines, '</div></div>'},
        {
            text = boxData.text,
        })
end

-- Prints non-empty effectiveness boxes only
dr.EffTable.printEffBoxes = function(boxes)
    boxes = table.filter(boxes, function(b)
              return type(b) ~= 'table' or #b > 0
        end)
    return w.mapAndConcat(boxes, dr.EffTable.printSingleBox)
end

--[[

Given the input to the constructor, compute types, abilities and
label of the entry.
Returns three values: types, abilities and the label.

--]]
dr.EffTable.parseEntryData = function(input1, input2)
    local types, abils, label

    if type(input1) == 'table' and type(input2) == 'table' then
        types = table.map(input1, string.lower)
        abils = table.map(input2, string.lower)
        label = nil
    else
        types = multigen.getGen(pokes[input1])
        abils = table.map(multigen.getGen(abilData[input1]), string.lower)
        label = input2
    end

    return types, abils, label
end

--[[

Returns the Wikicode for a table of dr.EffTable objects: all tables but the
first are collapsed by default.

--]]
dr.EffTable.printEffTables = function(EffTables)

    -- If only one table is there, nothing to collapse
    if #EffTables == 1 then
        return tostring(EffTables[1])
    end

    -- All tables are collapsible and all default-collapsed but the first one
    return w.mapAndConcat(EffTables, function(EffTable, key)
            EffTable:setCollapse('mw-collapsible' ..
                    (key == 1 and '' or ' mw-collapsed'))
            return tostring(EffTable)
        end, '\n')
end

-- ======================== INSTANCE METHODS ========================
--[[

EffTable constructor. It takes types, abilities, a label and the EffTipi
informations to use.

--]]
dr.EffTable.new = function(types, abils, label, et)
    local this = setmetatable(dr.EffTable.super.new(label), dr.EffTable)
    this.collapse = ''
    -- this.types = types
    -- this.abils = abils
    -- this.et = et

    this:createColors(types)

    return this
end

--[[

Equality operator for effectiveness tables. Returns true if both
footers and effectiveness values are equal.

--]]
dr.EffTable.__eq = function(a, b)
    if not table.equal(a.footer, b.footer) then
        return false
    end

    --[[
        dr.EffTable.allEff is used since a and b can have different
        effectinevess values.
    --]]
    return table.all(dr.EffTable.allEff, function(eff)
            return table.equal(a[eff], b[eff]) end)
end

-- Creates the colors to be used as input for the CSS module
dr.EffTable.createColors = function(this, types)
    this.colors = {
        type1 = types.type1,
        type2 = types.type2,
    }
end

--[[

Compute all effectiveness for the given combination of types, abilities
and EffTipi informations given.

--]]
dr.EffTable.computeEff = function(this, types, abils, et)
    local onlyAbil = table.getn(abils) == 1

    -- For non unique abilities, the effectiveness calculations have to be
    -- made without ability, since the footer will contain lines about them.
    local abil = onlyAbil and abils.ability1 or 'tanfo'

    --[[
        For every possible effectiveness value, checks for types having it
        against the current types + ability combination. If some are found,
        they are added as a table to this, the key being the effectiveness.
    --]]
    for _, eff in ipairs(this.allEff) do
        local effTypes = et.difesa(eff, types.type1, types.type2, abil)
        if #effTypes > 0 then

            -- Sorting necessary for comparison and printing.
            table.sort(effTypes)
            this[eff] = effTypes
        end
    end
end

-- Collapsed setter
dr.EffTable.setCollapse = function(this, collapse)
    this.collapse = collapse
end

--[[

Returns the wikicode representation of an effectiveness table as a string.
Only non-empty effectivenesses are added and the footer is only present if it
contains at least one line.

--]]
dr.EffTable.__tostring = function(this)
    local weak = {text = 'Debolezze'}
    local std = {text = 'Danno normale'}
    local res = {text = 'Resistenze'}
    local imm = {text = 'Immunit&agrave;'}

    local interpData = {
        bg = css.horizGradLua(this.colors),
        foot = #this.footer < 1 and '' or string.interp(
                dr.EffTable.strings.FOOTER_CONTAINER,
                { lines = w.mapAndConcat(this.footer, tostring) })
    }

    -- Can't use ipairs because effectivenesses are not integers but floats
    for eff, types in pairs(this) do
        if type(eff) == 'number' then
            --[[
                eff is not used as an index since sorting is only supported for
                integer indixes
            --]]
            if eff == 0 then
                table.insert(imm, {eff = 0, types = types})
            elseif eff < 1 then
                table.insert(res, {eff = eff, types = types})
            elseif eff == 1 then
                table.insert(std, {eff = 1, types = types})
            else -- eff > 1
                table.insert(weak, {eff = eff, types = types})
            end
        end
    end

    -- Pointless to sort imm and std, as they only have one item
    table.sort(res, dr.EffTable.greatestEffFirst)
    table.sort(weak, dr.EffTable.greatestEffFirst)

    interpData.effBoxes = dr.EffTable.printEffBoxes({weak, std, res, imm},
            this.colors)

    local effTab = string.interp(
        dr.EffTable.strings.EFFTABLE_CONTAINER, interpData)

    if #this.labels > 0 then
        return string.interp(
            dr.EffTable.strings.MULTILABEL_CONTAINER, {
                title = mw.text.listToText(this.labels, ', ', ' e '),
                collapse = this.collapse or '',
                effTab = effTab
            })
    end

    return effTab
end

return dr

--[[

Gen 6 version of DebRes

--]]

local dr = {}

local txt = require('Wikilib-strings')  -- luacheck: no unused
local tab = require('Wikilib-tables')   -- luacheck: no unused
local oop = require('Wikilib-oop')
local basedr = require('DebRes-base')
local basefooter = require('DebRes-footer')
local et = require('EffTipi-6')

--[[

This class represents a table of type effectiveness. It holds inforation
about the effectiveness of types against a types-abilities combination.
Furthermore, it has footer lines, as a list of FooterLine instances,
and a list of forms sharing the same effectiveness data.

--]]
dr.EffTable = oop.makeClass(basedr.EffTable)

--[[

All the possible effectiveness values, considering abilities. Therefore,
triple resistances are taken in account, as well as abilities like
Filtro, Solidroccia and Pellearsa.

-- ]]
dr.EffTable.allEff = {
    0, 0.25, 0.5, 1, 2, 4, -- Standard
    1.5, 3 -- Filtro/Solidroccia
}

--[[

EffTable constructor. It can be used in two versions.

In the first, name and formname are not table, respectively a string with
the Pokémon name, as name + abbreviation, and an optional extended name
of the alternative form.

In the second, name and formname are tables, respectviely holding types
and abilities for whichthe DebRes should be created.

--]]
dr.EffTable.new = function(name, formname)
    -- local types, abils, label = basedr.EffTable.parseEntryData(name, formname)

    local types, abils, label = dr.EffTable.parseEntryData(name, formname)

    local this = setmetatable(dr.EffTable.super.new(types, abils, label, et),
                              dr.EffTable)

    this:computeEff(types, abils, et)
    this:makeFooter(types, abils)

    return this
end

-- Creates the footer for an efftable, given the primary ability, the types,
-- the full ability list and whether the ability is only one
dr.EffTable.makeFooter = function(this, types, abils)
    this.footer = {}

    local onlyAbil = table.getn(abils) == 1
    -- For non unique abilities, the effectiveness calculations have to be
    -- made without ability, since the footer will contain lines about them.
    local abil = onlyAbil and abils.ability1 or 'tanfo'

    -- Adding immunities footer lines
    if abil ~= 'magidifesa' then
        if et.typesHaveImm[types.type1] then
            table.insert(this.footer, basefooter.FooterLine.new('RINGTARGET',
                    types, abils, et))
        end

        if types.type1 ~= types.type2 and et.typesHaveImm[types.type2] then
            --[[
                Swapping types for dual typed Pokémon, since
                basefooter.FooterLine only checks the first one for immunities
            --]]
            table.insert(this.footer, basefooter.FooterLine.new('RINGTARGET',
                    {type1 = types.type2, type2 = types.type1}, abils, et))
        end
    end

    -- Adding TAKENOFF footer line for Pokémon having just one ability
    if onlyAbil then
        if et.modTypesAbil[abil] then
            table.insert(this.footer, basefooter.FooterLine.new('TAKENOFF',
                    types, abil, et))
        end

    -- Adding MAYBE footer line for Pokémon having more than one ability
    else
        local maybeAbils = table.filter(abils, function(ability)
                return this.shouldAddMaybe(ability, types, et) end)
        local maybeLines = table.mapToNum(maybeAbils, function(ability)
                return basefooter.FooterLine.new('MAYBE', types, ability, et)
            end)
        this.footer = table.merge(this.footer, maybeLines)
    end

    -- Footer should be sorted for equality and printing
    table.sort(this.footer)
end

return dr

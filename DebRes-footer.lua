--[[

This file contains the "standard" EffTable footer line, ie. footer lines
for post-gen-1, non-glitch main series.

--]]

local fl = {}

local mw = require('mw')

local txt = require('Wikilib-strings')  -- luacheck: no unused
local tab = require('Wikilib-tables')   -- luacheck: no unused
local oop = require('Wikilib-oop')
local link = require('Links')
local basedr = require('DebRes-base')

--[[

This class represents an item in the footer list of lines. It needs
information about the line category, the initial text and the new
effectivenesses, as well as EffTipi informations.

These are the line categories:
    - MAYBE: This category tells about the effectiveness in case a specimen has
        a certain ability. Used for Pokémon species that can have more than one
        ability.
    - TAKENOFF: This category tells about the effectiveness in case an ability
        is lost. Used for Pokémon species that can have only one ability.
    - RINGTARGET: This category tells about the effectiveness of type-due
        immunities when immunities are lost.
--]]
fl.FooterLine = oop.makeClass()

-- ======================= STATIC FIELDS/METHODS ======================

-- Utility footerline strings. They can contain interpolation placeholders.
fl.FooterLine.strings = {

    -- MAYBE category beginning text
    MAYBE = 'Se questo Pok&eacute;mon ha [[${abil}]] ',

    -- TAKENOFF category beginning text
    TAKENOFF = 'Se le abilit&agrave; non compaiono nel gioco, se questo Pok&eacute;mon perde [[${abil}]] o se ne sono annullati gli effetti, ',

    -- RINGTARGET category beginning text
    RINGTARGET = 'Se questo Pok&eacute;mon tiene un [[Facilsaglio]]',

    -- Strings to be concatenated to RINGTARGET for some types
    SPETTRO = ', se un avversario usa [[Preveggenza]] o [[Segugio]] o ha [[Nervisaldi]], ',
    BUIO = ' o se un avversario usa [[Miracolvista]], ',
    VOLANTE = ' o una [[Ferropalla]] o se viene usata [[Gravit&agrave;]], ',

    --[[
        Strings to be concatenated to RINGTARGET for immunities shared by
        ability and types
    --]]
    NOT_HAVE_ABIL = 'e se non ha [[${abil}]], ',
    IMM_TAKENOFF = 'e se ha perso [[${abil}]] o ne sono stati annullati gli effetti, ',

    -- New effectieness text
    EFF = "l'efficacia delle mosse di tipo ${types} &egrave; pari a ${eff}×",

    -- Special string for Magidifesa
    MAGIDIFESA = "solo mosse di tipo ${normale} e ${lotta} non lo renderanno esausto.",
}

-- Sorting categories to sort footerlines
fl.FooterLine.kindOrder = {'MAYBE', 'TAKENOFF', 'RINGTARGET'}

--[[

Returns whether an ability gives immunity to a certain type. Arguments
are the ability, the type and informations on EffTipi.

--]]
fl.FooterLine.abilityGrantsImm = function(abil, type, et)
    --[[
        This check is implemented computing the effectivenes of a type
        against another one that doesn't have immunities by itself and
        checking whether it's 0 or not.
    --]]
    return 0 == et.efficacia(type, 'elettro', 'elettro', abil)
end

--[[

Given a list of abilities and a type, filters such list to abilities
that shares an immunity with the given type.
Also needs EffTipi informations

--]]
fl.FooterLine.abilsSharingImmunity = function(typeImm, abils, et)
    return table.filter(abils,
        function(abil)
            return fl.FooterLine.abilityGrantsImm(abil, typeImm, et)
        end)
end

--[[

Equal operator for FooterLine. Two instances are considered equal if
they both have a tostring field, or if they have the same initial parts and
newEff tables.

--]]
fl.FooterLine.__eq = function(a, b)
    return a.tostring and b.tostring
        or not (a.tostring or b.tostring)
            and a.beginstring == b.beginstring
            and table.equal(a.newEff, b.newEff)
end

--[[

Less than operator for FooterLine, to allow sorting. Comparison is made by
categories, as specified in fl.FooterLine.kindOrder. In case of
equality, the initial parts of the lines are compared alphabetically.

--]]
fl.FooterLine.__lt = function(a, b)
    local aIndex = table.search(fl.FooterLine.kindOrder, a.kind)
    local bIndex = table.search(fl.FooterLine.kindOrder, b.kind)
    return aIndex == bIndex
           and a.beginstring < b.beginstring
           or aIndex < bIndex
end

--[[

This table holds functions to generate the initial part of a FooterLine based
on its category.

--]]
fl.FooterLine.init = {}

-- Initial part for MAYBE category. Simple string interpolation.
fl.FooterLine.init.MAYBE = function(abil)
    return string.interp(fl.FooterLine.strings.MAYBE,
            {abil = string.camelCase(abil)})
end

-- Initial part for TAKENOFF category. Simple string interpolation.
fl.FooterLine.init.TAKENOFF = function(abil)
    return string.interp(fl.FooterLine.strings.TAKENOFF,
            {abil = string.camelCase(abil)})
end

--[[

Initial part for RINGTARGET category. After adding some more strings based on
the type and the abilities, concatenates the result.

--]]
fl.FooterLine.init.RINGTARGET = function(abils, type, et)
    local pieces = {fl.FooterLine.strings.RINGTARGET}

    -- Adding text for specific types, otherwise a space
    table.insert(pieces, fl.FooterLine.strings[type:upper()] or ' ')

    --[[
        If the Pokémon has only one ability, the related string deals with its
        loss, otherwise it is about the possibility of it happening.
    --]]
    local notAbil = table.getn(abils) == 1
            and fl.FooterLine.strings.IMM_TAKENOFF
            or fl.FooterLine.strings.NOT_HAVE_ABIL

    --[[
        Adds a string for every ability that shares an immunity with the
        type of the footerline
    --]]
    local abilImm = table.flatMap(
        et.typesHaveImm[type:lower()],
        function(typeImm)
            return fl.FooterLine.abilsSharingImmunity(typeImm, abils, et)
        end)
    local abilImmString = table.mapToNum(abilImm, function(abil)
            return string.interp(notAbil, {abil = string.camelCase(abil)})
        end)

    pieces = table.merge(pieces, abilImmString)

    return table.concat(pieces)
end

-- ======================== INSTANCE METHODS ========================

--[[

FooterLine constructor. Its arguments are a line category, the Pokémon type
and a single ability. The only exception is the RINGTARGET category, that
requires all of the Pokémon abilities.

--]]
fl.FooterLine.new = function(kind, types, abil, et)
    local this = setmetatable({}, fl.FooterLine)

    kind = kind:upper()
    types = table.map(types, string.lower)
    abil = type(abil) ~= 'table' and abil:lower()
            or table.map(abil, string.lower)

    -- Line category
    this.kind = kind

    -- Initial part of the footer line
    this.beginstring = '\n*' .. this.init[kind](abil, types.type1, et)

    --[[
        For every new effectiveness value, a key-value pair is added to this
        table: the key is the effectiveness (as a string), and the value is
        a table of all the types names having this effectiveness.
        Such types need to be kept sorted, so that table.equals can compare
        them correctly and printing is easier.
    --]]
    this.newEff = {}

    -- Handling corner case abilities
    if this:makeSpecialAbil(kind, types, abil, et) then
        return this
    end

    --[[
        RINGTARGET type with mono-type Pokémon, the new effectiveness are 1x
        against the types the Pokémon is immune to
    --]]
    if kind == 'RINGTARGET' and types.type1 == types.type2 then
        this.newEff[1] = et.typesHaveImm[types.type1]
        -- See the comment for this.newEff
        table.sort(this.newEff[1])

        return this
    end

    local newTypes
    newTypes, types, abil = this:makeNewTypes(kind, types, abil, et)
    -- See the comment for this.newEff
    table.sort(newTypes)

    --[[
        Every type that changes effectiveness is routed into the mapping with
        the corresponding effectiveness in this.newEff. The mapping is
        created on the spot if not already existing.
    --]]
    for _, type in ipairs(newTypes) do
        local eff = et.efficacia(type, types.type1, types.type2, abil)
        if this.newEff[eff] then
            table.insert(this.newEff[eff], type)
        else
            this.newEff[eff] = {type}
        end
    end

    return this
end

--[[
    This method takes care of corner case abilities that need to be treated
    separately when calculating new effectiveness. It takes as argument athe
    ability to be checked and possibly handled, and the types to be used when
    calculating the new effectiveness. If the ability is a corner case, true
    is returned, false otherwise. Such abilities are so far Filtro,
    Solidroccia, Scudoprisma and Magidifesa.
--]]
fl.FooterLine.makeSpecialAbil = function(this, kind, types, abil, et)
    -- RINGTARGET footer line type doesn't deal with abilities
    if kind == 'RINGTARGET' then
        return false
    end

    --[[
        These abilities reduce the effectiveness of super-effective moves.
        However, if the type is TAKENOFF, the effectiveness shown in the footer
        should be the one without theability, that is the increased one.
    --]]
    if table.search({'filtro', 'solidroccia', 'scudoprisma'}, abil) then
        -- Super-effective number values
        local superEff = table.filter(basedr.EffTable.allEff, function(eff)
                return eff > 1 end)

        --[[
            Multiplier to derive the effectiveness shown in the footer. It
            should increase the current one if the footer line type is
            TAKENOFF, since the basic calculation is made with the ability.
            Otherwise, the new effectiveness should be decreased,
        --]]
        local mult = kind == 'TAKENOFF' and 1.33 or 0.75

        --[[
            If the footer line kind is TAKENOFF, the ability needs to be taken
            in account when looking for super-effective types. Otherwise, it
            should be not.
        --]]
        local effAbil = kind == 'TAKENOFF' and abil or 'tanfo'

        --[[
            For any super-effective value that has some types, the types are
            added to the footer with reduced/incrased effectiveness.
        --]]
        for _, eff in ipairs(superEff) do
            local effTypes = et.difesa(eff, types.type1, types.type2, effAbil)
            if #effTypes > 0 then
                local newEff = math.ceil(eff * mult * 100) / 100
                -- See the comment for this.newEff in the constructor
                table.sort(effTypes)
                this.newEff[newEff] = effTypes
            end
        end

        return true

    --[[
        The stantard footer would be too long here. Furthermore, the
        ability will always be Shedinja's peculiar, so we chose a custom
        solution.
    --]]
    elseif abil == 'magidifesa' then
        this.tostring = string.interp(
            table.concat{
                '\n*',
                fl.FooterLine.strings.TAKENOFF,
                fl.footerLine.strings.MAGIDIFESA
            },
            {
                abil = 'Magidifesa',
                normale = link.colorType('Normale'),
                lotta = link.colorType('Lotta')
            })

        return true
    end

    return false
end

--[[
    This method returns the types that gain a new effectiveness in the footer
    line context, as well as returning the new types and abilities to be used
    in the effectiveness value calculations. It takes as parameters the types
    and abilities to base the computations on.
--]]
fl.FooterLine.makeNewTypes = function(this, kind, types, abil, et)
    local newTypes
    if kind == 'RINGTARGET' then
        -- The new types are the ones the first type is immune to
        newTypes = et.typesHaveImm[types.type1]
        -- The Pokémon is now mono-type, in type effectiveness respect
        types.type1 = types.type2
    else
        -- The new types are the ones the ability has an impact on
        newTypes = et.modTypesAbil[abil]
        --[[
            If the ability is taken off, then it should not be taken in
            account when dealing with this line type effectiveness
        --]]
        abil = kind == 'TAKENOFF' and 'tanfo' or abil
    end

    return newTypes, types, abil
end

--[[

String representation of a FooterLine. For every effectiveness value, it
creates colored labels for its types, and it appends them to the initial text.

--]]
fl.FooterLine.__tostring = function(this)
    if this.tostring then
        return this.tostring
    end

    local newEff = table.mapToNum(this.newEff, function(types, eff)
            local colorTypes = table.map(types, function(type)
                    return link.colorType(type)
                end, ipairs)
            return string.interp(fl.FooterLine.strings.EFF,
                {
                    types = mw.text.listToText(colorTypes, ', ', ' e '),
                    eff = basedr.EffTable.displayEff(eff)
                })
        end)

    return table.concat{this.beginstring,
        mw.text.listToText(newEff, ', ', ' e '),
        '.'
    }
end

return fl
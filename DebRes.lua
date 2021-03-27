--[[

Creates a table showing weaknesses and resistances of a Pokémon.

If a Pokémon has more forms, it only shows tables that are actually
different. Forms that share a table are listed above the table itself.

It can be called with a Pokémon name. Ex:

{{#invoke: DebRes | DebRes | Nidoking }}

it can be invoked with types and abilities, using both positional and named
parameters. Ex:

{{#invoke: DebRes | DebRes | Veleno | Terra | Velenopunto | Antagonismo
        | Forzabruta | Remasabbia }}
{{#invoke: DebRes | DebRes | type1=Veleno | type2=Terra | abil1=Velenopunto
        | abil2=Antagonismo | abild=Clorofilla | abile=Risplendi }}

It can be called with one type and one ability. Ex:

{{#invoke: DebRes | DebRes | Spettro | | Levitazione }}
{{#invoke: DebRes | DebRes | type=Spettro | abil=Levitazione }}

It can be used with just one type. Ex:

{{#invoke: DebRes | DebRes | Spettro }}
{{#invoke: DebRes | DebRes | type=Spettro }}

It can be invoked with two types as well. Ex:

{{#invoke: DebRes | DebRes | Veleno | Terra }}
{{#invoke: DebRes | DebRes | type1=Veleno | type2=Terra }}

NOTE: named and positional parameters could be mixed, but I STRONGLY
    recommend NOT TO DO IT.

======================= DEVELOPER INFORMATIONS =======================

This file is actually just a proxy to the most recent DebRes, that should
be used in Pokémon pages.
Actual DebRes are defined in subpages, and inherit from a base class
defined in DebRes-base.

--]]

local dr = {}


local mw = require('mw')

local txt = require('Wikilib-strings')  -- luacheck: no unused
local tab = require('Wikilib-tables')   -- luacheck: no unused
local list = require('Wikilib-lists')
local multigen = require('Wikilib-multigen')
local w = require('Wikilib')
local currdr = require('DebRes-6')
local pokes = require("Poké-data")

dr.debRes = function(frame)
    local p = w.trimAndMap(mw.clone(frame.args), string.lower)
    local pokeData = p[1] and (pokes[string.parseInt(p[1]) or p[1]]
            or pokes[mw.text.decode(p[1])])

    --[[
        If no data is found, the first parameter is the type, that is no
        Pokémon is given and types and abilities are directly provided
    --]]
    if not pokeData then
        local types, abils = {}, {}
        types.type1 = p[1] or p.type1 or p.type
        types.type2 = p[2] or p.type2 or types.type1
        abils.ability1 = p[3] or p.abil1 or p.abil
        abils.ability2 = p[4] or p.abil2
        abils.abilityd = p[5] or p.abild
        abils.abilitye = p[6] or p.abile
        return tostring(currdr.EffTable.new(types, abils))
    end

    pokeData = multigen.getGen(pokeData)

    return list.makeFormsLabelledBoxes({
        name = pokeData.name:lower(),
        makeBox = currdr.EffTable.new,
        printBoxes = currdr.EffTable.printEffTables
    })
end

dr.DebRes, dr.debres = dr.debRes, dr.debRes

return dr

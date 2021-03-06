--[[

This module creates all HTML tables for
a single Pokémon, for all generations and
all forms.

NOTE: It doesn't support form differences
not listed in AltForms/data or
UselessForms/data, noticeably most gender
differences.

--]]

local u = {}

local mw = require('mw')

local txt = require('Wikilib-strings')
local tab = require('Wikilib-tables') -- luacheck: no unused
local gamesUtil = require('Wikilib-games')
local gens = require('Wikilib-gens')
local forms = require('Wikilib-forms')
local multigen = require('Wikilib-multigen')
local ms = require('MiniSprite')
local spr = require('Spr')
local c = require("Colore-data")
local alt = forms.allFormsData()
local pokes = require("Poké-data")
local gendata = require("Gens-data")
local wlib = require("Wikilib-data")

--[[

Cella di una generazione dell'intestazione
della table dei mini sprite. Ha come argomenti
la generazione della cella, quella del Pokémon
e la regione associata.

--]]

local genBox = function(gen, pokeGen, region)
	local link
	-- All'indice di una generazione contiene la prima generazione
	-- che usa lo stesso MS
	local MSGenRef = { '1', '2', '3', '3', '3', '6', '6' }

	link = {}
	for gen = math.max(pokeGen, MSGenRef[gen]), gen do
		table.insert(link, table.concat{'[[', gendata[gen].ext,
		' generazione|<span style="color:#000">',
		gendata[gen].roman, '</span>]]'})
	end
	link = table.concat(link, '-')
	return string.interp('! class="roundy" style="padding: 3px; width: 50px; background: #${light}; border: 1px solid #${dark};" | ${link}',
{
	light = c[region].light,
	dark = c[region].dark,
	link = link
})
end

--[[

Intestazione della tabella dei mini sprite.

Scorre il primo argomento, che è un array
con le generazioni dei mini sprites, e per
ogni elemento crea una cella con l'apposita
funzione

--]]

local headGens = function(msGens, pokeGen)
	return table.concat(table.map(msGens, function(gen)
			return genBox(gen, pokeGen, gendata[gen].region)
		end), '\n')
end

-- Crea una cella per i mini sprite, usando l'apposito modulo.

local msBox = function(abbr, ndex, gen)
	return string.interp('| class="roundy" style="background: #FFF; border: 1px solid #000;" | ${ms}',
		{ms = ms.staticLua(txt.tf(ndex) ..
				(abbr == 'base' and '' or abbr), gen)})
end

--[[

Crea una riga di box per i mini sprites di una stessa
forma.

Scorre gli elementi dell'argomento msGens, che
è dunque un array con le generazioni dei mini sprite,
e per ognuno inserisce l'immagine se la forma esiste
in quella generazione, altrimenti un box vuoto. Infine
aggiunge in testa ai box ottenuti quello del nome della
forma

--]]

local msLine = function(abbr, name, ndex, type1, type2, msGens)
	local formLine = {}

	--[[
		Caso particolare: unown è il solo Pokémon ad
		avere il mini sprite di seconda generazione
		uguale per tutte le forme, con un rowspan di
		26, che viene inserito a parte una sola volta,
		con la sigla della forma base; per le forme ?
		e ! si inserisce invece una cella vuota
	--]]
	if ndex == 201 then
		if abbr == 'base' then
			table.insert(formLine, '| style="background: #FFF; border: 1px solid #000;" rowspan="26" class="roundy" | ' .. ms.staticLua(201, 2))
			table.remove(msGens, 1)
		elseif abbr == 'PE' or abbr == 'PI' then
			table.insert(formLine, '| &nbsp;')
		end
	end

	for k, gen in ipairs(msGens) do

        --[[
            Checking if the current form is
            available in any of the current
            mini sprite generations.
        --]]
        local shouldShow = false
        for i = msGens[k - 1] or 1, gen do
            shouldShow = shouldShow or gamesUtil.anyInGen(i,
                alt[ndex].since[abbr],
                alt[ndex]['until'] and alt[ndex]['until'][abbr])
        end

        if shouldShow then
			table.insert(formLine, msBox(abbr, ndex, gen))
		else
			table.insert(formLine, '| &nbsp;')
		end
	end

	return string.interp([=[|-
| class="roundy" style="color:#${dark}; background: #${light}; padding: 3px; height: 50px;" | ${name}
${forms}]=],
{
	light = c[type1].light,
	dark = type1 == type2 and c[type1].dark or c[type2].normale,
	name = name == '' and pokes[ndex].name or name,
	forms = table.concat(formLine, '\n')
})
end

--[[

Crea una riga di minispirte per ogni forma.

Loops through gamesChron, so that the result
is already ordered. Most arguments are just
passed down to msLine.

--]]

local msForms = function(msGens, ndex, type1, type2)
	return table.concat(table.map(alt[ndex].gamesOrder, function(abbr)
			return msLine(abbr, alt[ndex].names[abbr],
					ndex, type1, type2, msGens)
		end), '\n')
end

--[[

Crea la tabella dei mini sprite.

Dapprima si recuperano i tipi della forma
base, per poterne usare i colori per la
tabella. Poi si determinano le generazioni
dei mini sprite e si procede con il wikicode,
in cui vengono inserite l'intestazione e
le righe relative alle forme con apposite
funzioni

--]]

local msTable = function(gen, ndex)
	local pokedata = multigen.getGen(pokes[ndex])
	local type1, type2 = pokedata.type1, pokedata.type2
	--[[
		Si determinano le generazioni dei mini
		sprites, che non sono continue poiché
		terza, quarta e quinta generazione
		condividono gli stessi.

		I mini sprite di Unown della seconda
		generazione vengono aggiunti come caso
		particolare, quindi qui si inseriscono
		solo i restanti
	--]]
	local msGens
	if gen < 2 then
		msGens = {1, 2, 5, 7}
	elseif gen < 3 then
		msGens = {2, 5, 7}
	elseif gen < 6 then
		msGens = {5, 7}
	else
		msGens = {7}
	end
	return string.interp([=[


== Mini Sprite ==
{| class="roundy pull-center text-center" style="border: 2px solid #${dark}; background:#${std};"
! class="roundy" colspan="5" style="width: 100%; background:#${light}; color:#${dark};" | Mini sprite
|-
! class="roundy" style="padding: 3px; background: #E6E6E6; border: 1px solid grey;" | Nome forma
${gens}
${forms}
|}]=],
{
	std = c[type1].normale,
	dark = type1 == type2 and c[type1].dark or c[type2].normale,
	light = c[type1].light,
	gens = headGens(msGens, gen),
	forms = msForms(msGens, ndex, type1, type2)
})
end

--[[

Dati per gli sprite relativi ai giochi,
divisi per generazione.

Per ogni sprite sono indicati il/i gioco/i
a cui appartiene, l'indice da usare per
la cronologia e la sigla del nome dell'
immagine dello sprite

--]]

local spriteGames = {
	[1] = {
		{
			games = {'Rosso', 'Blu'},
			gamesAbbr = 'rb',
			sprAbbr = 'rb'
		},
		{
			games = {'Rosso (J)', 'Verde'},
			gamesAbbr = 'v',
			sprAbbr = 'verde'
		},
		{
			games = {'Giallo'},
			gamesAbbr = 'g',
			sprAbbr = 'gia'
		}
	},

	[2] = {
		{
			games = {'Oro'},
			gamesAbbr = 'oa',
			sprAbbr = 'or'
		},
		{
			games = {'Argento'},
			gamesAbbr = 'oa',
			sprAbbr = 'ar'
		},
		{
			games = {'Cristallo'},
			gamesAbbr = 'c',
			sprAbbr = 'cr'
		}
	},

	[3] = {
		{
			games = {'Rubino', 'Zaffiro'},
			gamesAbbr = 'rz',
			sprAbbr = 'rz'
		},
		{
			games = {'Rosso Fuoco', 'Verde Foglia'},
			gamesAbbr = 'rfvf',
			sprAbbr = 'rfvf'
		},
		{
			games = {'Smeraldo'},
			gamesAbbr = 's',
			sprAbbr = 'sme'
		}
	},

	[4] = {
		{
			games = {'Diamante', 'Perla'},
			gamesAbbr = 'dp',
			sprAbbr = 'dp'
		},
		{
			games = {'Platino'},
			gamesAbbr = 'pt',
			sprAbbr = 'pt'
		},
		{
			games = {'HeartGold', 'SoulSilver'},
			gamesAbbr = 'hgss',
			sprAbbr = 'hgss'
		}
	},

	[5] = {
		{
			games = {'Nero', 'Bianco'},
			gamesAbbr = 'nb',
			sprAbbr = 'nb'
		},
		{
			games = {'Nero 2', 'Bianco 2'},
			gamesAbbr = 'n2b2',
			sprAbbr = 'nb2'
		}
	},

	[6] = {
		{
			games = {'X', 'Y'},
			gamesAbbr = 'xy',
			sprAbbr = 'xy'
		},
		{
			games = {'Rubino Omega', 'Zaffiro Alpha'},
			gamesAbbr = 'roza',
			sprAbbr = 'roza'
		}
	},

	[7] = {
		{
			games = {'Sole', 'Luna'},
			gamesAbbr = 'sl',
			sprAbbr = 'sl'
		},
		{
			games = {'Ultrasole', 'Ultraluna'},
			gamesAbbr = 'usul',
			sprAbbr = 'usul'
		}
	},

	[8] = {
		{
			games = {'Spada', 'Scudo'},
			gamesAbbr = 'spsc',
			sprAbbr = 'spsc'
		},
	},
}

--[[

Aggiunge la variante back a quella passata, in
modo tale da essere accettata dal modulo spr

--]]

local addBack = function(variant)
	local words = mw.text.split(variant, ' ', true)
	table.insert(words, 2, 'back')
	return table.concat(words, ' ')
end

--[[

Ritorna true se bisogna aggiungere la
riga per la femmina, ovvero:
- Dalla quarta generazione in poi
- Se il genere non è la differenza
		di forma principale
- Se c'è differenza di genere

--]]

local shouldAddFemaleLine = function(ndex, gen)
	return gen > 3
		and not table.search(alt[ndex].names, 'Femmina')
		and table.search(wlib.alsoFemales, ndex)
end

--[[

Ritorna sigla, nome e variante sprite,
tenendo conto dei generi. Le modifiche
degne di nota sono:
- Variante sprite e sigla quando la forma
		è 'Femmina'
- Nome a 'Maschio' se è la forma base ed
		esiste una differenza di genere

--]]

local fixGenders = function(abbr, gen, ndex, variant)
	if gen > 3 then
		if alt[ndex].names[abbr] == 'Femmina' then
			return 'base', 'Femmina', 'fe' .. variant
		end

		if alt[ndex].names[abbr] == 'Maschio' or abbr == 'base'
				and table.search(wlib.alsoFemales, ndex) then
			return 'base', 'Maschio', variant
		end
	end

	return abbr, alt[ndex].names[abbr], variant
end

--[[

Cella dei giochi dell'intestazione delle
tables degli sprite. Necessita della
larghezza percentuale della cella stessa,
del gioco, del nome della pagina da linkare,
che ha come default il gioco, e dell'
arrotondamento, che invece ha default
la stringa vuota. La variabile color si
rende necessaria a causa di "Rosso (J)"

--]]

local gameBox = function(wd, game, link, rd)
	local color = game:gsub('%s%(J%)', '')
	return string.interp([=[! class="roundy${rd}" style="width: ${wd}%; background-color: #${std}; border: 1px solid #${dark};" | [[Pokémon ${link}|<span style="color:#${txtc}">${game}</span>]]]=],
{
		wd = wd,
		rd = rd or '',
		std = c[color].normale,
		dark = c[color].dark,
		link = link or game,
		txtc = table.search(wlib.whitetext, game:lower()) and 'FFF' or '000',
		game = game
})
end

--[[

Crea tutte le celle dei giochi della
generazione passata delle tables degli
sprite.

Scorre gli elementi della
subtable di SpriteGames relativo alla
generazione passata: se incontra una
subtable, allora per i due giochi in
essa contenuta inserisce una cella
con larghezza dimezzata, il nome della
pagina da linkare costruito con i due
elementi della sottotabella e arrotondamenti
left e right; altrimenti inserisce una cella
con larghezza intera e nome del gioco

--]]

local headGames = function(gen, ndex)
	--[[
		Caso particolare: Deoxys nella terza
		generazione ha una forma per ogni
		gioco, dunque bisogna inserire una
		riga diversa da tutte le altre
	--]]
	if gen == 3 and ndex == 386 then
		return table.concat({gameBox('8', 'Rubino', 'Rubino e Zaffiro', 'left'),
			gameBox('8', 'Zaffiro', 'Rubino e Zaffiro', 'right'),
			gameBox('16', 'Rosso Fuoco'), gameBox('16', 'Verde Foglia'),
			gameBox('16', 'Smeraldo')}, '\n')
	end

	-- Suddette elaborazioni; il gsub del game[1] serve per "Rosso (J)"

	return table.concat(table.map(spriteGames[gen], function(data)
			if #data.games == 2 then
				local link = table.concat{data.games[1]:gsub('%s%(J%)', ''),
						' e ', data.games[2]}
				local width = math.floor(50 / (#spriteGames[gen] + 2)) -- 100 / (...) / 2
				return table.concat{gameBox(width, data.games[1], link, 'left'),
						'\n', gameBox(width, data.games[2], link, 'right')}
			end
			return gameBox(math.floor(100 / (#spriteGames[gen] + 2)), data.games[1])
		end), '\n')
end

--[[

Crea il box con uno sprite, avendo a disposizione:
ndex, gioco, sesso e shiness, sigla della forma e
colspan della cella

--]]

local sprBox = function(game, var, ndex, form, cs)
	return string.interp([=[| class="roundy" style="background: #FFF; border: 1px solid #000;" colspan="${cs}" | ${spr}]=],
{
	cs = cs,
	spr = spr.sprLua(txt.three_figures(ndex)
			.. (form == 'base' and '' or form), game, var)
})
end

--[[

Crea una riga di sprite per ogni forma.

Scorre gli elementi della subtable spriteGames
relativa alla generazione passata, inserendo
un box per ognuno, se la forma esisteva
in dato gioco. Aggiunge poi in testa una
cella con il nome della forma e in fondo
quella per lo sprite retro.

--]]

local boxesLine = function(abbr, name, gen, var, ndex)
	local region = gendata[gen].region
	local backGame = gamesUtil.isBefore(gendata[gen].games[1],
                alt[ndex].since[abbr])
            and alt[ndex].since[abbr]
            or gendata[gen].games[1]

	local boxes = table.map(spriteGames[gen], function(data)
            local poke = ndex .. forms.toEmptyAbbr(abbr)
			return gamesUtil.isInGame(poke, data.gamesAbbr)
                    and sprBox(data.sprAbbr, var, ndex, abbr, #data.games)
                    or table.concat{'| colspan="', #data.games , '" | &nbsp; '}
		end)
	return string.interp([=[

|-
| class="roundy" style="color:#${dark}; background: #${light};" | ${name}${shinyStar}
${boxes}
${back}]=],
{
	light = c[region].light,
	dark = c[region].dark,
	name = name == '' and pokes[ndex].name or name,
	shinyStar = var:find('shiny') and table.concat{'[[File:Cromatico',
			gendata[gen].roman, '.png]]'} or '',
	boxes = table.concat(boxes, '\n'),
	back = sprBox(backGame, addBack(var), ndex, abbr, '1')
})
end

--[[

Crea una riga di box di sprites per ogni forma.

Inserisce le righe, se necessario, scorrendo la
table gamesOrder del Pokémon nella table delle
forme alternative, così da non dover ordinare
successivamente.

--]]

local formsBoxes = function(ndex, gen, var)
	--[[
		Caso particolare: Deoxys nella terza
		generazione ha una forma per ogni gioco,
		dunque la riga è unica
	--]]
	if ndex == 386 and gen == 3 then
		return string.interp([=[

|-
| class="roundy" style="background: #${light}; color:#${dark};" | Deoxys${shinyStar}
| class="roundy" colspan="2" style="background: #FFF; border: 1px solid #000;" | ${sprrz}
| class="roundy" style="background: #FFF; border: 1px solid #000;" | ${sprrf}
| class="roundy" style="background: #FFF; border: 1px solid #000;" | ${sprvf}
| class="roundy" style="background: #FFF; border: 1px solid #000;" | ${sprs}
| class="roundy" style="background: #FFF; border: 1px solid #000;" | <div>${sprrzd}${sprrfd}</div>${sprvfd}${sprsd}]=],
	{
		light = c.hoenn.light,
		dark = c.hoenn.dark,
		shinyStar = var:find('shiny') and '[[File:ShinyIIIStar.png]]' or '',
		sprrz = spr.sprLua('386', 'rz', var),
		sprrf = spr.sprLua('386A', 'rfvf', var),
		sprvf = spr.sprLua('386D', 'rfvf', var),
		sprs = spr.sprLua('386V', 's', var),
		sprrzd = spr.sprLua('386', 'rz', addBack(var), '40px'),
		sprrfd = spr.sprLua('386A', 'rfvf', addBack(var), '40px'),
		sprvfd = spr.sprLua('386D', 'rfvf', addBack(var), '40px'),
		sprsd = spr.sprLua('386V', 'sme', addBack(var), '40px'),
	})
	end

	local lines = table.filter(alt[ndex].gamesOrder, function(abbr)
        return gamesUtil.anyInGen(gen,
                alt[ndex].since[abbr],
                alt[ndex]['until'] and alt[ndex]['until'][abbr])
    end)
    lines = table.map(lines, function(abbr)
            local abbr, name, var = fixGenders(abbr, gen, ndex, var)
			return boxesLine(abbr, name, gen, var, ndex)
		end, ipairs)

	if shouldAddFemaleLine(ndex, gen) then
		table.insert(lines, 2, boxesLine('base', 'Femmina', gen,
				'fe' .. var, ndex))
	end
	return table.concat(lines, '\n')
end

-- Wikicode per la tabella degli sprite di una singola generazione.

local genTable = function(gen, ndex)
	local region = gendata[gen].region
	local gender = table.search(wlib.onlyFemales, ndex)
			and 'female' or 'male'

	return string.interp([=[{| class="roundy pull-center text-center" style="width: 65%; border: 2px solid #${dark}; background:#${std};"
! class="roundy" colspan="7" style="background:#${light};" | [[${gen} generazione|<span style="color:#${dark}">${gen} generazione</span>]]
|-
! class="roundy" style="width: ${wd}%; background-color: #E6E6E6; border: 1px solid grey;" | Nome forma
${games}
! class="roundy" style="width: ${wd}%; background-color: #E6E6E6; border: 1px solid grey;" | Retro${forms}${shinyForms}
|}]=],
{
	dark = c[region].dark,
	std = c[region].normale,
	light = c[region].light,
	gen = string.fu(gendata[gen].ext),
	wd = math.floor(100 / (#spriteGames[gen] + 2)),
	games = headGames(gen, ndex),
	forms = formsBoxes(ndex, gen, gender),
	shinyForms = gen > 1 and formsBoxes(ndex, gen, gender .. ' shiny') or ''
})
end

--[[

Funzione di interfaccia.

Dopo aver estratto il nome del Pokémon dall'unico
argomento, provvede a caricare se necessario il
modulo UselessFormsdata, quindi a recuperare dex
nazionale e generazione, e infine a creare le
tabelle degli sprites delle singole generazioni
e quella dei mini sprite

--]]

u.altSprites = function(frame)
	local poke = mw.text.decode(string.trim(frame.args[1] or '')):lower()

	-- Uses both AltForms and UselessForms
	local ndex = pokes[poke].ndex
	local gen = gens.getGen.ndex(ndex)

	--[[
		Per i Pokémon che, come Meowstic, hanno la
		differenza di forma principale nel genere,
		ma non hanno il Maschio come forma base:
		si toglie quest'ultima, per evitare di avere
		una riga in più inutile
	--]]
	if alt[ndex].names.M == 'Maschio' then
		table.remove(alt[ndex].gamesOrder, 1)
	end

	local forms = {}
	for a = gen, gendata.latest do
		table.insert(forms, table.concat{'== ',
			string.fu(gendata[a].ext), ' generazione =='})
		table.insert(forms, genTable(a, ndex))
	end
	return table.concat{
            table.concat(forms, '\n'),
            msTable(gen, ndex),
            '\n[[Categoria:Sottopagine Sprite e modelli]]'
        }
end

u.AltSprites, u.altsprites, u.alt_sprites =
u.altSprites, u.altSprites, u.altSprites

return u

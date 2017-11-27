--[[

Crea una tabella in cui sono presenti tutte le debolezze e
resistenze di un Pokémon, con tanto di note nel footer.
Per i Pokémon con più forme, crea solo le tabelle
effettivamente diverse, inserendo nel titolo tutte le
forme che condividono la stessa.

Può essere chiamato con il nome di un Pokémon, es:

{{#invoke: DebRes | DebRes | Nidoking }}

O direttamente con tipi e abilità, sia con parametri
posizionali che con con nome, es:

{{#invoke: DebRes | DebRes | Veleno | Terra | Velenopunto | Antagonismo | Forzabruta }}
{{#invoke: DebRes | DebRes | type1=Veleno | type2=Terra | abil1=Velenopunto | abil2=Antagonismo | abild=Clorofilla }}

Può essere chiamato anche con un solo tipo e una sola abilità, es:

{{#invoke: DebRes | DebRes | Spettro | | Levitazione }}
{{#invoke: DebRes | DebRes | type=Spettro | abil=Levitazione }}

Può essere chiamato anche con un solo tipo, es

{{#invoke: DebRes | DebRes | Spettro }}
{{#invoke: DebRes | DebRes | type=Spettro }}

Può essere chiamato anche con due soli tipi, es

{{#invoke: DebRes | DebRes | Veleno | Terra }}
{{#invoke: DebRes | DebRes | type1=Veleno | type2=Terra }}

Si potrebbe anche mescolare notazione posizionale e con nome, ma
consiglio vivamente di NON FARLO

--]]

local dr = {}

local mw = require('mw')

local box = require('Box')
local et = require('EffTipi')
local link = require('Links')
local w = require('Wikilib')
local abillib = require('Wikilib-abils')
local forms = require('Wikilib-forms')
local list = require('Wikilib-lists')
local oop = require('Wikilib-oop')
local txt = require('Wikilib-strings')
local tab = require('Wikilib-tables')
local alts = require("AltForms-data")
local css = require('Css')
local abilData = require("PokéAbil-data")
local pokes = require("Poké-data")

--[[

Questa classe rappresenta una tabella di efficacia
tipi. Primariamente, contiene informazioni riguardo
l'efficacia dei vari tipi di attacchi contro un
certo Pokémon (o forma alternativa), ovvero contro
una certa combinazione di tipi e abilità; oltre a
ciò, possiede le righe che compongono il footer e
le forme che hanno tali dati di efficacia tipi.

--]]
dr.EffTable = oop.makeClass(list.Labelled)

-- Stringhe utili
dr.EffTable.strings = {

	--[[
		Wikicode per la parte iniziale di un box
		(Debolezze, Immunità, Danno Normale, ecc)
	--]]
	BOX_INIT = [=[<div class="roundy flex flex-row flex-wrap flex-items-stretch" style="padding: 0.5em 0; margin: 0;"><span class="inline-flex flex-items-center flex-main-center width-xl-30 width-xs-100" style="padding: 0.3em;">'''${text}'''</span><div class="flex flex-row flex-wrap flex-items-stretch roundy width-xl-70 width-xs-100" style="border-spacing: 0; padding: 0;">]=],
	
	-- Wikicode per una riga di tipi aventi la stessa efficacia
	BOX_LINE = [=[<div class="flex flex-row flex-wrap flex-items-stretch width-xl-100" style="padding: 0.1em;"><div class="inline-flex flex-items-center flex-main-center roundy width-xl-5 width-sm-10 width-xs-100" style="padding: 0 0.2em; background: #FFF;">${eff}&times;</div><div class="inline-flex flex-row flex-wrap flex-items-center flex-main-start width-xl-95 width-sm-90 width-xs-100" style="padding-left: 0.2em;">${types}</div></div>]=],
}

--[[

Tutte i possibili moltiplicatori dell'efficacia,
considerando anche le triple resistenze e gli
effetti di Filtro/Solidroccia e Pellearsa

--]]
dr.EffTable.allEff = {0, 0.25, 0.5, 1, 2, 4, -- Standard
-- 0.125, -- Tripla resistenza (al momento inutile)
-- 0.3125, 0.625, 1.25, 2.5, 5, -- Pellearsa (al momento inutile)
1.5, 3 -- Filtro/Solidroccia
}

--[[

Visualizzazione dei moltiplicatori di efficacia,
se diversa dal semplice numero

--]]
dr.EffTable.effStrings = {
	[0.5] = '½',
	[0.25] = '¼'
}

--[[

Ritorna la visualizzazione dell'efficacia, se
presente, altrimenti semplicemente il numero
con la virgola come separatore decimale

--]]
dr.EffTable.displayEff = function(eff)
	return dr.EffTable.effStrings[eff] or
		(tostring(eff):gsub('%.', ','))
end

--[[

Ritorna true se bisogna aggiungere una
riga del footer di categoria MAYBE per
una certa abilità, dati i tipi del Pokémon.
Ciò accade se l'abilità non modifica
l'efficacia di tipi a cui i tipi propri
del Pokémon danno già immunità

--]]
dr.EffTable.shouldAddMaybe = function(abil, types)
	local abilMod = et.modTypesAbil[abil]
	local immType1 = et.typesHaveImm[types.type1]
	local immType2 = et.typesHaveImm[types.type2]

	if not abilMod then
		return false
	end
	if not (immType1 or immType2) then
		return true
	end

	for k, type in pairs(abilMod) do
		if immType1 and table.search(immType1, type)
				or immType2 and table.search(immType2, type) then
			return false
		end
	end
	return true
end

--[[

Usata per il sorting delle righe dei tipi
aventi la stessa efficacia, fa in modo che
vengano ordinate per efficacia decrescente

--]]
dr.EffTable.greatestEffFirst = function(line0, line1)
	return line0.eff > line1.eff
end

-- Stampa i tipi dati come Boxes tipi
dr.EffTable.printTypes = function(types)
	return box.listTipoLua(types, ' inline-block width-xl-15 width-md-20 width-sm-35 width-xs-45',
		'margin: 0.3ex; padding: 0.3ex 0; line-height: 3ex; font-weight: bold;')
end

-- Crea la table dei colori, prendendo i dati da types
dr.EffTable.createColors = function(this, types)
	this.colors = {
		type1 = types.type1,
		type2 = types.type2,
	}
end

--[[

Stampa una riga di tipi aventi la stessa
efficacia, aggiungendo il bordo inferiore
se indicato

--]]
dr.EffTable.printEffLine = function(data, roundy)
	return string.interp(dr.EffTable.strings.BOX_LINE,
		{
			rd = roundy or '',
			eff = dr.EffTable.displayEff(data.eff),
			types = dr.EffTable.printTypes(data.types),
		})
end

-- Stampa un singolo box (Debolezze, Immunità, Danno Normale, ecc)
dr.EffTable.printSingleBox = function(boxData, colors)

	--[[
		Il controllo andrebbe comunque fatto dopo la
		seconda table.remove, ma qui è più leggibile
	--]]
	if #boxData == 1 then
		return string.interp(table.concat{dr.EffTable.strings.BOX_INIT,
				dr.EffTable.printEffLine(boxData[1]), '</div></div>'},
		{
			text = boxData.text,
		})
	end
	
	-- Prima e ultima riga hanno l'efficacia arrotondata
	local firstLine = dr.EffTable.printEffLine(table.remove(boxData, 1),
			'top', colors)
	local lastLine = dr.EffTable.printEffLine(table.remove(boxData),
			'bottom')
	
	-- Controllo superfluo, ma il caso con due righe è molto comune
	local allLines
	if #boxData > 0 then
		allLines = table.map(boxData, function(lineData)
				if type(lineData) == 'table' then
					return dr.EffTable.printEffLine(lineData, '', colors)
				end
			end)
	else
		allLines = {}
	end
	
	table.insert(allLines, 1, firstLine)
	table.insert(allLines, lastLine)
	allLines = table.concat(allLines)
	return string.interp(table.concat{dr.EffTable.strings.BOX_INIT,
			allLines, '</div></div>'},
		{
			text = boxData.text,
		})
end

--[[

Stampa i boxes (Debolezze, Resistenze, ecc)
passati solo se hanno almeno una riga

--]]
dr.EffTable.printEffBoxes = function(boxes, colors)
	boxes = table.filter(boxes, function(box)
			return type(box) ~= 'table' or #box > 0
	end)
	return w.mapAndConcat(boxes, function(box)
			return dr.EffTable.printSingleBox(box, colors)
		end)
end

--[[

Costruttore della classe: ha in ingresso il
nome del Pokémon, nella forma nome + sigla,
e, opzionalmente, il nome esteso della forma

--]]
dr.EffTable.new = function(name, formName)
	local types, abils

	if type(name) == 'table' and type(formName) == 'table' then
		types = table.map(name, string.lower)
		abils = table.map(formName, string.lower)
	else
		types = pokes[name]
		abils = table.map(abillib.lastAbils(abilData[name]), string.lower)
	end

	local this = setmetatable(dr.EffTable.super.new(formName),
			dr.EffTable)
	this.collapse = ''
	
	-- Dati per la stampa
	this:createColors(types)
	
	local onlyAbil = table.getn(abils) == 1
	
	--[[
		Se l'abilità non è unica, il calcolo
		dell'efficacia va fatto senza abilità,
		poiché se ne terrà conto nel footer
	--]]
	local abil = onlyAbil and abils.ability1 or 'tanfo'
	
	--[[
		Per ogni possibile efficacia, se vi sono
		tipi che la hanno, inserisce una table
		con i loro nomi all'indice dell'efficacia
		stessa
	--]]
	for k, eff in ipairs(dr.EffTable.allEff) do
		local types = et.difesa(eff, types.type1, types.type2, abil)
		if #types > 0 then

			--[[
				I tipi devono essere ordinati per il
				confronto e la conversione a stringa
			--]]
			table.sort(types)
			this[eff] = types
		end
	end
	
	--[[
		Contiene le righe del footer sotto forma di
		istanze di dr.EffTable.FooterLine
	--]]
	this.footer = {}
	
	if abil ~= 'magidifesa' then
		if et.typesHaveImm[types.type1] then
			table.insert(this.footer, dr.EffTable.FooterLine.new('RINGTARGET',
					types, abils))
		end
		
		--[[
			I tipi vanno scambiati perché il costruttore
			di dr.EffTable.FooterLine controlla solo il primo
		--]]
		if not (types.type1 == types.type2) and et.typesHaveImm[types.type2] then
			table.insert(this.footer, dr.EffTable.FooterLine.new('RINGTARGET',
					{type1 = types.type2, type2 = types.type1}, abils))
		end
	end

	if onlyAbil then
		if et.modTypesAbil[abil] then
			table.insert(this.footer, dr.EffTable.FooterLine.new('TAKENOFF',
					types, abil))
		end
	else
		
		-- Can't use table.map because of string indexes
		for key, abil in pairs(abils) do
			if dr.EffTable.shouldAddMaybe(abil, types) then
				table.insert(this.footer, dr.EffTable.FooterLine.new('MAYBE',
						types, abil))
			end
		end
	end
	
	-- Va mantenuta ordinata per il contronfo e la stampa
	table.sort(this.footer)

	return this
end

--[[

Operatore di uguaglianza: ritorna true se sono uguali sia
i footer che i valori di efficacia con i tipi associati

--]]
dr.EffTable.__eq = function(a, b)
	if not table.equal(a.footer, b.footer) then
		return false
	end
	
	--[[
		Si scorre dr.EffTable.allEff perché se si
		scorresse a o b si potrebbe non controllare
		tutti i valori di efficacia dell'altro
	--]]
	for k, eff in pairs(dr.EffTable.allEff) do
		if not table.equal(a[eff], b[eff]) then
			return false
		end
	end

	return true
end

--[[

Setta le classi css per l'espandibilità,
dunque se la tabella sarà espandibile e
se sarà ridotta o meno di default

--]]
dr.EffTable.setCollapse = function(this, collapse)
	this.collapse = collapse
end

--[[

Stampa la tabella dell'efficacia tipi in
WikiCode: inserisce solo i valori di
efficacia almeno un tipo e il footer se
ha almeno una riga

--]]
dr.EffTable.__tostring = function(this)
	local weak = {text = 'Debolezze'}
	local std = {text = 'Danno normale'}
	local res = {text = 'Resistenze'}
	local imm = {text = 'Immunit&agrave;'}

	local interpData = {
		bg = css.horizGradLua{type1 = this.colors.type1, type2 = this.colors.type2},
		foot = #this.footer < 1 and '' or string.interp([=[<div class="roundy text-left text-small" style="padding: 0.5em 0; margin: 0;">${lines}</div>]=],
				{
					lines = w.mapAndConcat(this.footer, tostring)
				})
	}
	
	-- Non si può usare ipairs perché gli indici non sono interi
	for eff, types in pairs(this) do
		if type(eff) == 'number' then
			--[[
				Non si usa eff come indice perché così le tables
				sono ordinabili, avendo indici interi
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

	-- È inutile ordinare imm e std, hanno un solo elemento
	table.sort(res, dr.EffTable.greatestEffFirst)
	table.sort(weak, dr.EffTable.greatestEffFirst)
	
	interpData.effBoxes = dr.EffTable.printEffBoxes({weak, std,
			res, imm}, this.colors)
	
	local tab = string.interp([[<div class="roundy pull-center text-center width-xl-80 width-md-100" style="padding: 0.5ex; padding-bottom: 0.01ex; ${bg}">${effBoxes}${foot}</div>]], interpData)

	if #this.labels > 0 then
		return string.interp([[==== ${title} ====
<div class="${collapse}">
${tab}
</div>]],
			{
				title = mw.text.listToText(this.labels, ', ', ' e '),
				collapse = this.collapse or '',
				tab = tab
			})
	end

	return tab
end

--[[

Questa classe rappresenta una riga del footer;
per fare ciò maniente informazioni sulla
categoria di riga, sulla parte iniziale del
testo della riga e sui tipi che cambiano
efficacia, associandoli alla nuova.

Le possibili categorie di riga sono tre:
	- MAYBE: usata quando un Pokémon potrebbe
		avere una certa abilità, poiché ne ha
		più di una possibile; indica l'efficacia
		dei tipi in presenza di detta abilità
	- TAKENOFF: usata per i Pokémon che hanno
		una sola abilità possibile, indica che
		le informazioni sono relative al caso 
		in cui il Pokémon perda l'abilità
	- RINGTARGET: usata con i Pokémon che hanno
		immunità dovute ai tipi, indica
		l'efficacia dei tipi verso cui si ha
		immunità nel caso queste siano perse

--]]
dr.EffTable.FooterLine = oop.makeClass()

-- Stringhe utili
dr.EffTable.FooterLine.strings = {

	-- Inizio del testo del footer per la categoria MAYBE
	MAYBE = 'Se questo Pok&eacute;mon ha [[${abil} (abilità)|${abil}]] ',

	-- Inizio del testo del footer per la categoria TAKENOFF
	TAKENOFF = 'Se questo Pok&eacute;mon perde [[${abil} (abilità)|${abil}]], o se ne sono annullati gli effetti, ',
		
	-- Inizio del testo del footer per la categoria RINGTARGET
	RINGTARGET = 'Se questo Pok&eacute;mon tiene un [[Facilsaglio]]',
	
	-- Stringhe da concatenare a RINGTARGET per alcuni tipi
	SPETTRO = ', se un avversario usa [[Preveggenza (mossa)|Preveggenza]] o [[Segugio (mossa)|Segugio]] o ha [[Nervisaldi (abilità)|Nervisaldi]], ',
	BUIO = ' o se un avversario usa [[Miracolvista (mossa)|Miracolvista]], ',
	VOLANTE = ' o una [[Ferropalla]] o se viene usata [[Gravità (mossa)|Gravit&agrave;]], ',
	
	--[[
		Stringhe da concatenare a RINGTARGET quando un'
		abilità e un il tipo danno la stessa immunità
	--]]
	NOT_HAVE_ABIL = 'e se non ha [[${abil} (abilità)|${abil}]], ',
	IMM_TAKENOFF = 'e se ha perso [[${abil} (abilità)|${abil}]] o ne sono stati annullati gli effetti, ',
	
	-- Testo per la nuova efficacia
	EFF = "l'efficacia delle mosse di tipo ${types} &egrave; pari a ${eff}×"
}

-- Ordine delle categorie, per l'ordinamento delle righe
dr.EffTable.FooterLine.kindOrder = {'MAYBE', 'TAKENOFF', 'RINGTARGET'}

--[[

Ritorna true se abil dà immunità a type.
Si verifica che l'efficacia di type su
un ipotetico Pokémon che non ha immunità
derivanti dai tipi sia nulla

--]]
dr.EffTable.FooterLine.abilityGrantsImm = function(abil, type)
	return 0 == et.efficacia(type, 'elettro', 'elettro', abil)
end

--[[

Contiene funzioni che generano la parte iniziale
del footer in base alla categoria

--]]
dr.EffTable.FooterLine.init = {}

-- Parte iniziale per la categoria MAYBE
dr.EffTable.FooterLine.init.MAYBE = function(abil)
	return string.interp(dr.EffTable.FooterLine.strings.MAYBE,
			{abil = txt.camelCase(abil)})
end

-- Parte iniziale per la categoria TAKENOFF
dr.EffTable.FooterLine.init.TAKENOFF = function(abil)
	return string.interp(dr.EffTable.FooterLine.strings.TAKENOFF,
			{abil = txt.camelCase(abil)})
end

--[[

Parte iniziale per la categoria RINGTARGET:
aggiunge le stringhe necessarie per alcuni
tipi e abilità e concatena il tutto

--]]
dr.EffTable.FooterLine.init.RINGTARGET = function(abils, type)
	local pieces = {dr.EffTable.FooterLine.strings.RINGTARGET}

	table.insert(pieces, dr.EffTable.FooterLine.strings[type:upper()]
			or ' ')
	
	--[[
		Se l'abilità è una sola, bisogna inserire una
		stringa diversa in caso di immunità condivise
	--]]
	local notAbil = table.getn(abils) == 1
			and dr.EffTable.FooterLine.strings.IMM_TAKENOFF
			or dr.EffTable.FooterLine.strings.NOT_HAVE_ABIL
	
	--[[
		Per ogni abilità, controlla se ha un'immunità
		condivisa con il tipo del footer, e in tal caso
		inserisce una stringa a tal proposito
	--]]
	for k, abil in pairs(abils) do
		for k, typeImm in pairs(et.typesHaveImm[type:lower()]) do
			if dr.EffTable.FooterLine.abilityGrantsImm(abil, typeImm) then
				table.insert(pieces, string.interp(notAbil,
						{abil = txt.camelCase(abil)}))
			end
		end
	end
	return table.concat(pieces)
end

--[[

Costruttore della classe: ha in ingresso la
categoria di riga, i tipi e una sola abilità,
fatta eccezione per la categoria RINGTARGET
in cui si hanno invece tutte le abilità.

--]]
dr.EffTable.FooterLine.new = function(kind, types, abil)
	local this = setmetatable({}, dr.EffTable.FooterLine)
	
	kind = kind:upper()
	types = table.map(types, string.lower)
	abil = type(abil) ~= 'table' and abil:lower() or
			table.map(abil, string.lower)
	
	-- La categoria di riga
	this.kind = kind
	
	-- La parte iniziale della riga del footer
	this.init = '\n*' .. dr.EffTable.FooterLine.init[kind](abil, types.type1)
	
	--[[
		Per ogni nuova efficacia ha una subtable
		con i tipi che hanno detta efficacia: tali
		subtables vanno tenute ordinate per la
		conversione a stringa stampa e il confronto
		con table.equal
	--]]
	this.newEff = {}

	--[[
		Filtro, Solidroccia, Scudoprisma e Magidifesa sono
		casi particolari da trattare separatamente,
		ammesso che si stia creando una riga relativa
		alle abilità
	--]]
	if kind ~= 'RINGTARGET' then
		if abil == 'filtro' or abil == 'solidroccia' or abil == 'scudoprisma' then
		
			--[[
				Se l'abilità viene persa, la nuova
				efficacia è piena, altrimenti ridotta
			--]]
			local xKeys
			if kind == 'TAKENOFF' then
				xKeys = {[2] = 2, [4] = 4}
			else
				xKeys = {[2] = 1.5, [4] = 3}
			end
			
			for k, v in pairs(xKeys) do
				local x = et.difesa(k, types.type1, types.type2, 'tanfo')
				if #x > 0 then
					table.sort(x) -- Vedi commento a this.newEff
					this.newEff[v] = x
				end
			end
			
			return this
		elseif abil == 'magidifesa' then
		
			--[[
				Un footer standard sarebbe troppo lungo per
				Magidifesa, inoltre è, e molto probabilmente
				resterà, abilità peculiare di Shedinja. Si
				opta quindi per una gestione custom.
			--]]
			this.tostring = string.interp(table.concat{'\n*', dr.EffTable.FooterLine.strings.TAKENOFF,
					[=[solo mosse di tipo ${normale} e ${lotta} non lo renderanno esausto.]=]},
					{
						abil = 'Magidifesa',
						normale = link.colorType('Normale'),
						lotta = link.colorType('Lotta')
					})
			
			return this
		end
	end
	
	local newTypes
	if kind == 'RINGTARGET' then
	
		--[[
			Se si controllano le immunità e il Pokémon
			ha un solo tipo la nuova efficacia è 1x
		--]]
		if types.type1 == types.type2 then
			this.newEff[1] = et.typesHaveImm[types.type1]
			table.sort(this.newEff[1]) -- Vedi commento a this.newEff
			
			return this
		else
			newTypes = et.typesHaveImm[types.type1]
			
			--[[
				Quando perde l'immunita, ai fini del
				calcolo danni il Pokémon è monotipo
			--]]
			types.type1 = types.type2
		end
	else
		newTypes = et.modTypesAbil[abil]
		
		--[[
			Se la categoria è TAKENOFF l'abilità non va
			considerata nel calcolo danni del footer
		--]]
		abil = kind == 'TAKENOFF' and 'tanfo' or abil 
	end
	table.sort(newTypes) -- Vedi commento a this.newEff

	--[[
		Per ogni tipo in newTypes calcola la nuova
		efficacia, e se questa esiste non esiste
		la crea, altrimenti aggiunge il tipo a
		quelli già presenti
	--]]
	for k, type in ipairs(newTypes) do
		local eff = et.efficacia(type, types.type1,
				types.type2, abil)
		if this.newEff[eff] then
			table.insert(this.newEff[eff], type)
		else
			this.newEff[eff] = {type}
		end
	end
	
	return this
end	

--[[

Operatore di uguaglianza: ritorna true
se le due FooterLine hanno entrambi
il membro tostring, o se nessuna delle
due lo ha e hano uguali sia init che
newEff

--]]
dr.EffTable.FooterLine.__eq = function(a, b)
	return a.tostring and b.tostring 
		or not (a.tostring or b.tostring)
			and a.init == b.init
			and table.equal(a.newEff, b.newEff)
end

--[[

Operatore minore, per l'ordinamento:
confronta gli indici delle categorie in
dr.EffTable.FooterLine.kindOrder e in caso
di uguaglianza i testi iniziali

--]]
dr.EffTable.FooterLine.__lt = function(a, b)
	local aIndex = table.search(dr.EffTable.FooterLine.kindOrder, a.kind)
	local bIndex = table.search(dr.EffTable.FooterLine.kindOrder, b.kind)
	return aIndex == bIndex and a.init < b.init or aIndex < bIndex
end

--[[

Conversione a stringa.

Per ogni efficacia crea la stringa con
l'elenco dei tipi corrispondenti in campo
colorato, per poi concatenarle tutte alla
parte iniziale

--]]
dr.EffTable.FooterLine.__tostring = function(this)
	if this.tostring then
		return this.tostring
	end

	local newEff = {}
	--[[
		Can't use table.map because this.newEff has
		string index, that won't work with table.concat
	--]]
	for eff, types in pairs(this.newEff) do
		local colorTypes = table.map(types, function(type)
				return link.colorType(type)
			end)
		table.insert(newEff, string.interp(dr.EffTable.FooterLine.strings.EFF,
				{
					types = mw.text.listToText(colorTypes, ', ', ' e '),
					eff = dr.EffTable.displayEff(eff)
				}))
	end
	
	return table.concat{this.init, mw.text.listToText(newEff, ', ', ' e '), '.'}
end

--[[

Ritorna il wikicode per una table di dr.EffTables:
la prima è espansa e le successive collassate.

--]]
dr.EffTable.printEffTables = function(EffTables)

	-- Se c'è una sola table non bisogna far collassare niente
	if #EffTables == 1 then
		return tostring(EffTables[1])
	end
		
	--[[
		Si rendono tutte le tables collasabili e tutte
		tranne la prima collassate di default
	--]]
	return w.mapAndConcat(EffTables, function(EffTable, key)
			EffTable:setCollapse('mw-collapsible' ..
					(key == 1 and '' or ' mw-collapsed'))
			return tostring(EffTable)
		end, '\n')
end

--[[

Funzione d'interfaccia al wikicode: prende in ingresso
il nome di un Pokémon, il suo ndex o una combo tipi +
abilità e genera le table dell'efficacia tipi. Se il 
Pokémon ha più forme, ritorna una table per ogni forma,
tutte collassabili con solo quella della forma base
estesa al caricamento della pagina.

--]]
dr.debRes = function(frame)
	local p = w.trimAndMap(mw.clone(frame.args), string.lower)
	local pokeData = pokes[string.parseInt(p[1]) or p[1]]
			or pokes[mw.text.decode(p[1])]
	
	--[[
		If no data is found, the first parameter is
		the type, that is no Pokémon is given and
		types and abilities are directly provided
	--]]
	if not pokeData then
		local types, abils = {}, {}
		types.type1 = p[1] or p.type1 or p.type
		types.type2 = p[2] or p.type2 or types.type1
		abils.ability1 = p[3] or p.abil1 or p.abil
		abils.ability2 = p[4] or p.abil2
		abils.abilityd = p[5] or p.abild
		return tostring(dr.EffTable.new(types, abils))
	end

	return list.makeFormsLabelledBoxes({
		name = pokeData.name:lower(),
		makeBox = dr.EffTable.new,
		printBoxes = dr.EffTable.printEffTables
	})
end

dr.DebRes, dr.debres = dr.debRes, dr.debRes

return dr

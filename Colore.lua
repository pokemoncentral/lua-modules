-- Modulo contenente i vecchi template colori

-- Ogni funzione ritorna la stringa esadecimale di colore relativa.  Nel wikicode si invoca così:
-- {{#invoke: colore|fuoco}}
-- È possibile aggiungere un parametro "light" o "dark" per ottenere il colore modificato:
-- {{#invoke: colore|fuoco|light}}

local c = {}
local tab = require('Modulo:Wikilib/tables') -- luacheck: no unused
local txt = require('Modulo:Wikilib/strings') -- luacheck: no unused

-- Questa è la funzione principale che viene chiamata da (quasi) tutte le altre.
-- Restituisce il codice esadecimale giusto per la variante richiesta.

local function _colore(variante, normale, light, dark)
    variante = string.trim(variante:lower())
    local colors = {normale = normale, light = light,
        dark = dark, med = normale}
    return colors[variante] or 'Errore'
end

-- Colori tipi

c.acciaio = function(frame) return _colore(frame.args[1] or 'normale', 'AAAABB', 'DFDFE1', '74747B') end
c.acqua = function(frame) return _colore(frame.args[1] or 'normale', '3399FF', '9FCEFF', '0D6AC8') end
c.buio = function(frame) return _colore(frame.args[1] or 'normale', '775544', 'BDA396', '442C21') end
c.coleottero = function(frame) return _colore(frame.args[1] or 'normale', 'AABB22', 'DAEC44', '849400') end
c.coleot = c.coleottero
c.drago = function(frame) return _colore(frame.args[1] or 'normale', '7766EE', 'A194FF', '31229D') end
c.elettro = function(frame) return _colore(frame.args[1] or 'normale', 'FFCC33', 'FFEEBC', 'BD8E00') end
c.erba = function(frame) return _colore(frame.args[1] or 'normale', '77CC55', 'BDFFA3', '299100') end
c.folletto = function(frame) return _colore(frame.args[1] or 'normale', 'FFAAFF', 'FFDDFF', 'EC67EA') end
c.fuoco = function(frame) return _colore(frame.args[1] or 'normale', 'FF4422', 'FF927D', 'BA1F00') end
c.ghiaccio = function(frame) return _colore(frame.args[1] or 'normale', '77DDFF', 'DBF6FF', '13A8D9') end
c.lotta = function(frame) return _colore(frame.args[1] or 'normale', 'BB5544', 'EA9A8D', '912E1E') end
c.normale = function(frame) return _colore(frame.args[1] or 'normale', 'BBBBAA', 'E7E7D8', '8A8A7B') end
c.ombra = function(frame) return _colore(frame.args[1] or 'normale', '604E82', '8674A8', '3E3355') end
c.psico = function(frame) return _colore(frame.args[1] or 'normale', 'FF5599', 'FF9CC4', 'D00053') end
c.roccia = function(frame) return _colore(frame.args[1] or 'normale', 'BBAA66', 'E1D08C', '88762C') end
c.sconosciuto = function(frame) return _colore(frame.args[1] or 'normale', '68A090', '9DC1B7', '44685E') end
c['???'] = c.sconosciuto
c.spettro = function(frame) return _colore(frame.args[1] or 'normale', '6666BB', '9F9FEC', '42428E') end
c.terra = function(frame) return _colore(frame.args[1] or 'normale', 'DDBB55', 'F1DDA0', 'B59226') end
c.veleno = function(frame) return _colore(frame.args[1] or 'normale', 'AA5599', 'C689BA', '792F6A') end
c.volante = function(frame) return _colore(frame.args[1] or 'normale', '6699FF', '9CBDFF', '3678FF') end

-- Alias glitch
-- Aliases with the underscore are needed because of module css

c.Glitch, c.glitch = c.sconosciuto, c.sconosciuto
c.IIIItoto, c.iiiitoto, c.Uccello, c.uccello =
    c.sconosciuto, c.sconosciuto, c.sconosciuto, c.sconosciuto
c['6!2?2 A'], c['6!2?2 a'], c['x v zA'], c['x v za'] =
    c.sconosciuto, c.sconosciuto, c.sconosciuto, c.sconosciuto
c['6!2?2_A'], c['6!2?2_a'], c['x_v_zA'], c['x_v_za'] =
    c.sconosciuto, c.sconosciuto, c.sconosciuto, c.sconosciuto
c.L, c.l, c.B, c.b = c.sconosciuto, c.sconosciuto, c.sconosciuto, c.sconosciuto
c[',K Pk(nome del giocatore)xX'], c[',k pk(nome del giocatore)xx'] =
    c.sconosciuto, c.sconosciuto
c[',K_Pk(nome_del_giocatore)xX'], c[',k_pk(nome_del_giocatore)xx'] =
    c.sconosciuto, c.sconosciuto
c['Allen. Jr ♀'], c['allen. jr ♀'], c['Allen._Jr_♀'], c['allen._jr_♀'] =
    c.sconosciuto, c.sconosciuto, c.sconosciuto, c.sconosciuto
c['Normale (glitch)'], c['normale (glitch)'], c['Normale_(glitch)'], c['normale_(glitch)'] =
    c.sconosciuto, c.sconosciuto, c.sconosciuto, c.sconosciuto
c["Pokémaniaco"], c['pokémaniaco'] = c.sconosciuto, c.sconosciuto
c["'l) m) ZM"], c["'l) m) zm"], c["'l)_m)_ZM"], c["'l)_m)_zm"] =
    c.sconosciuto, c.sconosciuto, c.sconosciuto, c.sconosciuto
c["(Classe dell'ultimo allenatore affrontato)"] =
    c.sconosciuto
c["(Classe_dell'ultimo_allenatore_affrontato)"] =
    c.sconosciuto
c["(classe dell'ultimo allenatore affrontato)"] =
    c.sconosciuto
c["(classe_dell'ultimo_allenatore_affrontato)"] =
    c.sconosciuto
c['Qi JT(nome del giocatore)? POké BB(nome del Pokémon) de W N'] =
    c.sconosciuto
c['Qi_JT(nome_del_giocatore)?_POké_BB(nome_del_Pokémon)_de_W_N'] =
    c.sconosciuto
c['qi jt(nome del giocatore)? poké bb(nome del pokémon) de w n'] =
    c.sconosciuto
c['qi_jt(nome_del_giocatore)?_poké_bb(nome_del_pokémon)_de_w_n'] =
    c.sconosciuto
c['Poké BB'], c['poké bb'], c['Poké_BB'], c['poké_bb'] =
    c.sconosciuto, c.sconosciuto, c.sconosciuto, c.sconosciuto
c['8 8 9 5'], c['8_8_9_5'], c['999'], c['?'] =
    c.sconosciuto, c.sconosciuto, c.sconosciuto, c.sconosciuto
c['66848.04'], c["' ♀ ♀ ' 2222 37572"], c["'_♀_♀_'_2222_37572"] =
    c.sconosciuto, c.sconosciuto, c.sconosciuto

-- Colori attacchi

c.fisico = function(frame) return _colore(frame.args[1] or 'normale', 'C92112', 'D96358', '82150B') end
c.fisico_text = function(frame) return 'F67A1A' end
c.speciale = function(frame) return _colore(frame.args[1] or 'normale', '4F5870', '83899A', '333948') end
c.speciale_text = function(frame) return 'FFFFFF' end
c.stato = function(frame) return _colore(frame.args[1] or 'normale', '8C888C', 'AEABAE', '5B585B') end
c.stato_text = function(frame) return 'F7F7F7' end

-- Colori versioni

c.verde = function(frame) return _colore(frame.args[1] or 'normale', '11BB11', 'A7DB8D', '0B7A0B') end
c.rosso = function(frame) return _colore(frame.args[1] or 'normale', 'FF1111', 'FF7777', 'A60B0B') end
c.blu = function(frame) return _colore(frame.args[1] or 'normale', '1111FF', '7777FF', '0B0BA6') end
c.giallo = function(frame) return _colore(frame.args[1] or 'normale', 'FFD733', 'FFE57A', 'A68C21') end
c.oro = function(frame) return _colore(frame.args[1] or 'normale', 'DAA520', 'E7C46E', '8E6B15') end
c.argento = function(frame) return _colore(frame.args[1] or 'normale', 'C0C0C0', 'D6D6D6', '7D7D7D') end
c.cristallo = function(frame) return _colore(frame.args[1] or 'normale', '4FD9FF', '8CE6FF', '338DA6') end
c.rubino = function(frame) return _colore(frame.args[1] or 'normale', 'A00000', 'D42E2E', '680000') end
c.zaffiro = function(frame) return _colore(frame.args[1] or 'normale', '0000A0', '5959C1', '000068') end
c.rosso_fuoco = function(frame) return _colore(frame.args[1] or 'normale', 'FF7327', 'FFA472', 'A64B19') end
c.rosso_Fuoco = c.rosso_fuoco
c.verde_foglia = function(frame) return _colore(frame.args[1] or 'normale', '00DD00', '59E959', '015701') end
c.verde_Foglia = c.verde_foglia
c.smeraldo = function(frame) return _colore(frame.args[1] or 'normale', '00A000', '2ED42E', '006800') end
c.diamante = function(frame) return _colore(frame.args[1] or 'normale', 'AAAAFF', 'CCCCFF', '6F6FA6') end
c.perla = function(frame) return _colore(frame.args[1] or 'normale', 'FFAAAA', 'FFC8C8', 'A66F6F') end
c.platino = function(frame) return _colore(frame.args[1] or 'normale', '999999', 'BDBDBD', '646464') end
c.heartgold = function(frame) return _colore(frame.args[1] or 'normale', 'B69E00', 'CEB654', '766700') end
c.heartGold = c.heartgold
c.soulsilver = function(frame) return _colore(frame.args[1] or 'normale', 'C0C0E1', 'D6D6EB', '7D7D92') end
c.soulSilver = c.soulsilver
c.nero = function(frame) return _colore(frame.args[1] or 'normale', '444444', '858585', '2C2C2C') end
c.bianco = function(frame) return _colore(frame.args[1] or 'normale', 'C3C3C3', 'D8D8D8', '7F7F7F') end
c.nero_2 = function(frame) return _colore(frame.args[1] or 'normale', '424B50', '848A8D', '2B3134') end
c.bianco_2 = function(frame) return _colore(frame.args[1] or 'normale', 'E3CED0', 'EDDFE0', '948687') end
c.x = function(frame) return _colore(frame.args[1] or 'normale', '025DA6', '5A96C5', '013D6C') end
c.y = function(frame) return _colore(frame.args[1] or 'normale', 'EA1A3E', 'F16A81', '981128') end
c.rubino_omega = function(frame) return _colore(frame.args[1] or 'normale', 'AB2813', 'C87365', '6F1A0C') end
c.rubino_Omega = c.rubino_omega
c.zaffiro_alpha = function(frame) return _colore(frame.args[1] or 'normale', '26649C', '729ABF', '194166') end
c.zaffiro_Alpha = c.zaffiro_alpha
c.sole = function(frame) return _colore(frame.args[1] or 'normale', 'F2952D', 'FFC587', 'A45500') end
c.luna = function(frame) return _colore(frame.args[1] or 'normale', '5599C8', '9ACFF4', '155785') end
c.ultrasole = function(frame) return _colore(frame.args[1] or 'normale', 'EE7936', 'FFB58C', 'B54000') end
c.ultraluna = function(frame) return _colore(frame.args[1] or 'normale', '884799', 'AF8DB7', '440E52') end
c.lgp = function(frame) return _colore(frame.args[1] or 'normale', 'FFCF11', 'FFF4C3', 'D09E2A') end
c.LG_Pikachu, c.LG_pikachu, c.LGP, c.lgpikachu, c["Let's Go, Pikachu!"] = c.lgp, c.lgp, c.lgp, c.lgp, c.lgp
c.lge = function(frame) return _colore(frame.args[1] or 'normale', 'C47E39', 'F9C876', '6A3F31') end
c.LG_Eevee, c.LG_eevee, c.LGE, c.lgeevee, c["Let's Go, Eevee!"] = c.lge, c.lge, c.lge, c.lge, c.lge
c.colo = function(frame) return _colore(frame.args[1] or 'normale', 'B6CAE4', 'CFDCED', '768394') end
c.colosseum = c.colo
c.xd = function(frame) return _colore(frame.args[1] or 'normale', '604E82', '8674A8', '3E3355') end
c.XD = c.xd
c.br = function(frame) return _colore(frame.args[1] or 'normale', 'DCA202', 'FFD461', '684D02') end
c.battle_revolution = c.br
c.md = function(frame) return _colore(frame.args[1] or 'normale', 'D78144', 'DECAA9', '7C4B2D') end
c.MD = c.md
c.md_rosso = function(frame) return _colore(frame.args[1] or 'normale', 'C50C50', 'D85C8A', '840836') end
c.md_blu = function(frame) return _colore(frame.args[1] or 'normale', '095BAF', '5A91C9', '063D75') end
c.md_tempo = function(frame) return _colore(frame.args[1] or 'normale', '2190C7', '6AB5D9', '166185') end
c['md_oscurità'] = function(frame) return _colore(frame.args[1] or 'normale', 'C3141B', 'D76166', '830D12') end
c.md_cielo = function(frame) return _colore(frame.args[1] or 'normale', '7BB54F', 'A6CD89', '527935') end
c.md_portali = function(frame) return _colore(frame.args[1] or 'normale', '7D6A7A', 'AE9EAC', '4D3249') end
c.md_super = function(frame) return _colore(frame.args[1] or 'normale', 'A5A3D2', 'CCC9FF', '7471A6') end
c.super_md = c.md_super
c.ranger = function(frame) return _colore(frame.args[1] or 'normale', 'F7681A', 'FA9D6A', 'A14411') end
c.osa = function(frame) return _colore(frame.args[1] or 'normale', '2D4B98', '768ABC', '1D3163') end
c.osA = c.osa
c.tl = function(frame) return _colore(frame.args[1] or 'normale', '2CB8E9', '76D1F1', '1D7898') end
c.TL = c.tl
c.conquest = function(frame) return _colore(frame.args[1] or 'normale', 'EC9722', 'F8DF9D', '945F13') end

-- Colori regioni

c.kanto = function(frame) return _colore(frame.args[1] or 'normale', 'FF3600', 'FFA48C', '6A0000') end
c.johto = function(frame) return _colore(frame.args[1] or 'normale', 'FF7D00', 'FFC791', '9D4E00') end
c.hoenn = function(frame) return _colore(frame.args[1] or 'normale', 'FFC300', 'FFF99A', 'BA8300') end
c.sinnoh = function(frame) return _colore(frame.args[1] or 'normale', '00DB05', '96FF96', '008303') end
c.unima = function(frame) return _colore(frame.args[1] or 'normale', '00A2FF', 'A3DDFF', '0057CD') end
c.unova = c.unima
c.settipelago = function(frame) return _colore(frame.args[1] or 'normale', '52CC91', '8DEBBC', '2B915E') end
c.auros = function(frame) return _colore(frame.args[1] or 'normale', '817548', 'ADA588', '544C2F') end
c.orre = c.auros
c.kalos = function(frame) return _colore(frame.args[1] or 'normale', 'AE45FF', 'D49CFF', '5A009F') end
c.kalos_centrale = function(frame) return _colore(frame.args[1] or 'normale', 'D1D1D1', 'EAEAEA', 'BBBBBB') end
c.kalosce = c.kalos_centrale
c.kalos_costiera = function(frame) return _colore(frame.args[1] or 'normale', '013D6C', '026FC4', '002847') end
c.kalosco = c.kalos_costiera
c.kalos_montana = function(frame) return _colore(frame.args[1] or 'normale', '981128', 'EA1A3E', '76071A') end
c.kalosmo = c.kalos_montana
c.orange = function(frame) return _colore(frame.args[1] or 'normale', 'FF7F00', 'FFAC59', 'A65300') end
c.alola = function(frame) return _colore(frame.args[1] or 'normale', 'EE82EE', 'FCCAFC', 'AC4BAB') end
c.mele_mele = c.giallo
c.mele_Mele = c.mele_mele
c.akala = c.psico
c.ula_ula = c.rosso
c.ula_Ula = c.ula_ula
c.poni = c.spettro
c.cristalline = function(frame) return _colore(frame.args[1] or 'normale', 'FFB200', 'FFD36B', 'AE7E00') end
c.decolora = c.cristalline

-- Colori statistiche

c['abilità'] = function(frame) return _colore(frame.args[1] or 'normale', '317BEE', '83B4FF', '2052A4') end
c['agilità'] = function(frame) return _colore(frame.args[1] or 'normale', '38BD62', '83EEA4', '188339') end
c.attacco = function(frame) return _colore(frame.args[1] or 'normale', 'EACA2F', 'FFFBE6', 'B88C00') end
c.atk = c.attacco
c.attacco_speciale = function(frame) return _colore(frame.args[1] or 'normale', '26BAE0', 'B2E3EF', '15687D') end
c.spatk = c.attacco_speciale
c.difesa = function(frame) return _colore(frame.args[1] or 'normale', 'E5721D', 'FFC499', '8E3600') end
c.def = c.difesa
c.difesa_speciale = function(frame) return _colore(frame.args[1] or 'normale', '4C6CD4', '9EB5FF', '0A163D') end
c.spdef = c.difesa_speciale
c.forza = function(frame) return _colore(frame.args[1] or 'normale', 'FF4131', 'FF9494', 'BD2018') end
c.ps = function(frame) return _colore(frame.args[1] or 'normale', '58E810', 'E1FFD3', '2E7A08') end
c.PS, c.hp = c.ps, c.ps
c.resistenza = function(frame) return _colore(frame.args[1] or 'normale', 'EECD31', 'FFE683', 'C58308') end
c.speciali = function(frame) return _colore(frame.args[1] or 'normale', '3ECDB4', 'A3FFEF', '179881') end
c.spec = c.speciali
c['velocità'] = function(frame) return _colore(frame.args[1] or 'normale', 'D425CE', 'EF8DEC', '380036') end
c.spe = c['velocità']
c.thlon = function(frame) return _colore(frame.args[1] or 'normale', '90a8e0', 'B7C6EB', '5E6D92') end
c['pokéAthlon'], c['pokéathlon'] = c.thlon, c.thlon

-- Colori zone
-- NB: La regex è {{colorezona/(.*?)|(.*?)}} --> {{#invoke: colore | zona_$2 | $1}}, con le variabili invertite.
-- E prima va fatto {{colorezona/text|(.*?)}} --> {{#invoke: colore | zona_text | $1}}
-- E prima ancora {{colorezona/(.*?)}} --> {{#invoke: colore | zona_terra | $1}}

c.zona_grotta = function(frame) return _colore(frame.args[1] or 'normale', 'CC8F66', 'E0B192', 'A66A42') end
c.zona_cave, c.zona_Grotta, c.zona_caverna = c.zona_grotta, c.zona_grotta, c.zona_grotta
c.zona_terra = function(frame) return _colore(frame.args[1] or 'normale', '75C977', 'A2E0A3', '4AA14D') end
c.zona_Terra, c.zona_land = c.zona_terra, c.zona_terra
c.zona_foresta = function(frame) return _colore(frame.args[1] or 'normale', '3A822D', '71AD64', '34612D') end
c.zona_Foresta, c.zona_bosco, c.zona_forest = c.zona_foresta, c.zona_foresta, c.zona_foresta
c.zona_nebbia = function(frame) return _colore(frame.args[1] or 'normale', 'B5ADC7', 'CAC1DE', '9E98AD') end
c.zona_Nebbia, c.zona_fog = c.zona_nebbia, c.zona_nebbia
c.zona_palude = function(frame) return _colore(frame.args[1] or 'normale', '7792BD', 'BDA595', '3D6633') end
c.zona_Palude, c.zona_marsh = c.zona_palude, c.zona_palude
c.zona_cenere = function(frame) return _colore(frame.args[1] or 'normale', '9C8583', 'B8A09E', '856765') end
c.zona_Cenere, c.zona_ash = c.zona_cenere, c.zona_cenere
c.zona_rovine = function(frame) return _colore(frame.args[1] or 'normale', 'BFB895', 'EBE5CA', '9E9773') end
c.zona_Rovine, c.zona_ruins = c.zona_rovine, c.zona_rovine
c.zona_sabbia = function(frame) return _colore(frame.args[1] or 'normale', 'D6BD7C', 'DBCFA0', 'B59B59') end
c.zona_Sabbia, c.zona_sand = c.zona_sabbia, c.zona_sabbia
c.zona_lago = function(frame) return _colore(frame.args[1] or 'normale', '66BDCC', '85D4DE', '538FBD') end
c.zona_Lago, c.zona_lake = c.zona_lago, c.zona_lago
c.zona_oceano = function(frame) return _colore(frame.args[1] or 'normale', '485CC2', '5A98F5', '1E3F94') end
c.zona_Oceano, c.zona_ocean = c.zona_oceano, c.zona_oceano
c.zona_sottacqua = function(frame) return _colore(frame.args[1] or 'normale', '6053AD', '737AC7', '553894') end
c.zona_Sottacqua, c.zona_underwater = c.zona_sottacqua, c.zona_sottacqua
c.zona_montagna = function(frame) return _colore(frame.args[1] or 'normale', 'B8907D', 'D4B5A7', '7A5443') end
c.zona_Montagna, c.zona_mountain = c.zona_montagna, c.zona_montagna
c.zona_vulcano = function(frame) return _colore(frame.args[1] or 'normale', 'D20000', 'D23434', 'A30000') end
c.zona_Vulcano, c.zona_volcano = c.zona_vulcano, c.zona_vulcano
c.zona_neve = function(frame) return _colore(frame.args[1] or 'normale', 'DCEBEF', 'E1EFF2', 'BBCDD1') end
c.zona_Neve, c.zona_snow = c.zona_neve, c.zona_neve
c.zona_spazio = function(frame) return _colore(frame.args[1] or 'normale', '222222', '555555', '000000') end
c.zona_Spazio, c.zona_space = c.zona_spazio, c.zona_spazio
c.zona_distorsione = function(frame) return _colore(frame.args[1] or 'normale', '5A65DB', 'CC8562', '2622A8') end
c.zona_Distorsione, c.zona_distortion = c.zona_distorsione, c.zona_distorsione
c.zona_ombra = function(frame) return _colore(frame.args[1] or 'normale', '472E63', '604E82', '1A0A2C') end
c.zona_Ombra, c.zona_shadow = c.zona_ombra, c.zona_ombra
c.zona_edificio = function(frame) return _colore(frame.args[1] or 'normale', 'A8B9BD', 'C3D8DE', '8A9CA1') end
c.zona_Edificio, c.zona_building, c.zona_palazzo = c.zona_edificio, c.zona_edificio, c.zona_edificio
c.zona_strada = function(frame) return _colore(frame.args[1] or 'normale', 'ABA9A4', 'CFCDC7', '949391') end
c.zona_Strada, c.zona_road = c.zona_strada, c.zona_strada
c.zona_citta = function(frame) return _colore(frame.args[1] or 'normale', 'D9D9D9', 'E6E6E6', 'CCCCCC') end
c.zona_Citta, c.zona_city, c.zona_City = c.zona_citta, c.zona_citta, c.zona_citta
c['zona_città'], c['zona_Città'] = c.zona_citta, c.zona_citta
c.zona_normale, c.zona_Normale = c.normale, c.normale
c.zona_fuoco, c.zona_Fuoco = c.fuoco, c.fuoco
c.zona_acqua, c.zona_Acqua = c.acqua, c.acqua
c.zona_erba, c.zona_Erba = c.erba, c.erba
c.zona_elettro, c.zona_Elettro = c.elettro, c.elettro
c.zona_lotta, c.zona_Lotta = c.lotta, c.lotta
c.zona_volante, c.zona_Volante = c.volante, c.volante
c.zona_veleno, c.zona_Veleno = c.veleno, c.veleno
c.zona_coleot, c.zona_Coleot = c.coleottero, c.coleottero
c.zona_coleottero, c.zona_Coleottero = c.coleottero, c.coleottero
c.zona_roccia, c.zona_Roccia = c.roccia, c.roccia
c.zona_terratipo, c.zona_Terratipo = c.terra, c.terra
c.zona_psico, c.zona_Psico = c.psico, c.psico
c.zona_ghiaccio, c.zona_Ghiaccio = c.ghiaccio, c.ghiaccio
c.zona_drago, c.zona_Drago = c.drago, c.drago
c.zona_spettro, c.zona_Spettro = c.spettro, c.spettro
c.zona_buio, c.zona_Buio = c.buio, c.buio
c.zona_acciaio, c.zona_Acciaio = c.acciaio, c.acciaio
c.zona_folletto, c.zona_Folletto = c.folletto, c.folletto
c.zona_rosso, c.zona_Rosso = c.rosso, c.rosso
c.zona_blu, c.zona_Blu = c.blu, c.blu
c.zona_verde, c.zona_Verde = c.verde, c.verde
c.zona_giallo, c.zona_Giallo = c.giallo, c.giallo

c.zona_text = function(frame)
    local zone = string.trim(frame.args[1] or ''):lower()
    local colors = {palude = '573118', vulcano = 'FFBC00',
        spazio = 'FFFFFF', distorsione = 'E0FAFF'}
    colors.marsh = colors.palude
    colors.volcano = colors.vulcano
    colors.space, colors.shadow, colors.ombra =
        colors.spazio, colors.spazio, colors.spazio
    colors.distortion = colors.distorsione
    return colors[zone] or '000000'
end

-- Colore pcwiki

c.pcwiki = function(frame)
    local var = (string.trim(frame.args[1] or 'normale')):lower()
    local colors = {['medium light'] = 'B1D6FF',
        ['medium dark'] = '5BA0FF'}
    return colors[var] or _colore(var, '7CBAFF', 'D0E6FF', '0078FF')
end

c.PCWiki, c.PCwiki = c.pcwiki, c.pcwiki

-- Colori ore

c.giorno = function(frame) return _colore(frame.args[1] or 'normale', '5ED0FF', '96E0FF', '4192B3') end
c.giorno_text = function(frame) return '000000' end
c.mattina = function(frame) return _colore(frame.args[1] or 'normale', 'FFFFAA', 'FFFFC8', 'B3B377') end
c.mattina_text = function(frame) return '000000' end
c.notte = function(frame) return _colore(frame.args[1] or 'normale', '003366', '597A9B', '002347') end
c.notte_text = function(frame) return 'FFFF99' end
c.sera = function(frame) return _colore(frame.args[1] or 'normale', 'FF8741', 'FEAD7E', 'AD3F00') end
c.sera_text = function(frame) return '000000' end

-- Colori stagioni

c.autunno = function(frame) return _colore(frame.args[1] or 'normale', 'F89058', 'FAB189', 'AE653D') end
c.inverno = function(frame) return _colore(frame.args[1] or 'normale', 'F0D8F8', 'F4E3FA', 'A897AE') end
c.estate = function(frame) return _colore(frame.args[1] or 'normale', '78D0F8', 'A0DEFA', '5492AE') end
c.primavera = function(frame) return _colore(frame.args[1] or 'normale', 'B0F858', 'C7FA89', '7BAE3D') end

-- Colori gare

c.acume = function(frame) return _colore(frame.args[1] or 'normale', '78C850', 'A7DB8D', '4E8234') end
c.amaro = c.acume
c.bellezza = function(frame) return _colore(frame.args[1] or 'normale', '6890F0', '9DB7F5', '445E9C') end
c.secco = c.bellezza
c.classe = function(frame) return _colore(frame.args[1] or 'normale', 'F08030', 'F5AC78', '9C531F') end
c.pepato = c.classe
c.gara = function(frame) return _colore(frame.args[1] or 'normale', 'E090A8', 'EBB7C6', '925E6D') end
c.grazia = function(frame) return _colore(frame.args[1] or 'normale', 'F85888', 'FA92B2', 'A13959') end
c.dolce = c.grazia
c.grinta = function(frame) return _colore(frame.args[1] or 'normale', 'F8D030', 'FAE078', 'A1871F') end
c.aspro = c.grinta

-- Colori gcc

c.acqua_gcc = function(frame) return _colore(frame.args[1] or 'normale', '5BC7E5', '94DBEE', '3B8295') end
c.lampo_gcc = function(frame) return _colore(frame.args[1] or 'normale', 'FAB536', 'FCCE7C', 'A37523') end
c.drago_gcc = function(frame) return _colore(frame.args[1] or 'normale', 'C6A114', 'DAC266', '81690D') end
c.erba_gcc = function(frame) return _colore(frame.args[1] or 'normale', '7DB808', 'AAD15E', '517805') end
c.folletto_gcc = function(frame) return _colore(frame.args[1] or 'normale', 'E03A83', 'EA7EAE', '912555') end
c.fuoco_gcc = function(frame) return _colore(frame.args[1] or 'normale', 'E24242', 'EC8484', '932B2B') end
c.incolore_gcc = function(frame) return _colore(frame.args[1] or 'normale', 'E5D6D0', 'EEE4E0', '958B87') end
c.arcobaleno_gcc = c.incolore_gcc
c.metallo_gcc = function(frame) return _colore(frame.args[1] or 'normale', '8A776E', 'B3A6A1', '5A4D48') end
c.oscurita_gcc = function(frame) return _colore(frame.args[1] or 'normale', '2C2E2B', '767775', '1D1E1C') end
c['oscurità_gcc'] = c.oscurita_gcc
c.psiche_gcc = function(frame) return _colore(frame.args[1] or 'normale', 'A65E9A', 'C596BD', '6C3D64') end
c.supporto_gcc = function(frame) return _colore(frame.args[1] or 'normale', 'DC2222', 'E66363', '9A1717') end
c.aiuto_gcc = c.supporto_gcc
c.combattimento_gcc = function(frame) return _colore(frame.args[1] or 'normale', 'FF501F', 'FF8D6D', 'A63414') end
c.allenatore_gcc = function(frame) return _colore(frame.args[1] or 'normale', 'FFE955', 'FFFCE4', 'B3A33B') end
c.trainer_gcc = c.allenatore_gcc
c['pokébody_gcc'] = function(frame) return _colore(frame.args[1] or 'normale', '146837', '5A9572', '0E4926') end
c['poké-body_gcc'] = c['pokébody_gcc']
c['poképower_gcc'] = function(frame) return _colore(frame.args[1] or 'normale', '850921', 'A95263', '5D0617') end
c['poké-power_gcc'] = c['poképower_gcc']
c.abilita_gcc = function(frame) return _colore(frame.args[1] or 'normale', 'C84923', 'D87F64', '8C3318') end
c['abilità_gcc'] = c.abilita_gcc
c.strumento_gcc = function(frame) return _colore(frame.args[1] or 'normale', '7777EE', 'A6A6F4', '4D4D9B') end
c.stadio_gcc = function(frame) return _colore(frame.args[1] or 'normale', '90E183', 'B7EBAE', '5E9255') end

-- Colori Parco Lotta

c.arena = function(frame) return _colore(frame.args[1] or 'normale', 'FFC115', 'FFD767', 'A67E0E') end
c.azienda = function(frame) return _colore(frame.args[1] or 'normale', '3291C1', '7AB7D7', '215E7E') end
c.fabbrica = c.azienda
c.cupola = function(frame) return _colore(frame.args[1] or 'normale', 'AD32DA', 'D35CFF', '71009B') end
c.dojo = function(frame) return _colore(frame.args[1] or 'normale', '20811D', '2DBA29', '043503') end
c.maniero = function(frame) return _colore(frame.args[1] or 'normale', '40AD72', '83CAA3', '2A714A') end
c.palazzo = function(frame) return _colore(frame.args[1] or 'normale', 'F6F60A', 'FFFF67', '888600') end
c.palco = function(frame) return _colore(frame.args[1] or 'normale', 'F87A97', 'FFADC0', 'A14F62') end
c.parco_lotta = function(frame) return _colore(frame.args[1] or 'normale', '3FA9D0', '82C7E0', '296E87') end
c.parco_Lotta = c.parco_lotta
c.piramide = function(frame) return _colore(frame.args[1] or 'normale', 'FF5900', 'FF9049', 'A13500') end
c.serpe = function(frame) return _colore(frame.args[1] or 'normale', '7D000C', 'B51826', '300105') end
c.torre = function(frame) return _colore(frame.args[1] or 'normale', 'D6553C', 'E49080', '8B3727') end

-- Colori tasche

c.bacche = function(frame) return _colore(frame.args[1] or 'normale', '6161FD', 'BBC5FF', '08088C') end
c.macchine = function(frame) return _colore(frame.args[1] or 'normale', '9248E5', 'D4ABFD', '1F0042') end
c.MT_e_MN = c.macchine
c['poké_ball'] = function(frame) return _colore(frame.args[1] or 'normale', 'C88820', 'E0A038', 'B87008') end
c['poké_Ball'] = c['poké_ball']
c.rimedi = function(frame) return _colore(frame.args[1] or 'normale', '00BE00', '99FF99', '006100') end
c.strumenti = function(frame) return _colore(frame.args[1] or 'normale', '0296C8', '6DE0FF', '00384B') end
c.strumenti_base = function(frame) return _colore(frame.args[1] or 'normale', 'F93333', 'FFA7A7', '8E0808') end
c.strumenti_lotta = function(frame) return _colore(frame.args[1] or 'normale', '3070E0', '4880F0', '2058C8') end
c.messaggi = function(frame) return _colore(frame.args[1] or 'normale', '1890B0', '18A8D0', '208090') end
c.cristalli_z = function(frame) return _colore(frame.args[1] or 'normale', 'AB6900', 'FFB744', '4D1F00') end
c.cristalli_Z = c.cristalli_z

-- Colori gruppi uova

c.mostro_uova = function(frame) return _colore(frame.args[1] or 'normale', 'D25064', 'D25064', '933846') end
c.acqua_1_uova = function(frame) return _colore(frame.args[1] or 'normale', '97B5FD', '97B5FD', '697FB1') end
c['acqua 1_uova'] = c.acqua_1_uova
c.coleottero_uova = function(frame) return _colore(frame.args[1] or 'normale', 'AAC22A', 'AAC22A', '77881D') end
c.coleot_uova = c.coleot_uova
c.volante_uova = function(frame) return _colore(frame.args[1] or 'normale', 'B29AFA', 'B29AFA', '7C6CAF') end
c.campo_uova = function(frame) return _colore(frame.args[1] or 'normale', 'E0C068', 'E0C068', '9D8649') end
c.magico_uova = function(frame) return _colore(frame.args[1] or 'normale', 'FFC8F0', 'FFC8F0', 'B38CA8') end
c.erba_uova = function(frame) return _colore(frame.args[1] or 'normale', '82D25A', '82D25A', '5B933F') end
c.umanoide_uova = function(frame) return _colore(frame.args[1] or 'normale', 'D29682', 'D29682', '93695B') end
c.acqua_3_uova = function(frame) return _colore(frame.args[1] or 'normale', '5876BE', '5876BE', '3D5285') end
c['acqua 3_uova'] = c.acqua_3_uova
c.minerale_uova = function(frame) return _colore(frame.args[1] or 'normale', '7A6252', '7A6252', '554439') end
c.amorfo_uova = function(frame) return _colore(frame.args[1] or 'normale', '8A8A8A', '8A8A8A', '606060') end
c.acqua_2_uova = function(frame) return _colore(frame.args[1] or 'normale', '729AFA', '729AFA', '506CAF') end
c['acqua 2_uova'] = c.acqua_2_uova
c.ditto_uova = function(frame) return _colore(frame.args[1] or 'normale', 'A664BF', 'A664BF', '744686') end
c.drago_uova = function(frame) return _colore(frame.args[1] or 'normale', '7A42FF', '7A42FF', '552EB3') end
c.sconosciuto_uova = function(frame) return _colore(frame.args[1] or 'normale', '0080C0', '0080C0', '005986') end
c.asessuato_uova = function(frame) return _colore(frame.args[1] or 'normale', '333333', '333333', '232323') end

-- Varie ed eventuali

c.arancione = c.orange
c.background = function(frame) return 'EAEAEA' end
c.bronzo = function(frame) return _colore(frame.args[1] or 'normale', 'DEAB79', 'EBCDAF', '856749') end
c.bulba = function(frame) return _colore(frame.args[1] or 'normale', 'C4E673', 'E0F2B6', '80964B') end
c.camilla = function(frame) return _colore(frame.args[1] or 'normale', '525252', '8E8E8E', '353535') end
c['club pokémiglia'] = function(frame) return _colore(frame.args[1] or 'normale', '389AD8', '9ECEEC', '075282') end
c.diantha = function(frame) return _colore(frame.args[1] or 'normale', 'E64A80', 'F08FB1', 'A5385C') end
c.dw = function(frame) return _colore(frame.args[1] or 'normale', 'E78EA0', 'F3DBDE', '984852') end
c.DW, c['dream world'] = c.dw, c.dw
c.FFFFFF = function(frame) return 'FFFFFF' end
c.ffffff = c.FFFFFF
c.ghicocca = function(frame) return _colore(frame.args[1] or 'normale', 'F0A018', 'F8C038', 'A05840') end
c.nardo = function(frame) return _colore(frame.args[1] or 'normale', 'E88058', 'F0AA8F', 'C84040') end
c.olio = function(frame) return _colore(frame.args[1] or 'normale', 'BAB1C9', 'DCD7E3', '978CAE') end
c['pokémon'] = function(frame) return _colore(frame.args[1] or 'normale', 'E5653C', 'E2947C', 'A62F19') end
c['pokéwalker'] = function(frame) return _colore(frame.args[1] or 'normale', 'D82D40', 'ED7B88', '700A16') end
c.safari_amici = function(frame) return _colore(frame.args[1] or 'normale', '68AA57', 'AFDBA5', '447039') end
c['000000'] = function(frame) return '000000' end
c['000'] = c['000000']

-- Generating aliases

--[[

This function generate aliases for colors that contain an underscore in their
name. It adds to the exported table aliases with both spaces and nothing
instead of the underscores, both original and first uppercase variations (so,
four aliases are added in total). Arguments:

- name: The name tobe aliased.
- funct: the function to be mapped to the alias.

--]]
local makeUnderscoreAliases = function(name, funct)
    if name:find('_') then
        local spaces = name:gsub('_', ' ')
        c[spaces], c[string.fu(spaces)] = funct, funct

        local noSpaces = name:gsub('_', '')
        c[noSpaces], c[string.fu(noSpaces)] = funct, funct
    end
end

--[[
    table.keys is necessary because a plain pairs would act wierd, in that
    we are adding keys to the c in the for loop
--]]
for _, name in ipairs(table.keys(c)) do
    local funct = c[name]

    c[string.fu(name)] = funct
    makeUnderscoreAliases(name, funct)

    if name:find('é') then
        local noAccent = name:gsub('é', 'e')
        c[noAccent], c[string.fu(noAccent)] = funct, funct

        makeUnderscoreAliases(noAccent, funct)
    end

    if name:find('à') then
        local noAccent = name:gsub('à', 'a')
        c[noAccent], c[string.fu(noAccent)] = funct, funct

        makeUnderscoreAliases(noAccent, funct)
    end
end

return c

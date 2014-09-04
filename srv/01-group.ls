require! fs

data = fs.readFileSync "#__dirname/../data/kandidatky2014.csv"
lines = data.toString!.split "\n"
  ..shift!
  ..pop!

obce = {}

groupVek = (vek) ->
  if vek <= 25
    return 0
  if vek > 95
    return 14
  vek -= 25
  Math.ceil vek / 5

initObec = (id, nazev) ->
  obce[id] =
    id: id
    nazev: nazev
    celkem: 0
    ing: 0
    mgr: 0
    mudr: 0
    judr: 0
    rsdr: 0
    bez: 0
    jiny: 0
    veky: []
    zeny: 0
  for i in [0 to 14]
    obce[id]["vek-#i"] = 0


hasTitul = (tituly, titul) ->
  -1 !== tituly.indexOf titul

tituly_assoc = {}
ruzumnyTituly =  <[ing mgr mudr judr]>
rsdrs = []
for line, index in lines
  [ID, obec, poradi, jmeno, prijmeni, titulpred, titulza, vek, povolani, cislo, strana, zkratka, pohlavi] = line.split "\t"
  titulpred .= replace /\./g ''
  titulza .= replace /\./g ''

  titulpred .= replace /,/g ''
  titulza .= replace /,/g ''


  titulpred .= toLowerCase!
  titulza .= toLowerCase!

  titulpred .= replace 'arch' ''
  tituly = (titulpred.split " ") ++ (titulza.split " ")

  if not obce[ID] then initObec ID, obec
  obec = obce[ID]
  obec.celkem++
  titul = titulpred + titulza
  maRozumnyTitul = false
  if titul.length == 0
    obec.bez++
  else
    for rozumnyTitul in ruzumnyTituly
      if hasTitul titul, rozumnyTitul
        if rozumnyTitul == 'mvdr' then rozumnyTitul = 'mudr'
        obec[rozumnyTitul]++
        maRozumnyTitul = true
    if not maRozumnyTitul
      obec.jiny++
  if pohlavi[0] == "N"
    obec.zeny++
  vek = parseInt vek, 10
  if vek
    obec["vek-#{groupVek vek}"]++
    obec['veky'].push vek

obce = for id, obec of obce
  obec.veky.sort (a, b) -> a - b
  obec['vek-median'] = obec.veky[Math.round obec.veky.length / 2]
  delete obec.veky
  for key, value of obec
    value

obce.unshift do
  for key, value of obec
    key
fs.writeFileSync do
  "#__dirname/../data/obce.tsv"
  obce.map (.join '\t') .join '\n'

require! fs

data = fs.readFileSync "#__dirname/../data/kandidatky2014.csv"
lines = data.toString!.split "\n"
  ..shift!
  # ..pop!

tituly_assoc = {}
rsdrs = []
currentObecId = null
currentObec = []
headers = <[poradi jmeno prijmeni titulpred titulza vek povolani cislo strana zkratka pohlavi]>
saveCurrentObec = ->
  return if currentObec.length == 0
  out = ([headers] ++ currentObec).map (.join '\t') .join '\n'
  fs.writeFileSync "#__dirname/../data/obce/#currentObecId.tsv", out
  currentObec.length = 0

for line, index in lines
  [id, obec, poradi, jmeno, prijmeni, titulpred, titulza, vek, povolani, cislo, strana, zkratka, pohlavi] = line.split "\t"
  if id != currentObecId
    saveCurrentObec!
  currentObecId = id

  currentObec.push [poradi, jmeno, prijmeni, titulpred, titulza, vek, povolani, cislo, strana, zkratka, pohlavi]

saveCurrentObec!

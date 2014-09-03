require! fs
data = fs.readFileSync "#__dirname/../data/kandidatky2014.csv"
lines = data.split "\n"
for line in lines
	[ID, obec, poradi, jmeno, prijmeni, titulpred, titulza, vek, povolani, cislo, strana, zkratka, pohlavi] = line.split "\n"
	console.log titulpred
	process.exit!

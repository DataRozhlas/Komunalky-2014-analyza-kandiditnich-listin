require! {
  fs
  diacritics
  async
}
dir = "#__dirname/../data/obce"
files = fs.readdirSync dir
# files.length = 5
unify = (name) ->
  name .= replace /ova$/ ''
  name .= replace /[aeiouy]*$/ ''
  name

(err, mista) <~ async.mapLimit files, 5, (file, cb) ->
  (err, content) <~ fs.readFile "#dir/#file"
  names = {}
  lines = content.toString!split "\n"
    ..shift!
  for line in lines
    [poradi, jmeno, prijmeni] = line.split "\t"
    continue unless prijmeni
    prijmeni = diacritics.remove prijmeni .toLowerCase!
    casti = prijmeni.split /[- ]/
    for cast in casti
      std = unify cast
      names[std] = names[std] + 1 || 1
  len = lines.length

  people = for name, count of names
    percent = count / len
    {name, count, percent, file, len}
  people.sort (a, b) -> b.percent - a.percent
  cb null people.0

mista .= filter -> it
mista .= filter -> it.count > 2 and it.percent > 0.05
mista.sort (a, b) -> b.percent - a.percent
for {name, count, percent, file, len} in mista
  console.log "#name\t#count\t#percent\t#file\t#len"
# console.log mista
# console.log diacritics.remove "šěčš"

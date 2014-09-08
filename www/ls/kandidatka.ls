container = d3.select \.ig
wrap = container.append \div
  ..attr \class \kandidatka-wrap
content = wrap.append \div
  ..attr \class \kandidatka

heading = content.append \h1

tableContainer = content.append \div
  ..attr \class \tableContainer


tableHeadings =
  * value: (.poradi)
    sortable: 1
    name: '#'
  * value: -> "#{it.titulpred} #{it.jmeno} #{it.prijmeni} #{it.titulza}"
    sortable: -> "#{it.prijmeni}#{it.jmeno}"
    name: "Jméno"
  * value: -> parseInt it.vek, 10
    sortable: 1
    name: "Věk"
  * value: (.povolani)
    sortable: 1
    filterable: 1
    name: "Povolání"
  * value: -> if it.pohlavi == 'PRAVDA' then "Muž" else "Žena"
    filterable: 1
    name: "Pohl."
  * value: (.zkratka)
    filterable: 1
    name: "Strana"

window.ig.showKandidatka = (obecId, obecName) ->
  container.classed \kandidatka-active yes
  heading.html "Kandidátka obce #obecName"
  tableContainer.html ''
  (err, obec) <~ d3.tsv "../data/obce/#obecId.tsv"
  new window.ig.DataTable tableContainer, tableHeadings, obec

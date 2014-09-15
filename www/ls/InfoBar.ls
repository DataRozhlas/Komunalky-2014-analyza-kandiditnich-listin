vekGroups = <[18 25 30 35 40 45 50 55 60 65 70 75 80 85 90+]>
titulClassNames = <[ing mgr mudr judr jiny bez]>
titulLegend = [\Ing. \Mgr. \MUDr. \JUDr. \Jiný "Bez titulu"]

window.ig.InfoBar = class InfoBar
  (parentElement) ->
    @init parentElement

  displayData: ({nazev, celkem, tituly, veky, zeny, mandaty}) ->
    @nazev.text "#{nazev}"
    @container.classed \noData celkem == 0
    if celkem == 0
      @helpText.html "Vojenský újezd"
      celkem = 1
    else
      @helpText.html "Kliknutím do mapy zobrazíte detail kandidátky"
    vekyRelative = veky.map -> it / celkem
    maxVek = Math.max ...vekyRelative
    stdMaxVek = 0.25
    stdMaxVek = maxVek if maxVek > stdMaxVek
    tlacenka = (celkem / mandaty).toFixed 2 .replace '.' ','

    if mandaty
      @stats.data [celkem, mandaty, tlacenka] .html -> it
    else
      @stats.data ['-' '-' '-'] .html -> it

    @ageHistogram.style \height (d, i) ->
      "#{vekyRelative[i] / stdMaxVek * 100}%"
    sum = tituly.reduce do # fix chybejicich "jinych"
      (prev, curr) -> prev + curr
      0
    tituly.push tituly[* - 1]
    tituly[* - 2] = celkem - sum

    @genderFiller.style \width "#{zeny / celkem * 100}%"
    @titulFiller.style \width (d, i) -> "#{tituly[i] / celkem * 100}%"


  init: (parentElement) ->
    @container = parentElement.append \div
      ..attr \class "infoBar noData"
    @nazev = @container.append \h2
      ..text "Analýza kandidátní listiny"
    @helpText = @container.append \span
      ..attr \class \clickInvite
      ..text "Podrobnosti o obci zobrazíte najetím myši nad obec"
    @container.append \h3
      ..text "Věkové rozložení"
    histogramParent = @container.append 'div'
      ..attr \class \ageHistogram

    @ageHistogram = histogramParent.selectAll \div.field .data [0 til 15] .enter!append \div
      ..attr \class \field
      ..append \div
        ..attr \class \legend
        ..text (d, i) -> vekGroups[i]

    @container.append \h3
      ..text "Poměr mužů a žen"
      ..attr \class \genderH
    genderParent = @container.append \div
      ..attr \class \gender
      ..on \click -> window.ig.selectLayer \zeny
      ..append \div
        ..attr \class \center
      ..append \div
        ..attr \class \center-text
        ..text "50 %"
    @genderFiller = genderParent.append \div
      ..attr \class \genderFill

    @container.append \h3
      ..text "Tituly"
      ..attr \class \titulyH
    titulParent = @container.append \div
      ..attr \class \tituly

    @titulFiller = titulParent.selectAll \div.field .data [0 til 5] .enter!append \div
      ..attr \class (d, i) -> "#{titulClassNames[i]} field"
      ..on \click (d, i) -> window.ig.selectLayer titulClassNames[i]

    @container.append \div
      .attr \class \titulLegend
      .selectAll 'div' .data [0 til 6] .enter!append \div
        ..attr \class \item
        ..on \click (d, i) -> window.ig.selectLayer titulClassNames[i]
        ..append \span
          ..attr \class (d, i) -> "#{titulClassNames[i]} legendBg"
        ..append \span
          ..attr \class \text
          ..html (d, i) -> titulLegend[i]

    stats = @container.append \div
      ..attr \class \stats
      ..append \div
        ..attr \class \celkem
        ..append \h4 .html \Kandidátů
        ..append \span .attr \class \value
      ..append \div
        ..attr \class \mandaty
        ..append \h4 .html \Mandátů
        ..append \span .attr \class \value
      ..append \div
        ..attr \class \tlacenka
        ..append \h4 .html "Kandidátů na mandát"
        ..append \span .attr \class \value
    @stats = stats.selectAll \span.value

vekGroups = <[18 25 30 35 40 45 50 55 60 65 70 75 80 85 90+]>

window.ig.InfoBar = class InfoBar
  (parentElement) ->
    @init parentElement

  displayData: ({nazev, celkem, tituly, veky, zeny}) ->
    @nazev.text "#{nazev}"
    vekyRelative = veky.map -> it / celkem
    maxVek = Math.max ...vekyRelative
    stdMaxVek = 0.25
    stdMaxVek = maxVek if maxVek > stdMaxVek
    @ageHistogram.style \height (d, i) ->
      "#{vekyRelative[i] / stdMaxVek * 100}%"


  init: (parentElement) ->
    @container = parentElement.append \div
      ..attr \class \infoBar
    @nazev = @container.append \h2
    @container.append \h3
      ..text "Věkové rozložení"
    histogramParent = @container.append 'div'
      ..attr \class \ageHistogram

    @ageHistogram = histogramParent.selectAll \div.field .data [0 til 15] .enter!append \div
      ..attr \class \field
      ..append \div
        ..attr \class \legend
        ..text (d, i) -> vekGroups[i]

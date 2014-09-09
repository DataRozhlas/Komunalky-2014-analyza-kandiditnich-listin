window.Suggester = class Suggester
  suggestionThreshold: 3
  currentSuggestions: null
  currentSuggestionsIndex: null
  suggestionItems: null
  suggestionsDisabled: no
  onItemSelected: null
  lastQuery: null
  (parentElement) ->
    window.ig.Events @
    onValue = @~onValue
    @suggestions = []
    @container = parentElement .append \div
      ..attr \class \subsetSelector-container
    @input = @container.append \input
      ..attr \placeholder \Adamov
      ..on \focus @~downloadSuggestions
      ..on \keyup -> onValue @value
      ..on \keydown ~>
        @suggestionsDisabled = no
        switch d3.event.keyCode
        | 27 => @hideSuggestions!
        | 38 => @moveSuggestions -1
        | 40 => @moveSuggestions +1
        | 13 => @onInputSubmitted @currentSuggestions[@currentSuggestionsIndex]
    @suggestionList = @container.append \ul
      ..attr \class \suggestionList

  onInputSubmitted: (item) ->
    if not item
      item = @currentSuggestions[0]
    @suggestionsDisabled = yes
    @input.0.0.value = item.nazev
    @hideSuggestions!
    @emit 'selected' item

  onValue: (value) ->
    return if @suggestionsDisabled
    if value.length < @suggestionThreshold
      @hideSuggestions!
      return
    if value == @lastQuery
      @showSuggestions!
      return
    @lastQuery = value
    (err, suggestions) <~ @getSuggestions value
    @currentSuggestions = suggestions
    @showSuggestions!

  moveSuggestions: (dir) ->
    if @currentSuggestionsIndex is null
      @currentSuggestionsIndex =
        | dir > 0   => -1
        | otherwise => @currentSuggestions.length

    @currentSuggestionsIndex += dir
    if @currentSuggestionsIndex < 0
      @currentSuggestionsIndex += @currentSuggestions.length
    @currentSuggestionsIndex %= @currentSuggestions.length
    @refreshCurrentSelection!

  refreshCurrentSelection: ->
    selectedItem = @currentSuggestions[@currentSuggestionsIndex]
    @suggestionItems
      .classed \active no
      .filter -> it is selectedItem
      .classed \active yes

  showSuggestions: ->
    @suggestionList.selectAll "li" .data @currentSuggestions, (.id)
      ..enter!append \li
      ..exit!remove!
    @suggestionItems = @suggestionList.selectAll "li"
      ..attr \data-id (.id)
      ..on \click @~onInputSubmitted
      ..on \touchstart @~onInputSubmitted
      ..on \mouseover (item) ~>
        @currentSuggestionsIndex = @currentSuggestions.indexOf item
        @refreshCurrentSelection!
      ..html ->
          """<span class='obec'>#{it.nazev},
            <span class='okres'> okr. #{it.okres.nazev}</span>
          </span>"""

  hideSuggestions: ->
    @suggestionList.html ""

  getSuggestions: (value, cb) ->
    value .= toLowerCase!
    regExp = new RegExp "(^|-|\\s)" + value, ''
    filtered = @suggestions.filter ({nazevSearchable}) ->
      regExp.test nazevSearchable
    if filtered.length > 10
      tighterRegExp = new RegExp "^" + value, ''
      filtered .= filter ({nazevSearchable}) ->
        tighterRegExp.test nazevSearchable
    filtered.sort (a, b) ->
      if a > b then 1 else if b > a then -1 else 0
    if filtered.length > 10
      filtered.length = 10
    cb null, filtered

  downloadSuggestions: (cb) ->
    (err, text) <~ d3.text "/tools/suggester/0.0.1/okresy_obce.tsv"
    [okresy, obce] = text.split "\n\n"
    okresy_assoc = {}
    okresy.split "\n"
      .map (.split "\t")
      .forEach ([kod, nazev]) -> okresy_assoc[kod] = {kod, nazev}
    @suggestions = for line in obce.split "\n"
      [lon, lat, id, okres_kod, nazev] = line.split "\t"
      okres = okresy_assoc[okres_kod]
      lat = parseFloat lat
      lon = parseFloat lon
      id = parseInt id, 10
      nazevSearchable = nazev.toLowerCase!
      {lat, lon, id, okres, nazev, nazevSearchable}
    cb?!

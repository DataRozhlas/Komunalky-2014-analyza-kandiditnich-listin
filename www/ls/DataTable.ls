window.ig.DataTable = class DataTable
  (@parentElement, @headerFields, @fullData) ->
    window.ig.Events @
    @table = @parentElement.append \table
      ..attr \class \data-table
    @currentSort = {fieldIndex: null direction: 0}
    @drawHead!
    @prepareContent!
    @currentData = @fullData.slice!
    @currentTransformedData = @transformData @currentData
    @drawContent!

  drawHead: ->
    @table.append \thead .append \tr
      ..selectAll \th .data @headerFields .enter!append \th
        ..html (.name)
        ..on \click (d, i) ~>
          if d.sortable
            @sortBy i

  prepareContent: ->
    @tbody = @table.append \tbody

  drawContent: ->
    @tbody.html ''
    @lines = @tbody.selectAll \tr .data @currentTransformedData
      ..enter!append \tr
    @fields = @lines.selectAll \td .data(-> it) .enter!append \td
      ..html (.value)

  transformData: (input) ->
    input.map (inputLine) ~>
      @headerFields.map (headerField) ~>
        out = {}
          ..data = inputLine
          ..value = headerField.value inputLine
        out.sortable = switch typeof! headerField.sortable
          | \Function => headerField.sortable inputLine
          | otherwise => out.value
        out

  sortBy: (fieldIndex) ->
    if fieldIndex != @currentSort.fieldIndex
      @currentSort
        ..fieldIndex = fieldIndex
        ..direction = 1
    else
      @currentSort.direction *= -1

    @currentTransformedData.sort (a, b) ~>
      r = if a[fieldIndex].sortable > b[fieldIndex].sortable
        1
      else if a[fieldIndex].sortable < b[fieldIndex].sortable
        -1
      else
        0
      r * @currentSort.direction

    @drawContent!

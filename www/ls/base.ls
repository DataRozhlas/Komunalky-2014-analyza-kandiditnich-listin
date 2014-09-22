document.body.removeChild document.getElementById 'fallback'
body = d3.select \body
window.ig.infoBar = new ig.InfoBar body
window.ig.displayData = (data) ->
  nazev = data[1]
  celkem = data[2]
  tituly = data.slice 3, 8
  veky = data.slice 8, 23
  zeny = data[23]
  obyvatel = data[24]
  mandaty = data[25]
  window.ig.infoBar.displayData {nazev, celkem, tituly, veky, zeny, mandaty}

selectedOutline = null
suggesterContainer = body.append \div
  ..attr \class \suggesterContainer
  ..append \span .html "Najít obec"

suggester = new Suggester suggesterContainer
  ..on 'selected' (obec) ->
    window.ig.map.setView [obec.lat, obec.lon], 11
    setOutline obec.id

setOutline = (iczuj) ->
  if selectedOutline
    window.ig.map.removeLayer selectedOutline
  (err, data) <~ d3.json "/tools/suggester/0.0.1/geojsons/#{iczuj}.geo.json"
  return unless data
  style =
    fill: no
    opacity: 1
    color: '#000'
  selectedOutline := L.geoJson data, style
    ..addTo window.ig.map

if window.location.hash
  [iczuj, party] = that.slice 1 .split '|'
  iczuj = parseInt iczuj, 10
  <~ suggester.downloadSuggestions
  obec = suggester.suggestions.filter (.id == iczuj) .0
  if obec
    setOutline iczuj
    {lat, lon, nazev} = obec
    latlng = L.latLng [lat, lon]
    window.ig.map.setView latlng, 12
    window.ig.showKandidatka iczuj, nazev
    queueIterations = 0
    checkQueue = ->
      {data} = window.ig.utfgrid._objectForEvent {latlng: latlng}
      if data
        window.ig.displayData data
      else
        ++queueIterations
        setTimeout checkQueue, 100 if queueIterations < 100
    checkQueue!

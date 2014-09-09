document.body.removeChild document.getElementById 'fallback'
body = d3.select \body
window.ig.infoBar = new ig.InfoBar body
window.ig.displayData = (data) ->
  nazev = data[1]
  celkem = data[2]
  tituly = data.slice 3, 9
  veky = data.slice 9, 24
  zeny = data[25]
  obyvatel = data[26]
  mandaty = data[27]
  window.ig.infoBar.displayData {nazev, celkem, tituly, veky, zeny, mandaty}
window.ig.displayData [586846, "Jihlava", 420, 79, 35, 9, 5, 46, 247, 41, 26, 50, 47, 57, 40, 40, 48, 37, 22, 8, 3, 1, 0, 0, 45, 116, 50510, 37]


selectedOutline = null
suggester = new Suggester body
  ..on 'selected' (obec) ->
    window.ig.map.setView [obec.lat, obec.lon], 11
    if selectedOutline
      window.ig.map.removeLayer selectedOutline
    (err, data) <~ d3.json "/tools/suggester/0.0.1/geojsons/#{obec.id}.geo.json"
    return unless data
    style =
      fill: no
      opacity: 1
    selectedOutline := L.geoJson data, style
      ..addTo window.ig.map

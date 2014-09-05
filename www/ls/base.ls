document.body.removeChild document.getElementById 'fallback'
mapElement = document.createElement 'div'
  ..id = \map
document.body.appendChild mapElement
map = L.map do
  * mapElement
  * minZoom: 6,
    maxZoom: 13,
    zoom: 8,
    center: [49.78, 15.5]

getLayer = (topic, year) ->
  L.tileLayer do
    * "../data/tiles/#topic-#year/{z}/{x}/{y}.png"
    * attribution: '<a href="http://creativecommons.org/licenses/by-nc-sa/3.0/cz/" target = "_blank">CC BY-NC-SA 3.0 CZ</a> <a target="_blank" href="http://rozhlas.cz">Rozhlas.cz</a>, data <a target="_blank" href="http://www.volby.cz">ČSÚ</a>'
      zIndex: 2

baseLayer = L.tileLayer do
  * "http://{s}.tile.osm.org/{z}/{x}/{y}.png"
  * zIndex: 3
    opacity: 0.65
    attribution: 'mapová data &copy; přispěvatelé OpenStreetMap, obrazový podkres <a target="_blank" href="http://ihned.cz">IHNED.cz</a>'

grid = new L.UtfGrid "../data/tiles/meta-2014/{z}/{x}/{y}.json", useJsonP: no
  ..on \mouseover ({data}:e) ->
    displayData data

displayData = (data) ->
  nazev = data[1]
  celkem = data[2]
  tituly = data.slice 3, 10
  veky = data.slice 11, 26
  zeny = data[10]
  infoBar.displayData {nazev, celkem, tituly, veky, zeny}



map.addLayer grid
# map.addLayer baseLayer
map.addLayer getLayer \zeny 2014

layers = {}
for l in <[ing meta mgr mudr zeny]>
  layers[l] = getLayer l

currentLayer = null
selectLayer = (mapId) ->
  selectLayer maps[mapId]

selectLayer = (map) ->
  if currentLayer
    lastLayer = currentLayer
    setTimeout do
      ->
        map.removeLayer lastLayer.map
      300
  layer = getLayer map.imagery
  map.addLayer layer
  currentLayer :=
    map: layer


infoBar = new ig.InfoBar d3.select \body
displayData [588024,"Telč - Staré Město",168,23,16,2,1,0,111,15,42,15,11,15,10,30,18,22,14,15,12,5,1,0,0,0,46]

mapElement = document.createElement 'div'
  ..id = \map
document.body.appendChild mapElement
window.ig.map = map = L.map do
  * mapElement
  * minZoom: 6,
    maxZoom: 11,
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
    window.ig.displayData data
  ..on \click ({data}) ->
    window.ig.showKandidatka ...data

map.addLayer grid
# map.addLayer baseLayer



layers =
  * layer: getLayer 'tlacenka', 2014
    name: 'Kandidátů na mandát'
  * layer: getLayer 'zeny', 2014
    name: 'Zastoupení žen'
  * layer: getLayer 'ing', 2014
    name: 'Inženýři'
  * layer: getLayer 'mgr', 2014
    name: 'Magistři'
  * layer: getLayer 'mudr', 2014
    name: 'Doktoři'

currentLayer = null

selectLayer = ({layer}) ->
  if currentLayer
    lastLayer = currentLayer
    setTimeout do
      ->
        map.removeLayer lastLayer.map
      300

  map.addLayer layer
  currentLayer :=
    map: layer

selectLayer layers.0

d3.select 'body' .append \select
  ..attr \class \layerSelector
  ..selectAll \option .data layers .enter!append \option
    ..attr \value (d, i) -> i
    ..html (.name)
  ..on \change ->
    selectLayer layers[@value]

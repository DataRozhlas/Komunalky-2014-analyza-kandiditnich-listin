mapElement = document.createElement 'div'
  ..id = \map
document.body.appendChild mapElement
window.ig.map = map = L.map do
  * mapElement
  * minZoom: 6,
    maxZoom: 11,
    zoom: 7,
    center: [49.78, 15.5]
    maxBounds: [[48.4,11.8], [51.2,18.9]]

getLayer = (topic, year) ->
  L.tileLayer do
    * "../data/tiles/#topic-#year/{z}/{x}/{y}.png"
    * attribution: '<a href="http://creativecommons.org/licenses/by-nc-sa/3.0/cz/" target = "_blank">CC BY-NC-SA 3.0 CZ</a> <a target="_blank" href="http://rozhlas.cz">Rozhlas.cz</a>, data <a target="_blank" href="http://www.volby.cz">ČSÚ</a>'
      zIndex: 2

baseLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_b1/{z}/{x}/{y}.png"
  * zIndex: 1
    opacity: 1
    attribution: 'mapová data &copy; přispěvatelé <a target="_blank" href="http://osm.org">OpenStreetMap</a>, obrazový podkres <a target="_blank" href="http://stamen.com">Stamen</a>, <a target="_blank" href="https://samizdat.cz">Samizdat</a>'

labelLayer = L.tileLayer do
  * "https://samizdat.cz/tiles/ton_l1/{z}/{x}/{y}.png"
  * zIndex: 3
    opacity: 0.75

grid = new L.UtfGrid "../data/tiles/meta-2014/{z}/{x}/{y}.json", useJsonP: no
  ..on \mouseover ({data}:e) ->
    window.ig.displayData data
  ..on \click ({data}) ->
    return unless data
    return unless data.2
    window.ig.showKandidatka ...data

map.addLayer grid

map.on \zoomend ->
  z = map.getZoom!
  if z > 9 && !map.hasLayer baseLayer
    map
      ..addLayer baseLayer
      ..addLayer labelLayer
    layers.forEach (.layer.setOpacity 0.6)
  else if z <= 9 && map.hasLayer baseLayer
    map
      ..removeLayer baseLayer
      ..removeLayer labelLayer
    layers.forEach (.layer.setOpacity 1)

layers =
  * layer: getLayer 'tlacenka', 2014
    name: 'Počtu kandidátů na mandát'
  * layer: getLayer 'zeny', 2014
    name: 'Zastoupení žen'
  * layer: getLayer 'ing', 2014
    name: 'Počtu inženýrů na kandidátce'
  * layer: getLayer 'mgr', 2014
    name: 'Počtu magistrů na kandidátce'
  * layer: getLayer 'mudr', 2014
    name: 'Počtu doktorů na kandidátce'

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

d3.select 'body' .append \div
  ..attr \class \layerSelector
      ..append \span .html "Vybarvit mapu podle"
  ..append \select
    ..selectAll \option .data layers .enter!append \option
      ..attr \value (d, i) -> i
      ..html (.name)
    ..on \change ->
      selectLayer layers[@value]

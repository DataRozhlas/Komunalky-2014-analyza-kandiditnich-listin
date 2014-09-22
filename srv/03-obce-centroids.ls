require! {
  fs
  topojson
  d3
  async
}
(err, struktura) <~ fs.readFile "#__dirname/../data/struktura.tsv"
struktura .= toString!split "\n" .map (.split "\t")
obce_assoc = {}
okresy_assoc = {}
for [id, nazev, status, ou_kod, ou_nazev, orp_kod, orp_nazev, okres_kod, okres_nazev] in struktura
  obce_assoc[id] = {nazev, okres_kod, okres_nazev}
  okresy_assoc[okres_kod] = {okres_kod, okres_nazev}

(err, topo) <~ fs.readFile "#__dirname/../data/mapy.topo.json"
topo = JSON.parse topo
features = topojson.feature topo, topo.objects."data" .features
# features.length = 5
(err, output) <~ async.mapLimit features, 10, (feature, cb) ->
  centroid = d3.geo.centroid feature
  # console.log centroid, feature.properties
  id = feature.properties.ICZUJ
  obec_info = obce_assoc[id]
  if not obec_info
    if 'Praha' is feature.properties.NAZMC.substr 0, 5
      obec_info = okresy_assoc['CZ0100']
    else if 'Plzeň' is feature.properties.NAZMC.substr 0, 5
      obec_info = okresy_assoc['CZ0323']
    else if 'Ústí nad Labem' is feature.properties.NAZMC.substr 0, 14
      obec_info = okresy_assoc['CZ0427']
    else if 'Pardubice' is feature.properties.NAZMC.substr 0, 9
      obec_info = okresy_assoc['CZ0532']
    else if 'Liberec' is feature.properties.NAZMC.substr 0, 7
      obec_info = okresy_assoc['CZ0513']
    else if 'Brno' is feature.properties.NAZMC.substr 0, 4
      obec_info = okresy_assoc['CZ0642']
    else if 'Liberec' is feature.properties.NAZMC.substr 0, 7
      obec_info = okresy_assoc['CZ0513']
    else if 'Liberec' is feature.properties.NAZMC.substr 0, 7
      obec_info = okresy_assoc['CZ0513']
    else if +feature.properties.ICZUJ >=555321
      obec_info = okresy_assoc['CZ0805']
    else
      obec_info = okresy_assoc['CZ0806']

  [[w, s], [e, n]] = d3.geo.bounds feature
  line = (centroid.map (.toFixed 3)) ++ [
    parseInt feature.properties.ICZUJ, 10
    obec_info['okres_kod']
    feature.properties.NAZMC || feature.properties.NAZOB
  ] ++ [w, s, e, n].map (.toFixed 3)
  feature.properties = {nazev: feature.properties.NAZMC || feature.properties.NAZOB}



  # <~ fs.writeFile do
  #   "#__dirname/../data/suggester/geojsons/#{id}.geo.json"
  #   JSON.stringify {type: 'FeatureCollection', features: [feature]}
  <~ process.nextTick
  cb null, line
output.sort (a, b) -> a.2 - b.2
tsv = output.map (.join '\t') .join '\n'
# fs.writeFileSync "#__dirname/../data/suggester/obce_centroids_extents.tsv" tsv
# console.log tsv

# return

okresy = for kod, {okres_kod, okres_nazev} of okresy_assoc
  [okres_kod, okres_nazev]
okresy .= filter (.0)
tsv_okresy = okresy.map (.join '\t') .join '\n'
# fs.writeFileSync "#__dirname/../data/suggester/okresy.tsv" tsv_okresy
fs.writeFileSync "#__dirname/../data/suggester/obce_centroids_extents.tsv" tsv_okresy + "\n\n" + tsv

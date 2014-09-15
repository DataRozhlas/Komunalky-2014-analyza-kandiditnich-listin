require! {
  fs
  topojson
}

topo = fs.readFileSync "#__dirname/../data/mapy2.topo.json"
topo = JSON.parse topo

topo_old = fs.readFileSync "#__dirname/../data/mapy.topo.json"
topo_old = JSON.parse topo_old

features = topojson.feature topo, topo.objects."data" .features
features_old = topojson.feature topo_old, topo_old.objects."data" .features

assoc = {}
for feature in features_old
    assoc[feature.properties.ICZUJ] = feature.properties
for {properties}:feature in features
    if !properties.zeny
        properties.zeny = assoc[properties.ICZUJ].zeny
header = for key of features.0.properties
  key
csv = for {properties}:feature in features
  for key in header
    properties[key]

csv.unshift header

fs.writeFileSync do
  "#__dirname/../data/final_data.tsv"
  csv.map (.join '\t') .join '\n'

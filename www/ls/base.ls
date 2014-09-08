document.body.removeChild document.getElementById 'fallback'
window.ig.infoBar = new ig.InfoBar d3.select \body
window.ig.displayData = (data) ->
  nazev = data[1]
  celkem = data[2]
  tituly = data.slice 3, 10
  veky = data.slice 11, 26
  zeny = data[10]
  window.ig.infoBar.displayData {nazev, celkem, tituly, veky, zeny}
window.ig.displayData [588024,"Telč - Staré Město",168,23,16,2,1,0,111,15,42,15,11,15,10,30,18,22,14,15,12,5,1,0,0,0,46]

# <~ setTimeout _, 600
window.ig.showKandidatka 588024,"Telč - Staré Město"

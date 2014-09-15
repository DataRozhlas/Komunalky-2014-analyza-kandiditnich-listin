require! {
  fs
  child_process.exec
  async
}
readdir = (dir, cb) ->
  (err, entries) <~ fs.readdir dir
  dirs = []
  files = []
  for entry in entries
    addr = dir + "/" + entry
    if '.json' == entry.substr -5
      files.push addr
    else
      dirs.push addr
  (err, subFiles) <~ async.map dirs, readdir

  cb null, files.concat ...subFiles
(err, list) <~ readdir "#__dirname/../data/tiles/meta-2014"
chunks = []
i = Infinity
for item in list
  if i > 10
    i = 0
    chunk = []
    chunks.push chunk
  chunk.push item
  ++i

len = chunks.length
i = 0
async.eachLimit chunks, 8, (chunk, cb) ->
  (err) <~ exec "zopfli #{chunk.join ' '}"
  i++
  console.log "#i / #len -- #{(i / len * 100).toFixed 2}%"
  cb!

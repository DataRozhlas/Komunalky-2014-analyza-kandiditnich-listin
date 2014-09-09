require! {
  fs
  child_process.exec
  async
}
(err, files) <~ fs.readdir "#__dirname/../data/obce"
# files.length = 1
i = 0
async.eachLimit files, 8, (file, cb) ->
  console.log i++
  (err) <~ exec "zopfli #__dirname/../data/obce/#file"
  cb!

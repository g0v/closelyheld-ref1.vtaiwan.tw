require! <[
  async
  mammoth
  fs
  glob
  path
]>

function convert-to-json (path, callback)
  [,heading, article,] = path.match /([0-9]+)-([0-9]+)\.docx$/
  output = {}
  mammoth.convertToMarkdown path: path
    .then ({value}:it) ->
      [content, comments] = value.split '你知道嗎？'
      [comment, note] = comments.trim!split '參考條文及資料'
      [heading, ...rest ]= content.split '\n\n'
      note = note || ""
      rest.pop!
      all-comment = """
      你知道嗎？<br>
      #{comment.trim!replace '\n', '<br>'}<br>
      參考條文及資料<br>
      #{note.trim!replace '\n', '<br>'}
      """
      output := do
        comment: all-comment
        article: article
        original-article: article
        content: rest.join '\n'
        base-content: ""
    .done -> callback null, output

pros = do
  meta:
    abstract: ""
  content: []

err, files <- glob './src/*'
error, results <- async.map files, convert-to-json
sorted = results.sort (a, b) -> return ~~a.article - ~~b.article
pros.content.push sorted

file-name = (__dirname).replace "#{path.dirname __dirname}/", ''
pros |> JSON.stringify |> fs.write-file-sync "#{file-name}.json", _
###

vimify - vim2html

Bringing vim syntax highlighting to node!

@author: Johann Philipp Strathausen <strathausen@gmail.com>

###

{ exec } = require 'child_process'
async    = require 'async'
Tempfile = require 'temporary/lib/file'
fs = require 'fs'

# cb(err, style, html)
module.exports = vim2html = (text, type, cb) ->
  unless (type.search /^[a-z-_]+$/i) isnt -1
    return cb new Error 'illegal characters in vimify file type'
  codeFile      = new Tempfile
  htmlFilePath  = codeFile.path + '.html'
  opts = [
    # No swap file
    '-n'
    # Do not detach, wait for session to finish
    '-f'
    '+"set columns=79"'
    '+"syn on"'
    # Do not use <font> tags, but css
    '+"let html_use_css=1"'
    '+"let use_xhtml=1"'
    '+"set filetype=' + type + '"'
    '+"run! syntax/2html.vim"'
    '+"w ' + htmlFilePath + '"'
    '+"qa!"'
    codeFile.path
  ]
  async.series
    # write the source code to a temporary file
    codeFile : (cb) -> codeFile.writeFile text, 'utf8', cb

    # let vim convert the source code to html
    vim      : async.apply exec, 'vim ' + (opts.join ' ')

    # read the resulting html file containing css and html markup
    htmlFile : async.apply fs.readFile, htmlFilePath, 'utf8'

    # clean up temporary files
    delCode  : (cb) -> codeFile.unlink cb
    delHtml  : async.apply fs.unlink, htmlFilePath

  , (err, { htmlFile }) ->
    return cb err if err

    { style, html } = parseHtml htmlFile
    cb null, style, html

module.exports.parseHtml = parseHtml = (rawHtml) ->
  # vim provides an entire html file, but we only need style and code part
  parts = rawHtml.split ///
    <style\stype="text/css">\n|</style>|<pre>\n|</pre>\n</body>\n</html>\n
  ///
  [ a, style, b, html ] = parts

  # styling <body> and <pre> is nonsense, we don't want that
  style = style.replace /\n(body|pre)[^\n]*/g, ''

  { style, html }

unless module.parent
  text = """
  vimify = require 'vimify'
  vimify 'x = (y) -> y', 'coffee', (err, style, html) ->
    console.log 'the css', style
    console.log 'the markup', html
  """
  vim2html text, 'coffee', (err, style, html) ->
    console.error err
    console.log 'finished', style, html

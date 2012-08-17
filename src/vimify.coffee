###

vimify - vim2html

Bringing vim syntax highlighting to node!

@author: Johann Philipp Strathausen <strathausen@gmail.com>

###

fs       = require 'fs'
_        = require 'underscore'
async    = require 'async'
Tempfile = require 'temporary/lib/file'
{ exec } = require 'child_process'

# cb(err, style, html)
module.exports = vim2html = (text, type, options, cb=options) ->
  if (type.search /^[a-z-_]+$/i) is -1
    return cb new Error 'illegal characters in type'
  options      = [] unless _.isArray options
  options      = options.map (o) -> '+"' + o + '"'
  codeFile     = new Tempfile
  htmlFilePath = codeFile.path + '.xhtml'
  opts = [
    '-n' # no swap file
    '-f' # do not detach, wait for session to finish
    '+"set columns=85 lines=42"'
    '+"syn on"'
    '+"let html_use_css=1"'
    '+"let use_xhtml=1"'
    '+"set filetype=' + type + '"'
    options...
    '+"run! syntax/2html.vim"'
    '+"wq!"'
    '+"q!"'
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

    # vim provides an entire html file, but we only need style and code part
    parts = htmlFile.split ///
      <style\stype="text/css">\n|</style>|<pre>\n|</pre>\n</body>\n</html>\n
    ///
    [ a, style, b, html ] = parts

    # styling <body> and <pre> is nonsense, we don't want that
    style = style.replace /\n(body|pre)[^\n]*/g, ''
    cb null, style, html

unless module.parent
  text = """
  vimify = require 'vimify'
  vimify 'x = (y) -> y', 'coffee', (err, style, html) ->
    console.log 'the css', style
    console.log 'the markup', html
  """
  vim2html text, 'coffee', (err, style, html) ->
    console.log 'finished', style, html

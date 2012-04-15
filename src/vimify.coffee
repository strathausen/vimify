###

vim2html

a node module to bring vim syntax highlighting to node

@author: Johann Philipp Strathausen <strathausen@gmail.com>

###

{ exec } = require 'child_process'
fs       = require 'fs'
async    = require 'async'

# cb(err, style, html)
module.exports = vim2html = (text, type, cb) ->
  unless type.match /^[a-z-_]+$/i
    return cb new Error 'illegal characters in type'
  tempdir  = process.env.TEMP or '/tmp'
  codeFile = tempdir + '/node-vim2html-' + Math.random()
  htmlFile = codeFile + '.html'
  opts = [
    '-n' # no swap file
    '-f' # do not detach, wait for session to finish
    '+"set columns=85 lines=42"'
    '+"syn on"'
    '+"let html_use_css=1"'
    '+"let use_xhtml=1"'
    '+"set filetype=' + type + '"'
    '+"run! syntax/2html.vim"'
    '+"wq!"'
    '+"q!"'
    codeFile
  ]
  async.series
    # write the source code to a temporary file
    codeFile : async.apply fs.writeFile, codeFile, text

    # let vim convert the source code to html
    # (yeah, I've tried execFile and some things with spawn, but no luck...)
    vim      : async.apply exec, 'vim ' + (opts.join ' ')

    # read the resulting html file containing css and html markup
    htmlFile : async.apply fs.readFile, htmlFile, 'utf8'

    # clean up temporary files
    delCode  : async.apply fs.unlink, codeFile
    delHtml  : async.apply fs.unlink, htmlFile

  , (err, { htmlFile }) ->
    return cb err if err

    # vim provides an entire html file, but we only need style and code part
    parts = htmlFile.split /<!--\n|-->|<pre>\n|<\/pre>\n<\/body>\n<\/html>\n/
    [ a, style, b, html ] = parts

    # styling <body> and <pre> is nonsense, we don't want that
    style = style.replace /\n(body|pre)[^\n]*/g, ''
    cb null, style, html

unless module.parent
  text="""
  vimify = require 'vimify'
  vimify 'x = (y) -> y', 'coffee', (err, style, html) ->
    console.log 'the css', style
    console.log 'the markup', html
  """
  vim2html text, 'coffee', (err, style, html) ->
    console.log 'finished', style, html

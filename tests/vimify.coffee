assert = require 'assert'
fs = require 'fs'
vimify = require '../src/vimify'
result = {}

describe 'vimify', ->
  it 'running vimify', (done) ->
    vimify 'x = (y) -> y', 'coffee', (err, style, html) ->
      result = { err, style, html }
      do done

  it 'should run without errors', ->
      assert.equal result.err, null

  it 'should provide style as string', ->
      assert.equal typeof result.style, 'string'

  it 'should provide html as string', ->
      assert.equal typeof result.html, 'string'

  it 'should crash when using fancy stuff as a file type', ->
    vimify 'something', ';/', (err) ->
      assert err

  describe 'parser', ->
    it 'vim 7.2 output', ->
      rawHtml = fs.readFileSync __dirname + '/out_vim7-2.html', 'utf8'
      { style, html } = vimify.parseHtml rawHtml
      assert typeof style, 'string'
      assert typeof html, 'string'
      assert.equal style, """
<!--
.Statement { color: #f0e68c; font-weight: bold; }
.Special { color: #ffdead; }
-->

"""
      assert.equal html, 'x <span class="Statement">=</span> <span class="Special">(</span>y<span class="Special">)</span> <span class="Statement">-&gt;</span> y\n'

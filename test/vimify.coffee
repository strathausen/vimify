assert = require 'assert'
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

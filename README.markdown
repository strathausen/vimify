# vimify

Making your code ready for the internet age! Using fancy html and css directly
from your local vim expert!

## usage

    vimify = require 'vimify'
    vimify 'x = (y) -> y', 'coffee', (err, style, html) ->
      console.log 'the css', style
      console.log 'the markup', html

## author

Johann Philipp Strathausen <strathausen@gmail.com>

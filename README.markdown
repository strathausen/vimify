# vimify

Making your source code ready for the internet age! Using fancy html and css,
directly from your local vim expert!

## usage

    vimify = require 'vimify'
    vimify 'x = (y) -> y', 'coffee', (err, style, html) ->
      console.log 'the css', style
      console.log 'the markup', html

## todo

Make the code nicer! Use spawn or something to avoid using temporary files.
The html parsing is a little bit ugly. All this is just a quick prototype.
Add more detailed tests.

## author

Johann Philipp Strathausen <strathausen@gmail.com>

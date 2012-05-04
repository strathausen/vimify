# vimify

Making your source code ready for the internet age! Using fancy html and css,
directly from your local vim expert!

## usage

    vimify = require 'vimify'
    vimify 'x = (y) -> y', 'coffee', (err, style, html) ->
      console.log 'the css', style
      console.log 'the markup', html

## todo

All this is just a quick prototype.
Here's what I think could be done in the future:

- Make the code more elegant!
- Use spawn or something to avoid using temporary files.
- The html parsing is a little bit ugly.
- Add more detailed tests.
- Have it work on windows.


## author

Johann Philipp Strathausen <strathausen@gmail.com>

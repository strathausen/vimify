/*

vimify - vim2html

Bringing vim syntax highlighting to node!

@author: Johann Philipp Strathausen <strathausen@gmail.com>
*/
var Tempfile, async, exec, fs, text, vim2html, _,
  __slice = Array.prototype.slice;

fs = require('fs');

_ = require('underscore');

async = require('async');

Tempfile = require('temporary/lib/file');

exec = require('child_process').exec;

module.exports = vim2html = function(text, type, options, cb) {
  var codeFile, htmlFilePath, opts;
  if (cb == null) cb = options;
  if ((type.search(/^[a-z-_]+$/i)) === -1) {
    return cb(new Error('illegal characters in type'));
  }
  if (!_.isArray(options)) options = [];
  options = options.map(function(o) {
    return '+"' + o + '"';
  });
  codeFile = new Tempfile;
  htmlFilePath = codeFile.path + '.xhtml';
  opts = ['-n', '-f', '+"set columns=85 lines=42"', '+"syn on"', '+"let html_use_css=1"', '+"let use_xhtml=1"', '+"set filetype=' + type + '"'].concat(__slice.call(options), ['+"run! syntax/2html.vim"'], ['+"wq!"'], ['+"q!"'], [codeFile.path]);
  return async.series({
    codeFile: function(cb) {
      return codeFile.writeFile(text, 'utf8', cb);
    },
    vim: async.apply(exec, 'vim ' + (opts.join(' '))),
    htmlFile: async.apply(fs.readFile, htmlFilePath, 'utf8'),
    delCode: function(cb) {
      return codeFile.unlink(cb);
    },
    delHtml: async.apply(fs.unlink, htmlFilePath)
  }, function(err, _arg) {
    var a, b, html, htmlFile, parts, style;
    htmlFile = _arg.htmlFile;
    if (err) return cb(err);
    parts = htmlFile.split(/<style\stype="text\/css">\n|<\/style>|<pre>\n|<\/pre>\n<\/body>\n<\/html>\n/);
    a = parts[0], style = parts[1], b = parts[2], html = parts[3];
    style = style.replace(/\n(body|pre)[^\n]*/g, '');
    return cb(null, style, html);
  });
};

if (!module.parent) {
  text = "vimify = require 'vimify'\nvimify 'x = (y) -> y', 'coffee', (err, style, html) ->\n  console.log 'the css', style\n  console.log 'the markup', html";
  vim2html(text, 'coffee', function(err, style, html) {
    return console.log('finished', style, html);
  });
}

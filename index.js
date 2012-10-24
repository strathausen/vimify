/*

vimify - vim2html

Bringing vim syntax highlighting to node!

@author: Johann Philipp Strathausen <strathausen@gmail.com>
*/
var Tempfile, async, exec, fs, parseHtml, text, vim2html;

exec = require('child_process').exec;

async = require('async');

Tempfile = require('temporary/lib/file');

fs = require('fs');

module.exports = vim2html = function(text, type, cb) {
  var codeFile, htmlFilePath, opts;
  if ((type.search(/^[a-z-_]+$/i)) === -1) {
    return cb(new Error('illegal characters in vimify file type'));
  }
  codeFile = new Tempfile;
  htmlFilePath = codeFile.path + '.html';
  opts = ['-n', '-f', '+"set columns=79"', '+"syn on"', '+"let html_use_css=1"', '+"let use_xhtml=1"', '+"set filetype=' + type + '"', '+"run! syntax/2html.vim"', '+"w ' + htmlFilePath + '"', '+"qa!"', codeFile.path];
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
    var html, htmlFile, style, _ref;
    htmlFile = _arg.htmlFile;
    if (err) return cb(err);
    _ref = parseHtml(htmlFile), style = _ref.style, html = _ref.html;
    return cb(null, style, html);
  });
};

module.exports.parseHtml = parseHtml = function(rawHtml) {
  var a, b, html, parts, style;
  parts = rawHtml.split(/<style\stype="text\/css">\n|<\/style>|<pre>\n|<\/pre>\n<\/body>\n<\/html>\n/);
  a = parts[0], style = parts[1], b = parts[2], html = parts[3];
  style = style.replace(/\n(body|pre)[^\n]*/g, '');
  return {
    style: style,
    html: html
  };
};

if (!module.parent) {
  text = "vimify = require 'vimify'\nvimify 'x = (y) -> y', 'coffee', (err, style, html) ->\n  console.log 'the css', style\n  console.log 'the markup', html";
  vim2html(text, 'coffee', function(err, style, html) {
    console.error(err);
    return console.log('finished', style, html);
  });
}

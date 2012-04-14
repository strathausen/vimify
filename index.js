/*

vim2html

a node module to bring vim syntax highlighting to node

@author: Johann Philipp Strathausen <strathausen@gmail.com>
*/
var async, exec, fs, vim2html;

exec = require('child_process').exec;

fs = require('fs');

async = require('async');

module.exports = vim2html = function(text, type, cb) {
  var codeFile, htmlFile, opts, tempdir;
  if (!type.match(/^[a-z-_]+$/i)) {
    return cb(new Error('illegal characters in type'));
  }
  tempdir = process.env.TEMP || '/tmp';
  codeFile = tempdir + '/node-vim2html-' + Math.random();
  htmlFile = codeFile + '.html';
  opts = ['-n', '-f', '+"set columns=85 lines=42"', '+"syn on"', '+"let html_use_css=1"', '+"let use_xhtml=1"', '+"set filetype=' + type + '"', '+"run! syntax/2html.vim"', '+"wq!"', '+"q!"', codeFile];
  return async.series({
    codeFile: async.apply(fs.writeFile, codeFile, text),
    vim: async.apply(exec, 'vim ' + (opts.join(' '))),
    htmlFile: async.apply(fs.readFile, htmlFile, 'utf8'),
    delCode: async.apply(fs.unlink, codeFile),
    delHtml: async.apply(fs.unlink, htmlFile)
  }, function(err, _arg) {
    var a, b, html, htmlFile, parts, style;
    htmlFile = _arg.htmlFile;
    if (err) return cb(err);
    parts = htmlFile.split(/<!--\n|-->|<pre>\n|<\/pre>\n<\/body>\n<\/html>\n/);
    a = parts[0], style = parts[1], b = parts[2], html = parts[3];
    style = style.replace(/\n(body|pre)[^\n]*/g, '');
    return cb(null, style, html);
  });
};

if (!module.parent) {
  vim2html('@foo "hoo"', 'coffee', function(err, style, html) {
    return console.log('finished', style, html);
  });
}

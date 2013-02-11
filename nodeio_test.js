/*!
 * app.js
 * Copyright(c) 2013 huangjian <hj1986@gmail.com>
 * MIT Licensed
 */


/**
 * Module dependencies.
 */

var nodeIO = require('node.io');

exports.job = new nodeIO.Job({
  //input: function() {
  //  this.inputStream(stream);
  //  this.input.apply(this, arguments);
  //},
  input: '/home/work',
  //run: function (line) {
  //  this.emit("hello world" + line);
  //},
  run: function(full_path) {
    console.log(full_path);
    this.emit();
  }
  //output: function (lines) {
  //  write_stream.write(lines.join('\n'));
  //},
});


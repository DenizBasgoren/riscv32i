let elf =require( "./elf.js");
let layouter =require( "./layout.js");
let analyzer =require( "./analyze/index.js");

const elfFile = {
  "parse": elf.parse,
  "format": elf.format,
  "validate": elf.validate,

  "layout": layouter.layout,
  "delayout": layouter.delayout,

  "analyze": analyzer.analyze,
  "generate": analyzer.generate
};

module.exports = elfFile;

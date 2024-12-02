let assert = require( "assert");

const assign = function () {
  let result = Object.create(null);

  Array.from(arguments).forEach((arg) => {
    assert(typeof arg === "object");
    assert(!Array.isArray(arg));

    Object.keys(arg).filter((key) => arg[key] !== undefined).forEach((key) => {
      result[key] = arg[key];
    });
  });

  return result;
};

const util = {
  assign
};

module.exports = util;

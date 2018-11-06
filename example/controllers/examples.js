'use strict';
module.exports = {

  helloWorld: function(req, res, next) {
    return res.status(200).send('hello world');
  },

};

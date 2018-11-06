'use strict';
const express = require('express');
const exampleRoutes = require('./routes/examples');
const errorMiddleware = require('./errors/middleware');

module.exports = function(app) {
  // mount api routes on to api router
  const apiRouter = express.Router();
  apiRouter.use('/examples', exampleRoutes);

  // mount api router on to app
  app.use('/api', apiRouter);

  // mount middleware to handle errors
  app.use(errorMiddleware)
};

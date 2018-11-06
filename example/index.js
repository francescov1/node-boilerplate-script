'use strict';
Promise = require('bluebird');
const config = require('./config/main');
const express = require('express');

const router = require('./router.js');
const bodyParser = require('body-parser');

const app = express();

app.use(bodyParser.json());

router(app);

app.listen(config.port, () => {
  console.log(`server listening on port ${config.port}...`)
});

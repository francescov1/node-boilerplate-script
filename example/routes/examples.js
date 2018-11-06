'use strict';
const exampleController = require('../controllers/examples');
const express = require('express');
const router = express.Router();

router.get('/hello', exampleController.helloWorld);

module.exports = router;

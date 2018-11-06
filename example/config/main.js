'use strict';
if (process.env.NODE_ENV !== 'production') require('dotenv').config();

module.exports = {
  port: process.env.PORT || 3000,
  node_env: process.env.NODE_ENV || 'development'
};

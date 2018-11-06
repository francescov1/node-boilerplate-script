#!/bin/bash

npm init --force
# figure out how to do this
: '
node > package.json << EOF
var data = require('./package.json');
data.scripts.start = 'node index.js';
console.log(JSON.stringify(data));
EOF
'

mkdir controllers routes models config errors
touch index.js router.js config/main.js errors/custom.js errors/middleware.js .env .gitignore controllers/examples.js routes/examples.js models/user.js
npm install bluebird express body-parser mongoose
npm install --save-dev dotenv

cat > index.js <<- EOM
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
  console.log(\`server listening on port \${config.port}...\`)
});
EOM

cat > router.js <<- EOM
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
EOM

cat > config/main.js <<- EOM
'use strict';
if (process.env.NODE_ENV !== 'production') require('dotenv').config();

module.exports = {
  port: process.env.PORT || 3000,
  node_env: process.env.NODE_ENV || 'development'
};
EOM

cat > .env <<- EOM
NODE_ENV=development
PORT=3000
EOM

cat > .gitignore <<- EOM
**/node_modules/*
**/.env
EOM

cat > controllers/examples.js <<- EOM
'use strict';
module.exports = {

  helloWorld: function(req, res, next) {
    return res.status(200).send('hello world');
  },

};
EOM

cat > routes/examples.js <<- EOM
'use strict';
const exampleController = require('../controllers/examples');
const express = require('express');
const router = express.Router();

router.get('/hello', exampleController.helloWorld);

module.exports = router;
EOM

cat > errors/middleware.js <<- EOM
'use strict';

// error handling middlewear
function errorHandler(err, req, res, next) {
  console.error(err.stack);

  var status = err.status || err.statusCode || err.code;
  return res.status(status >= 100 && status < 600 ? status : 500).send({
    error: {
      type: err.name || err.type,
      message: err.message
    }
  });
}

module.exports = errorHandler;
EOM

cat > errors/custom.js <<- EOM
'use strict';

class AppError extends Error {
  constructor(message, status) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
    this.status = status || 500;
  }
}

class UnauthorizedError extends AppError {
  constructor(message) {
    super(message || "Unauthorized", 403);
  }
}

class NotFoundError extends AppError {
  constructor(message) {
    super(message || "Requested resource not found", 404);
  }
}

class NotAllowedError extends AppError {
  constructor(message) {
    super(message || "Operation not allowed", 405);
  }
}

class UnknownError extends AppError {
  constructor(message) {
    super(message || "Unknown error, developers have been notified", 400);
  }
}

module.exports = {
  UnauthorizedError,
  NotFoundError,
  NotAllowedError,
  UnknownError
};
EOM


cat > models/user.js <<- EOM
'use strict';
const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const UserSchema = new Schema({
  name: { type: String, required: true },
  email: {
    type: String,
    lowercase: true,
    unique: "Email is already in use",
    required: true,
    match: /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/
  },
});

module.exports = mongoose.model("User", UserSchema);
EOM

echo "Complete!"
echo "run \`npm start\` and test server at http://localhost:3000/api/examples/hello"

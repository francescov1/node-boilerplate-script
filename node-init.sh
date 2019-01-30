#!/bin/bash

# init npm and replace test script with start script
npm init --force
sed -i "" "s/\"test.*/\"start\": \"node index.js\"/" package.json

mkdir controllers routes models config errors
npm install bluebird express body-parser mongoose dotenv helmet

# write index.js boilerplate
cat > index.js <<- EOM
'use strict';
Promise = require('bluebird');
const config = require('./config/main');
const express = require('express');
const helmet = require('helmet');
const bodyParser = require('body-parser');

const router = require('./router.js');

const app = express();

app.use(helmet());
app.use(bodyParser.json());

router(app);

app.listen(config.port, () => {
  console.log(\`server listening on port \${config.port}...\`)
});
EOM

# write router.js boilerplate
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

  // mount catch all route
  app.all("*", (req, res) => res.status(200).send("My Node.js API"));
};
EOM

# write config/main.js boilerplate
cat > config/main.js <<- EOM
'use strict';
require('dotenv').config();

module.exports = {
  port: process.env.PORT || 3000,
  node_env: process.env.NODE_ENV || 'development'
};
EOM

# write .env boilerplate
cat > .env <<- EOM
NODE_ENV=development
PORT=3000
EOM

# write controllers/examples.js boilerplate
cat > controllers/examples.js <<- EOM
'use strict';
module.exports = {

  helloWorld: function(req, res, next) {
    return res.status(200).send('hello world');
  },

};
EOM

# write routes/examples.js boilerplate
cat > routes/examples.js <<- EOM
'use strict';
const exampleController = require('../controllers/examples');
const express = require('express');
const router = express.Router();

router.get('/hello', exampleController.helloWorld);

module.exports = router;
EOM

# write errors/middleware.js boilerplate
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

# write errors/custom.js boilerplate
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

# write models/user.js boilerplate
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

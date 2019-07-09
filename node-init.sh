#!/bin/bash

# init npm and replace test script with start script
npm init -y
sed -i "" "s/\"test\":.*/\"start\": \"node index.js\"/" package.json

mkdir routes models config errors
npm install bluebird express body-parser mongoose dotenv helmet morgan

# write index.js boilerplate
cat > index.js <<- EOM
'use strict';
Promise = require('bluebird');
const config = require('./config');
const express = require('express');
const helmet = require('helmet');
const bodyParser = require('body-parser');
const logger = require("morgan");

const routes = require('./routes');
const errors = require('./errors/middleware');

const app = express();

// basic middleware
app.use(helmet());
app.use(logger(config.node_env === "production" ? "combined" : "dev"));
app.use(bodyParser.json());

// api routes
app.use('/api', routes)

// error middleware
app.use(errors)

app.all("*", (req, res) => res.status(200).send("My Node.js API"));

app.listen(config.port, () => {
  console.log(\`Server listening on port \${config.port}...\`)
});
EOM

# write routes/index.js boilerplate
cat > routes/index.js <<- EOM
'use strict';
const express = require('express');
const exampleRoutes = require('./examples');

// mount routes on to api router
const apiRouter = express.Router();
apiRouter.use('/examples', exampleRoutes);

module.exports = apiRouter;
EOM

# write config/index.js boilerplate
cat > config/index.js <<- EOM
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

# write .gitignore boilerplate
cat > .gitignore <<- EOM
**/node_modules/*
**/.env
.DS_Store
EOM

# write routes/examples.js boilerplate
cat > routes/examples.js <<- EOM
'use strict';
const express = require('express');
const router = express.Router();

router.get('/hello', (req, res, next) => {
  return res.status(200).send('hello world');
});

module.exports = router;
EOM

# write errors/middleware.js boilerplate
cat > errors/middleware.js <<- EOM
'use strict';

// error handling middlewear
function errorHandler(err, req, res, next) {
  console.error(err.stack);

  const status = err.status || err.statusCode || err.code || 400;
  return res.status(status >= 100 && status < 600 ? status : 500).send({
    error: {
      type: err.name || err.type,
      message: err.message
    }
  });
}

module.exports = errorHandler;
EOM

# write errors/index.js boilerplate
cat > errors/index.js <<- EOM
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

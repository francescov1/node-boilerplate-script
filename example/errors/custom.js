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

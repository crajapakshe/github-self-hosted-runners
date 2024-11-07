const fs = require("fs");
const path = require("path");
const jwt = require("jsonwebtoken");

// Create a JWT for this application to authenticate
const generateJwt = (appId, privatePemKey) => {
  const payload = {
    // issued at time :: milliseconds => seconds - 10 seconds (for drift)
    iat: Math.floor(Date.now() / 1000) - 10,
    // expiry :: milliseconds => seconds + 10 minutes (max)
    exp: Math.floor(Date.now() / 1000) + 10 * 60 - 10,
    // github app's identifier
    iss: appId,
  };

  const signingOptions = {
    algorithm: "RS256",
  };

  const actualJwt = jwt.sign(payload, privatePemKey, signingOptions);

  return actualJwt;
};
exports.generateJwt = generateJwt;

const isPrivateKey = (str) => {
  const regex = /\s*(\bBEGIN\b).*(PRIVATE KEY\b)\s*/m;
  return regex.test(str);
};
exports.isPrivateKey = isPrivateKey;

const loadPrivateKey = (str) => {
  if (isPrivateKey(str)) {
    return str;
  }

  const actualPath = path.resolve(str);
  if (fs.existsSync(str)) {
    return fs.readFileSync(actualPath, "utf-8");
  }

  const msg = `Unable to load private key. Please check envvars.. ${str} provided.. checked path ${actualPath}`;
  throw new Error(msg);
};
exports.loadPrivateKey = loadPrivateKey;

const { generateJwt, loadPrivateKey } = require("./utils/generate-jwt.js");

const { GITHUB_APP_ID, GITHUB_APP_PRIVATE_KEY } = process.env;

const privateKey = loadPrivateKey(GITHUB_APP_PRIVATE_KEY);

const jwt = generateJwt(GITHUB_APP_ID, privateKey);

console.log(jwt);

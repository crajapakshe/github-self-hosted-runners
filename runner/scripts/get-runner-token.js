const { generateJwt, loadPrivateKey } = require("./utils/generate-jwt.js");
const {
  generateInstallationAccessToken,
} = require("./utils/generate-installation-access-token.js");
const {
  generateOrgRunnerToken,
} = require("./utils/generate-org-runner-token.js");

const {
  GITHUB_APP_ID,
  GITHUB_INSTALLATION_ID,
  GITHUB_APP_PRIVATE_KEY,
  REPO_OWNER,
} = process.env;

const main = async () => {
  const privateKey = loadPrivateKey(GITHUB_APP_PRIVATE_KEY);

  const jwt = generateJwt(GITHUB_APP_ID, privateKey);

  const installationAccessToken = await generateInstallationAccessToken(
    jwt,
    GITHUB_INSTALLATION_ID
  );

  const runnerToken = await generateOrgRunnerToken(
    REPO_OWNER,
    installationAccessToken
  );

  console.log(runnerToken);
};
main();

const { generateJwt, loadPrivateKey } = require("./utils/generate-jwt.js");
const { getInstallationIds } = require("./utils/get-installation-ids.js");

const { GITHUB_APP_ID, GITHUB_APP_PRIVATE_KEY, REPO_OWNER } = process.env;

const main = async () => {
  const privateKey = loadPrivateKey(GITHUB_APP_PRIVATE_KEY);
  const jwt = generateJwt(GITHUB_APP_ID, privateKey);

  // Get all orgs/users that have installed the app
  const results = await getInstallationIds(jwt);

  // Find the id for the REPO_OWNER
  const installation = results.find((res) => res.account.login === REPO_OWNER);

  if (!installation) {
    throw new Error(`This app is not currently installed for "${REPO_OWNER}"`);
  }

  const installationId = installation.id;

  console.log(installationId);
};

main();

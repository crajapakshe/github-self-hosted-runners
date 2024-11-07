const fetch = require("node-fetch");

// Register a runner for this org, with the Installation Access Token
const generateOrgRunnerToken = async (orgName, installationAccessToken) => {
  const headers = {
    Accept: "application/vnd.github.v3+json",
    Authorization: `token ${installationAccessToken}`,
    "Content-Type": "application/json",
  };
  const result = await fetch(
    `https://api.github.com/orgs/${orgName}/actions/runners/registration-token`,
    {
      method: "POST",
      headers,
    }
  )
    .then((res) => res.json())
    .then((res) => res.token);

  return result;
};
exports.generateOrgRunnerToken = generateOrgRunnerToken;

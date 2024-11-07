const fetch = require("node-fetch");

// Get an installation access token for a single application installation
const generateInstallationAccessToken = async (jwt, installationId) => {
  const headers = {
    Accept: "application/vnd.github.v3+json",
    Authorization: `Bearer ${jwt}`,
    "Content-Type": "application/json",
  };

  const result = await fetch(
    `https://api.github.com/app/installations/${installationId}/access_tokens`,
    {
      method: "POST",
      headers,
      body: JSON.stringify({ organization_self_hosted_runners: "write" }),
    }
  )
    .then((res) => res.json())
    .then((res) => res.token);

  return result;
};
exports.generateInstallationAccessToken = generateInstallationAccessToken;

const fetch = require("node-fetch");

const getInstallationIds = async (jwt) => {
  const headers = {
    Accept: "application/vnd.github.v3+json",
    Authorization: `Bearer ${jwt}`,
    "Content-Type": "application/json",
  };

  const results = await fetch("https://api.github.com/app/installations", {
    method: "GET",
    headers,
  }).then((res) => res.json());

  return results;
};

exports.getInstallationIds = getInstallationIds;

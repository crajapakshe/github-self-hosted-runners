#!/bin/bash

# ACTIONS_RUNNER_INPUT_NAME is used by config.sh
ACTIONS_RUNNER_INPUT_NAME=$HOSTNAME
echo "ACTIONS_RUNNER_INPUT_NAME = ${ACTIONS_RUNNER_INPUT_NAME}"

echo "GITHUB_USER = ${GITHUB_USER}"

echo "REPO_OWNER = ${REPO_OWNER}"
echo "REPO_NAME = ${REPO_NAME}"

#####################
## Register Runner ##
#####################

#####
## Labels
#####

if [ -z "$RUNNER_LABELS" ]
then
  RUNNER_LABELS="k8s-runner"
else
  RUNNER_LABELS="${RUNNER_LABELS},k8s-runner"
fi

echo "RUNNER_LABELS = ${RUNNER_LABELS}"

#####
## Groups
#####

if [ -z "$RUNNER_GROUPS" ]
then
  RUNNER_GROUPS="Default"
else
  RUNNER_GROUPS="${RUNNER_GROUPS}"
fi

echo "RUNNER_GROUPS = ${RUNNER_GROUPS}"

#####
## Flags
#####

RUNNER_FLAGS=""

if [ -z "$SINGLE_USE" ]
then
  # Do nothing
  RUNNER_FLAGS=$RUNNER_FLAGS
else
  RUNNER_FLAGS="${RUNNER_FLAGS} --ephemeral"
fi

echo "RUNNER_FLAGS = ${RUNNER_FLAGS}"

#####
## GitHub App Authentication
#####

if [ -z "$GITHUB_APP_ID" ]
then
  ## This is NOT setup as a GitHub App... do nothing special
  echo "GitHub App :: No GITHUB_APP_ID found"
else
  ## Authenticate as a GitHub App
  echo "GITHUB_APP_ID = ${GITHUB_APP_ID}"
  echo "GitHub App :: Using node to get RUNNER_TOKEN"

  ## Get Runner Token via Node script
  RUNNER_TOKEN=$(node ./scripts/get-runner-token.js)
fi

#####
## Repo level vs Org level
#####

if [ -z "$REPO_NAME" ]
then
  echo "No REPO_NAME specified -- Registering Runner to Org"
  ## https://docs.github.com/en/rest/reference/actions#create-a-registration-token-for-an-organization  
  RUNNER_URL="https://github.com/${REPO_OWNER}"

  if [ -z "$RUNNER_TOKEN" ]
  then
    echo "Fetching Org RUNNER_TOKEN from GH API"
    RUNNER_TOKEN="$(curl -sS -u "${GITHUB_USER}:${GITHUB_TOKEN}" --location --request POST "https://api.github.com/orgs/${REPO_OWNER}/actions/runners/registration-token" --header 'Accept: application/vnd.github.v3+json' | jq -r .token)"
  else
    echo "Using RUNNER_TOKEN provided"
    echo $RUNNER_TOKEN
  fi
else

  echo "REPO_NAME specified -- Registering Runner to Repo: ${REPO_NAME}"
  RUNNER_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"

  if [ -z "$RUNNER_TOKEN" ]
  then
    echo "Fetching Repo RUNNER_TOKEN from GH API"
    RUNNER_TOKEN="$(curl -sS -u "${GITHUB_USER}:${GITHUB_TOKEN}" --location --request POST "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/registration-token" --header 'Accept: application/vnd.github.v3+json' | jq -r .token)"
  else
    echo "Using RUNNER_TOKEN provided"
    echo $RUNNER_TOKEN
  fi
fi

######################
## Configure Runner ##
######################

echo "RUNNER_TOKEN = ${RUNNER_TOKEN}"
echo "RUNNER_URL = ${RUNNER_URL}"

cleanup() {
  echo "Removing RUNNER_TOKEN ..."
  /runner/config.sh remove --token "$RUNNER_TOKEN"
}

# Create GH worker directory
RUNNER_WORKDIR=${RUNNER_WORKDIR:-/github/${ACTIONS_RUNNER_INPUT_NAME}}
[[ ! -d "${RUNNER_WORKDIR}" ]] && mkdir -p "${RUNNER_WORKDIR}"

# No longer exists with GITHUB_APP_ID approach
export GITHUB_TOKEN="cleared"

export RUNNER_ALLOW_RUNASROOT=1
/runner/config.sh --disableupdate --unattended --replace --work "$RUNNER_WORKDIR" --url "$RUNNER_URL" --token "$RUNNER_TOKEN" --labels $RUNNER_LABELS --runnergroup $RUNNER_GROUPS $RUNNER_FLAGS

##################
## Start Runner ##
##################

/runner/bin/runsvc.sh

## Clean up on exit
cleanup
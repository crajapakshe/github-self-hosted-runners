# Dockerfile for DevOps runner
# Set the base image to Ubuntu
ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

# Define build arguments
ARG NODE_VERSION=20
ARG PYTHON_VERSION=3.11

# Install necessary packages
RUN apt-get update && \
    apt-get -y install apt-transport-https \
    ca-certificates \
    curl \
    tar \
    jq \
    build-essential \
    gnupg2 \
    iputils-ping \
    software-properties-common \
    p7zip-full \
    rsync

# Setup Docker 
# Add Docker's official GPG key:
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc

## Add the repository to Apt sources
RUN echo "deb [signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update

## Install Docker
RUN apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh

# Install node
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash
RUN apt-get install -y nodejs

# Install Python
RUN apt-get update && \
    apt-get -y install python3 python3-venv python3-pip

## Create Python venv
RUN python3 -m venv env
# SHELL is currently `sh` not `bash`, so `source` doesn't work in `sh`
RUN /bin/bash -c 'source env/bin/activate'

## DevOps custom installations
# Install tzdata to establish default zone
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
# Install software-properties-common
RUN apt-get update && apt-get install software-properties-common -y
# Add deadnakes configuration
RUN add-apt-repository ppa:deadsnakes/ppa -y
# Install specific version of python
RUN apt-get update && apt-get -y install python${PYTHON_VERSION} -y
# Install pip
RUN apt-get -y install python${PYTHON_VERSION}-venv python3-pip
# Create and activate virtual environment
RUN python${PYTHON_VERSION} -m venv env
RUN PATH="env/bin:$PATH"

## Installing GH CLi
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
RUN chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
RUN apt update 
RUN apt install gh -y

# Install GH Runner
ARG GH_RUNNER_VERSION=2.320.0
WORKDIR /runner
RUN curl -o actions.tar.gz --location "https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-arm64-${GH_RUNNER_VERSION}.tar.gz" && \
    tar -zxf actions.tar.gz && \
    rm -f actions.tar.gz && \
    ./bin/installdependencies.sh

COPY package*.json ./

RUN npm ci

COPY scripts ./scripts
COPY entrypoint.sh .
ENV RUNNER_ALLOW_RUNASROOT=1
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/runner/entrypoint.sh"]
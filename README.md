# GitHub Self-Hosted Runners

[![Get Active Self-Hosted Runners](https://github.com/crajapakshe/github-self-hosted-runners/actions/workflows/get-active-self-hosted-runners.yml/badge.svg)](https://github.com/crajapakshe/github-self-hosted-runners/actions/workflows/get-active-self-hosted-runners.yml) [![Test Runners](https://github.com/crajapakshe/github-self-hosted-runners/actions/workflows/test-self-hosted-runners.yml/badge.svg)](https://github.com/crajapakshe/github-self-hosted-runners/actions/workflows/test-self-hosted-runners.yml)

This guide will walk you through the process of installing and configuring a Self-Hosted GitHub Actions Runner on Docker Desktop.

### Prerequisites
- **Repository Access**: Create a GitHub Organization and fork one of your repositories to it.
- **Docker Desktop**: Use either [Docker Desktop](https://docs.docker.com/desktop/) or [Docker Engine](https://docs.docker.com/engine/), based on your preference.
- **Docker Hub**: Optional, for publishing the image to the [Docker Hub](https://hub.docker.com/r/crajapakshe429/github-self-hosted-runners) image registry.

The following steps outline the installation of a Self-Hosted GitHub Actions Runner on Docker Desktop/Engine:

## Step 1: Build Runner Image
To create a GitHub self-hosted runner image, follow these steps:

1. **Build the Docker Image**: Create a Docker image for the GitHub runner using a specified Dockerfile. Customize the GitHub runner version by setting the `GH_RUNNER_VERSION` build argument.
  ```bash
  docker buildx build --build-arg GH_RUNNER_VERSION=2.320.0 --provenance=true --sbom=true -t crajapakshe429/github-self-hosted-runners -f runner/runner-devops.Dockerfile ./runner/
  ```

2. **Publish the Docker Image**: Push the built image to a [Docker registry](https://hub.docker.com/r/crajapakshe429/github-self-hosted-runners) for reuse and deployment across different environments.
  ```bash
  docker image push crajapakshe429/github-self-hosted-runners
  ```

3. **Build and Publish in One Step**: Combine the build and publish steps into a single command to build the image and push it to the Docker registry in one go.
  ```bash
  docker buildx build --build-arg GH_RUNNER_VERSION=2.320.0 --provenance=true --sbom=true -t crajapakshe429/github-self-hosted-runners -f runner/runner-devops.Dockerfile --push ./runner/
  ```

## Step 2: Run Runners on Docker Desktop

To run the GitHub self-hosted runner image, use the following command or create a `.env` file from [.env.example](./runner/.env.example) and execute `docker run --rm --name github-runners --env-file runner/.env crajapakshepbl/github-runners:latest`.

```bash
  docker run --rm --name your_container_name \
       -e GITHUB_USER=your_github_user \
       -e REPO_OWNER=your_repo_owner \
       -e REPO_NAME=your_repo_name \
       -e SINGLE_USE=yep \
       -e RUNNER_LABELS=your_runner_labels \
       -e RUNNER_GROUPS=your_runner_groups \
       -e HOSTNAME=your_hostname \
       -e GITHUB_TOKEN=your_github_token \
       your_image_name
```

Replace the environment variables with your specific values:

- `GITHUB_USER`: Your GitHub username.
- `REPO_OWNER`: The owner of the repository where the runner will be used.
- `REPO_NAME`: The name of the repository.
- `RUNNER_LABELS`: Labels to assign to the runner.
- `RUNNER_GROUPS`: Groups to assign to the runner.
- `HOSTNAME`: The hostname for the runner.
- `your_image_name`: The name of the Docker image you built and published.

When the runners are up and running, executing the [Get Active Self-Hosted Runners](https://github.com/crajapakshe/github-self-hosted-runners/actions/workflows/get-active-self-hosted-runners.yml) action will provide a summary of active runners as shown below.

![get active runners](./images/get_active_runners_summary.png)

## Step 3: Configure Workflow to Use a Self-Hosted Runner
Go to your repository on GitHub and modify the runner to use `self-hosted` or the `label` (e.g., `devops`) you specified in the Runner Deployment manifest. The [Test Runners](https://github.com/crajapakshe/github-self-hosted-runners/actions/workflows/test-self-hosted-runners.yml) action demonstrates how self-hosted runners can be used in GitHub workflows.

```yml
  name: Test Runners

  on:
    workflow_dispatch:

  jobs:
    test-runner:
    name: Hello Self-Hosted Runner
    runs-on: 
      labels: ["self-hosted", "devops"]
    steps:
      - name: Checkout code
      uses: actions/checkout@v4
      - name: Echo
      run: echo "Hello Self-Hosted Runner!"
```

Since the workflow above is triggered manually, trigger it and wait for the job to build.

![runner info](./images/runner_info.png)
![pod logs](./images/pod_logs.png)
![completed job](./images/completed_job.png)
_The Self-Hosted GitHub Runner is fully functional._

## Contributions
We welcome contributions! Please visit our [Contributing Guide](https://github.com/crajapakshe/github-self-hosted-runners/blob/main/CONTRIBUTING.md) for more details on how to get started.

Thank you to all the contributors who have helped make this project better:

[![Contributors](https://contrib.rocks/image?repo=crajapakshe/github-self-hosted-runners)](https://github.com/crajapakshe/github-self-hosted-runners/graphs/contributors)

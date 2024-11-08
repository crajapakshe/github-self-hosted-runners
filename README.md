# GitHub Self-Hosted Runners

## Build Runner Image
To create a GitHub self-hosted runner image, follow these steps:

1. **Build the Docker Image**: This step involves creating a Docker image for the GitHub runner using a specified Dockerfile. You can customize the GitHub runner version by setting the `GH_RUNNER_VERSION` build argument.
    ```bash
    docker buildx build --build-arg GH_RUNNER_VERSION=2.320.0 --provenance=true --sbom=true -t crajapakshe429/github-self-hosted-runners -f runner/runner-devops.Dockerfile ./runner/
    ```

2. **Publish the Docker Image**: Once the image is built, you can push it to a Docker registry so that it can be reused and deployed across different environments.
    ```bash
    docker image push crajapakshe429/github-self-hosted-runners
    ```

3. **Build and Publish in One Step**: For convenience, you can combine the build and publish steps into a single command, which will build the image and push it to the Docker registry in one go.
    ```bash
    docker buildx build --build-arg GH_RUNNER_VERSION=2.320.0 --provenance=true --sbom=true -t crajapakshe429/github-self-hosted-runners -f runner/runner-devops.Dockerfile --push ./runner/
    ```
## Validate Image run on Docker Desktop

To run the GitHub self-hosted runner image, use the following command:

```bash
docker run -e GITHUB_USER=your_github_user \
           -e REPO_OWNER=your_repo_owner \
           -e REPO_NAME=your_repo_name \
           -e SINGLE_USE=yep \
           -e RUNNER_LABELS=your_runner_labels \
           -e RUNNER_GROUPS=your_runner_groups \
           -e HOSTNAME=your_hostname \
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
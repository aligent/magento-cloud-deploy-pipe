# Aligent Magento Cloud Deploy Pipe

This pipe is used to relay commits to Magento Cloud to trigger deployments.

## YAML Definition

Add the following your `bitbucket-pipelines.yml` file:

```yaml
      - step:
          name: "Git commit relay"
          script:
            - pipe: docker://ghcr.io/aligent/magento-cloud-deploy-pipe:latest
              variables:
                MAGENTO_CLOUD_REMOTE: "user@git-remote.git"
```
## Variables

| Variable              | Usage                                                       |
| --------------------- | ----------------------------------------------------------- |
| MAGENTO_CLOUD_REMOTE      | The git remote where commits will be relayed|
| NR_APP_ID      | (Optional) The NewRelic App ID the deployment marker will be created in|
| NR_USER_KEY      | (Optional) The NewRelic User Key for API Calls |
| NR_ALERT_MUTING_RULE_ID      | (Optional) The NewRelic Alert Mute Rule ID used for suppressing alerts during deployment|
| NR_ACCOUNT_ID      | (Optional) The NewRelic Account ID that the deployment will suppress the alerts|
| MAGENTO_CLOUD_CLI_TOKEN      | (Optional) Magento Cloud Deploy User API token, for automatic redeploy on transient failure|
| DEBUG                 | (Optional) Turn on extra debug information. Default: `false`. |

* Note that you need `nr-deployment.json.template` file under the project root with the content below to enable the NR deployment marker:
```
{
    "deployment": {
        "revision": "GITSHA"
    }
}
```

## Development

The image is built and pushed to `ghcr.io/aligent/magento-cloud-deploy-pipe` on GitHub Container Registry by the [Build](.github/workflows/build.yml) GitHub Actions workflow.

### Triggering a Build

- **Push to `main`**: builds and pushes the `latest` tag
- **Weekly schedule**: rebuilds `latest` from `main` without the build cache, so Alpine package and Magento Cloud CLI updates are picked up
- **Manual**: run the workflow from the Actions tab, or with `gh workflow run build.yml`. Only runs on `main` push the image
- **Pull request**: builds the image without pushing, to check the Dockerfile still works

### Repository Configuration

| Name             | Type     | Purpose                                                                  |
|------------------|----------|--------------------------------------------------------------------------|
| `ALPINE_VERSION` | Variable | Alpine base image version, passed as the `ALPINE_VERSION` build argument |

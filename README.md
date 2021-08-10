# Aligent Magento Cloud Deploy Pipe

This pipe is used to relay commits to Magento Cloud to trigger deployments.

## YAML Definition

Add the following your `bitbucket-pipelines.yml` file:

```yaml
      - step:
          name: "Git commit relay"
          script:
            - pipe: docker://aligent/magento-cloud-deploy-pipe:latest
              variables:
                SECONDARY_REMOTE: "user@git-remote.git"
```
## Variables

| Variable              | Usage                                                       |
| --------------------- | ----------------------------------------------------------- |
| SECONDARY_REMOTE      | The git remote where commits will be relayed|
| DEBUG                 | (Optional) Turn on extra debug information. Default: `false`. |

## Development

Commits published to the `main` branch  will trigger an automated build for the each of the configured PHP version.
Commits to `staging` will do the same but image tags will be suffixed with `-experimiental`.

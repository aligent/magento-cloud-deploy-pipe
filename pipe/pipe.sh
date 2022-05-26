#!/usr/bin/env bash
#
set -e

source "$(dirname "$0")/common.sh"

validate() {
     DEBUG=${DEBUG:=false}

     if [ -z ${MAGENTO_CLOUD_REMOTE} ]; then
          fail "No MAGENTO_CLOUD_REMOTE configured."
     fi
}

setup_ssh_creds() {
     # Setup pipeline SSH 
     INJECTED_SSH_CONFIG_DIR="/opt/atlassian/pipelines/agent/ssh"
     IDENTITY_FILE="${INJECTED_SSH_CONFIG_DIR}/id_rsa_tmp"
     KNOWN_SERVERS_FILE="${INJECTED_SSH_CONFIG_DIR}/known_hosts"
     if [ ! -f ${IDENTITY_FILE} ]; then
          info "No default SSH key configured in Pipelines.\n These are required to push to Magento cloud. \n These should be generated in bitbucket settings at Pipelines > SSH Keys."
          return
     fi
     mkdir -p ~/.ssh
     touch ~/.ssh/authorized_keys
     cp ${IDENTITY_FILE} ~/.ssh/pipelines_id

     if [ ! -f ${KNOWN_SERVERS_FILE} ]; then
          fail "No SSH known_hosts configured in Pipelines."
     fi
     cat ${KNOWN_SERVERS_FILE} >> ~/.ssh/known_hosts
     if [ -f ~/.ssh/config ]; then
          debug "Appending to existing ~/.ssh/config file"
     fi
     echo "IdentityFile ~/.ssh/pipelines_id" >> ~/.ssh/config

     echo "Host *" >> ~/.ssh/config
     echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> ~/.ssh/config

     chmod -R go-rwx ~/.ssh/
}

push_to_secondary_remote() {
     echo "Pushing to Magento Cloud"
     git remote add secondary-remote ${MAGENTO_CLOUD_REMOTE}
     # Fail pipeline on Magento Cloud failure (no appropriate status codes from git push)
     # and print output to bitbucket pipeline stream.
     git push secondary-remote ${BITBUCKET_BRANCH}  2>&1 | tee /dev/stderr | grep -E -i "Opening environment|Everything up-to-date|Deployment completed?|Warmed up page" > /dev/null
}


mute_nr_alerts() {
     if [[ ${NR_ALERT_MUTING_RULE_ID} && ${NR_ACCOUNT_ID} && ${NR_USER_KEY} ]]; then
          sed "s/NR_ACCOUNT_ID/${NR_ACCOUNT_ID}/g" nr-muting-rule.json.template | \
          sed "s/NR_ALERT_MUTING_RULE_ID/${NR_ALERT_MUTING_RULE_ID}/g" | \
          sed "s/RULE_ENABLED/false/" > nr-muting-rule.json # Disable the rule
          curl -s https://api.newrelic.com/graphql -H 'Content-Type: application/json' \
          -H "Api-Key: ${NR_USER_KEY}" -d @nr-muting-rule.json
     fi
}

create_nr_deploy_marker() {
     if [[ ${NR_APP_ID} && ${NR_USER_KEY} ]]; then
          export COMMIT=$(git rev-parse HEAD)
          jq '."deployment"."revision" = env.COMMIT' nr-deployment.json.template > nr-deployment.json
          curl -s https://api.newrelic.com/v2/applications/${NR_APP_ID}/deployments.json -H "Api-Key: ${NR_USER_KEY}" -w "\n"\
          -H "Content-Type: application/json" -d @nr-deployment.json
     fi
}

unmute_nr_alerts() {
     if [[ ${NR_ALERT_MUTING_RULE_ID} && ${NR_ACCOUNT_ID} && ${NR_USER_KEY} ]]; then
          sed "s/NR_ACCOUNT_ID/${NR_ACCOUNT_ID}/g" nr-muting-rule.json.template | \
          sed "s/NR_ALERT_MUTING_RULE_ID/${NR_ALERT_MUTING_RULE_ID}/g" | \
          sed "s/RULE_ENABLED/true/" > nr-muting-rule.json # Re-enable the rule
          curl -s https://api.newrelic.com/graphql -H 'Content-Type: application/json' \
          -H "Api-Key: ${NR_USER_KEY}" -d @nr-muting-rule.json
     fi
}

validate
setup_ssh_creds
mute_nr_alerts
push_to_secondary_remote && create_nr_deploy_marker # Place a marker only when deployment was successful
unmute_nr_alerts

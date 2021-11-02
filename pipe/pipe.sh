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
     chmod -R go-rwx ~/.ssh/
}

push_to_secondary_remote() {
     echo "Pushing to Magento Cloud"
     git remote add secondary-remote ${MAGENTO_CLOUD_REMOTE}
     # Fail pipeline on Magento Cloud failure (no appropriate status codes from git push)
     # and print output to bitbucket pipeline stream.
     git push secondary-remote ${BITBUCKET_BRANCH}  2>&1 | tee /dev/stdout | grep -E -i "Opening environment|Everything up-to-date|Deployment completed?|Warmed up page" > /dev/null
}

validate
setup_ssh_creds
push_to_secondary_remote

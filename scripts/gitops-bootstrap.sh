#!/bin/bash

exec > /tmp/logging.log 2>&1

# --- Error Handling Configuration ---
# Exit immediately if a command exits with a non-zero status.
set -e
# Ensures that ERR trap is inherited by shell functions
set -E
# --- Exit Functions ---
# Function for a clean, successful exit
good_exit() {
  local message="$1"
  echo "INFO: $message"
  echo '{"status": "success", "message": "'"$message"'"}'
  exit 0
}
# Function for failures
bad_exit() {
  local error_message="$1"
  echo "ERROR: $error_message" >&2
  echo '{"status": "failure", "message": "'"$error_message"'"}'
  exit 1
}
# --- Trap Handler for Errors ---
handle_error() {
  local last_command="$BASH_COMMAND"
  local line_number="$BASH_LINENO[0]"
  bad_exit "Script failed at line $line_number executing command: '$last_command'"
}
# Set the trap: When an error occurs, call handle_error
trap 'handle_error' ERR

# --- Script Logic Starts Here ---

echo "#########################################"
echo " Script Start gitops-operator-bootstrap"
echo "Current Date: $(date)"
echo "#########################################"

# Configurable login retry settings
MAX_RETRIES=10
SLEEP_BETWEEN_RETRIES=30


# Conditional logic for enabling or disabling gitops-operator-bootstrap
if [ "${enable}" == true ]; then
   echo "Logging in OpenShift API - ${api_url}..."
     attempt=1
     while (( attempt <= MAX_RETRIES )); do
       if login_output=$(oc login "${api_url}" --username="${admin_username}" --password="${admin_passwd}" 2>&1); then
       #if login_output=$(false); then
          echo "Login successful."
          break
       else
         echo "Login failed (attempt $attempt/$MAX_RETRIES). Retrying in $SLEEP_BETWEEN_RETRIES seconds..."
         (( attempt++ ))
         sleep "$SLEEP_BETWEEN_RETRIES"
       fi
     done
   
  if (( attempt > MAX_RETRIES )); then
    bad_exit "Failed to log in after $MAX_RETRIES attempts."
    exit 1
  fi

  #domain=$(echo ${api_url} | awk -F. '{print $2"."$3"."$4"."$5"."$6}' | sed 's/:443$//')

  if [ -d /tmp/scratch ]; then
    echo "removing old charts"
    rm -rf /tmp/scratch
  fi

  git clone https://github.com/abavage/helm-gitops.git /tmp/scratch
  helm upgrade --install gitops-operator /tmp/scratch/charts/gitops-operator \
  --set csv="${gitops_startingcsv}" \
  -n openshift


  helm upgrade --install gitops-bootstrap /tmp/scratch/charts/gitops-bootstrap \
  --set infrastructureGitPath="${infrastructureGitPath}" \
  --set namespaceGitPath="${namespaceGitPath}" \
  --set cluster_name="${cluster_name}" \
  --set ebsKmsKeyId="${ebsKmsKeyId}" \
  --set efsFileSystemId="${efsFileSystemId}" \
  --set gitRepoUserName="${gitRepoUserName}" \
  --set gitRepoPasswd="${gitRepoPasswd}" \
  --set domain="{$domain}" \
  -n openshift

  HELM=$(helm list -n openshift --no-headers | egrep 'gitops-operator|gitops-bootstrap' | awk '{print $8}' | sort -u)
  if [[ $HELM != deployed ]]; then
    bad_exit "Failed to install the gitops-bootstrap chart"
  else
    good_exit "Helm install of the gitops-bootstrap chart was successful."
  fi

else
  echo "disabled"
  good_exit "disabled this"
fi

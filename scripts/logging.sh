#!/bin/bash

# exec >enable-siem-logging.log 2>&1
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
echo "SIEM Logging Script Start"
echo "Current Date: $(date)"
echo "#########################################"

# Authenticate with ROSA
echo "Attempting ROSA login..."
rosa login -t "${token}"

if [ $? != 0 ]; then
  bad_exit "Unable to login console.redhat.com"
fi 


echo "ROSA login successful."

echo "Enabling SIEM logging for cluster '${cluster}' with ARN: ${siem_role_arn}..."
rosa edit cluster -c "${cluster}" --audit-log-arn "${siem_role_arn}" --yes
good_exit "SIEM logging enabled successfully for cluster '${cluster}'."

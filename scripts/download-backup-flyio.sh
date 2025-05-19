#!/usr/bin/env bash
set -e

# Usage: download-backup-flyio.sh [output_file]
# If output_file is not provided, defaults to profiles-{date-time}.7z in the current directory

show_help() {
  echo "Usage: $0 [output_file]"
  echo "  output_file: Optional. Name of the file to save the backup as."
  echo "              Defaults to profiles-{date-time}.7z in the current directory."
  echo "  --help:      Show this help message and exit."
}

# Check for --help flag
if [[ "$1" == "--help" ]]; then
  show_help
  exit 0
fi

# Get current date-time for default filename (format: YYYY-MM-DD_HH-MM-SS)
NOW=$(date '+%Y-%m-%d_%H-%M-%S')
DEFAULT_FILE="profiles-$NOW.7z"
OUTPUT_FILE="${1:-$DEFAULT_FILE}"
echo "Backup will be saved as: $OUTPUT_FILE"

# Configurable max retries (default 5)
MAX_RETRIES=${MAX_RETRIES:-5}
RETRY_COUNT=0

# Get machine ID
MACHINE_ID=$(flyctl machine list --json | jq -r '.[0].id')
echo "Working with machine ID: $MACHINE_ID"

# Use TMPDIR or /tmp for start_output.txt
TMPDIR=${TMPDIR:-/tmp}
START_OUTPUT_FILE="$TMPDIR/start_output.txt"

# Ensure the machine is started
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  echo "Attempt $(($RETRY_COUNT+1)) to start machine..."
  flyctl machine start $MACHINE_ID 2>&1 | tee "$START_OUTPUT_FILE"
  # Check if machine is started
  STATE=$(flyctl machine list --json | jq -r '.[0].state')
  echo "Current machine state: $STATE"
  if [ "$STATE" = "started" ]; then
    echo "Machine started successfully."
    break
  fi
  RETRY_COUNT=$(($RETRY_COUNT+1))
  if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
    echo "Machine not started yet. Waiting 5 seconds before retrying..."
    sleep 5
  fi

done

# Check if the machine successfully started after our max number of retries
if [ "$STATE" != "started" ]; then
  echo "Failed to start machine after $MAX_RETRIES attempts."
  cat "$START_OUTPUT_FILE"
  exit 1
fi

# SSH into the machine to create a 7z archive in /tmp
flyctl ssh console -C "7zz a /tmp/profiles.7z /opt/server/user/profiles/"

# Download the 7z file to the specified output file
# Use a temporary file and then move/rename it
TMP_DOWNLOAD="$TMPDIR/profiles.7z"
echo "get /tmp/profiles.7z $TMP_DOWNLOAD" | flyctl sftp shell
mv "$TMP_DOWNLOAD" "$OUTPUT_FILE"
echo "Backup downloaded to $OUTPUT_FILE"

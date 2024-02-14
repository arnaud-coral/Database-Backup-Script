#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 -d <database_name> -a <age_in_days>"
  exit 1
}

# Initialize variables with default values
DB_NAME=""
AGE_IN_DAYS=""

# Parse command line options
while getopts ":d:a:" opt; do
  case $opt in
    d) DB_NAME="$OPTARG" ;;    # Set the database name
    a) AGE_IN_DAYS="$OPTARG" ;;  # Set the age in days
    \?) echo "Invalid option: -$OPTARG" ; usage ;;
  esac
done

# Check if required options are provided
if [ -z "$DB_NAME" ] || [ -z "$AGE_IN_DAYS" ]; then
  echo "Error: Missing required options"
  usage
fi

# Validate that AGE_IN_DAYS is an integer
if ! [[ "$AGE_IN_DAYS" =~ ^-?[0-9]+$ ]]; then
  echo "Error: Age in days must be an integer"
  usage
fi

# Define the backup directory
BACKUP_DIR="$DB_NAME"

# Check if the backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
  echo "Error: Backup directory '$BACKUP_DIR' not found."
  exit 1
fi

# Calculate the cutoff date based on the age in days
CUTOFF_DATE=$(date -d "$AGE_IN_DAYS days ago" +"%Y-%m-%d %H:%M:%S")

# Delete backup folders older than the specified age
# Exclude the base directory from the list of folders to prevent its deletion
find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d | while read folder; do
  if [ -d "$folder" ]; then # Ensure the folder exists
    folder_date=$(stat -c %Y "$folder" 2>/dev/null) # Suppress error output
    cutoff_epoch=$(date -d "$CUTOFF_DATE" +"%s")
    if [ -n "$folder_date" ] && [ "$folder_date" -lt "$cutoff_epoch" ]; then
      echo "Deleting backup folder: $folder"
      rm -r "$folder"
    fi
  fi
done

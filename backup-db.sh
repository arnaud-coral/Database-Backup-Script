#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 -h <db_host> -P <db_port> -d <database_name> -u <db_username> -p <db_password>"
  exit 1
}

# Initialize variables with default values
DB_HOST="localhost"
DB_PORT="3306"

# Parse command line options
while getopts ":h:P:d:u:p:" opt; do
  case $opt in
    h) DB_HOST="$OPTARG" ;;  # Set the database host
    P) DB_PORT="$OPTARG" ;;  # Set the database port
    d) DB_NAME="$OPTARG" ;;  # Set the database name
    u) DB_USER="$OPTARG" ;;  # Set the database username
    p) DB_PASS="$OPTARG" ;;  # Set the database password
    \?) echo "Invalid option: -$OPTARG" ; usage ;;
  esac
done

# Check if required options are provided
if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ]; then
  echo "Error: Missing required options"
  usage
fi

# Date format for the backup folder (e.g., YYYY-MM-DD-HH-MM-SS)
DATE=$(date +"%Y-%m-%d-%H-%M-%S")

# Backup directory with the same name as the database and the date
BACKUP_DIR="$DB_NAME/$DATE"

# Create the backup directory
mkdir -p "$BACKUP_DIR"

# Log file for recording script activity and errors
LOG_FILE="$BACKUP_DIR/backup.log"

# Redirect both stdout and stderr to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Log the start of the backup process
echo "Starting database backup for $DB_NAME at $(date)"

# Get a list of tables in the database
TABLES=$(mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -N -B -e "use $DB_NAME; show tables;")

# Loop through the tables and create individual backup files with data
for TABLE in $TABLES; do
  mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" --complete-insert "$DB_NAME" "$TABLE" > "$BACKUP_DIR/$TABLE.sql"

  # Check if the table backup was successful
  if [ $? -eq 0 ]; then
    # Log the table backup
    echo "Backed up table $TABLE with data to $BACKUP_DIR/$TABLE.sql"
  else
    # Log the error if the table backup failed
    echo "Error: Backup of table $TABLE with data failed"
  fi
done

# Backup views in a separate file
mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" --no-data --routines --events --no-create-info --skip-triggers > "$BACKUP_DIR/$DB_NAME-views.sql"

# Backup stored procedures in a separate file
mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" --no-data --routines --events --no-create-info --skip-triggers > "$BACKUP_DIR/$DB_NAME-stored-procedures.sql"

# Backup events in a separate file
mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" --no-data --routines --events --no-create-info --skip-triggers --no-create-db > "$BACKUP_DIR/$DB_NAME-events.sql"

# Check if the backup was successful
if [ $? -eq 0 ]; then
  # Log the successful backup
  echo "Backup of database $DB_NAME completed successfully and saved to $BACKUP_DIR"
else
  # Log the error if the backup failed
  echo "Error: Backup of database $DB_NAME failed"
fi

# Log the end of the backup process
echo "Backup process completed at $(date)"

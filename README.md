# 🚀 Database Backup Script

This is a simple Bash script for creating backups of your MySQL database. It allows you to specify the database host, port, name, username, and password as command line options. The script will create a backup of your database, including individual SQL files for tables, views, stored procedures, and events. It also records the backup process in a log file.

## 🛠️ Usage

### 💾 Backup script

```shell
Usage: ./backup-db.sh -d <db_name> [-P <db_port>] [-h <db_host>] [-u <db_username>] [-p <db_password>]
```
- -h: Database host (default is "localhost")
- -P: Database port (default is "3306")
- -d: Database name (required)
- -u: Database username (required)
- -p: Database password (required)

**Note:** If the script is provided with the `-h` option and no `-u` nor `-p` options it will load credentials from a config file named db_name.config. The config file should have the same name as the provided database name.

### 🗑️ Cleanup script

```shell
Usage: ./cleanup-backup.sh -d <db_name> -a <age_in_days>
```
- d: Database name (required)
- a: Age in days (required)

## 🔎 Features
- 📅 Automatic date-based folder for backups.
- 📂 Individual SQL files for each table.
- 👀 Backup of views, stored procedures, and events.
- 📝 Detailed logs of the backup process.
- 🗑️ Cleanup of old backup folders.

## 🧰 Prerequisites
- Make sure you have MySQL client tools installed.

## 🚴 Usage

### 💾 Backup script

1. Make the script executable:
```shell
chmod +x backup-db.sh
```
2. Run the script with the required options:
```shell
./backup-db.sh -d my_database -u my_user -p my_password
```
3. The script will create a backup folder with timestamp, e.g., `my_database/2023-11-02-10-30-45`.
4. Inside the folder, you will find SQL files for tables, views, stored procedures, and events.
5. The script logs its activity and errors to a file named `backup.log` within the backup folder.
6. Your database backup is now complete! 🎉

### 🗑️ Cleanup script

1. Make the script executable:
```shell
chmod +x cleanup-backup.sh
```
2. Run the cleanup script with the required options:
```shell
./cleanup-backup.sh -d my_database -a 15
```
3. The script will delete subfolders in the directory `./my_database` that are older than 15 days.
4. The cleanup process is logged to the console.
5. Cleanup is complete! 🗑️

## 📜 License

This script is © 2023 by Arnaud Coral. It's licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/). Please refer to the license for permissions and restrictions.
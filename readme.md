This Bash script provides functionality for backing up and restoring files using encryption. It allows you to create encrypted backups of specified directories and restore them when needed and secure copy it to a remote server


##Usage

To use the script, follow the instructions below.

>Backup

To perform a backup, execute the script with the following parameters:


./backup.sh  <source_directory> <backup_directory> <encryption_key> <days>


<source_directory>: The directory that you want to back up.
<backup_directory>: The directory where the backups will be stored.
<encryption_key>: The encryption key used to encrypt the backups.
<days>: The number of days within which files should be considered for backup.


>>Example:

./backup.sh  /path/to/source /path/to/backup mypass123 7


This will create a backup of the files in /path/to/source directory and store them in /path/to/backup directory. The backups will be encrypted using the provided encryption key (mypass123) and only files modified within the last 7 days will be includedin the backup.



>Restore

To restore files from a backup, execute the script with the following parameters:

./restore.sh  <backup_directory> <restore_directory> <decryption_key>



<backup_directory>: The directory where the backups are stored.
<restore_directory>: The directory where the restored files will be placed.
<decryption_key>: The decryption key used to decrypt the backups.


>>Example:

./restore.sh  /path/to/backup /path/to/restore mypass123


This will restore the files from the backups located in /path/to/backup directory and place them in /path/to/restore directory. The backups will be decrypted using the provided decryption key (mypass123).


##Notes

1...The script uses the tar command to create compressed archives of directories and files.

2...The backups are encrypted using the gpg command, which requires the gpg tool to be installed on the system.

3...The encrypted backups are saved with the .gpg extension.

4...The script uses the scp command to copy the encrypted backups to a remote server.

5... Make sure you have the necessary permissions and correct network configuration for successful copying.

6...The script assumes a Unix-like environment with Bash shell support.


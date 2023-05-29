#!/bin/bash

# Backup and Restore Library

# Validate backup parameters
validate_backup_params() {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <source_directory> <backup_directory> <encryption_key> <days>"
        exit 1
    fi

    if [ $# -ne 4 ]; then
        echo "Error: Incorrect number of parameters provided."
        echo "Usage: $0 <source_directory> <backup_directory> <encryption_key> <days>"
        exit 1
    fi

    source_directory="$1"
    backup_directory="$2"
    gpg_key="$3"
    days="$4"

    if [ ! -d "$source_directory" ]; then
        echo "Error: Source directory '$source_directory' does not exist."
        exit 1
    fi

    if [ ! -d "$backup_directory" ]; then
        echo "Error: Backup directory '$backup_directory' does not exist."
        exit 1
    fi
}

# Backup function
backup() {
    source_directory="$1"
    backup_directory="$2"
    gpg_key="$3"
    days="$4"

    # Get the current date
    date=$(date +%Y-%m-%d)

    # Replace any white space or colon with an underscore
    date=${date//[ :]/_}


    new_backup_directory="$backup_directory/$date"
    mkdir "$new_backup_directory"

    # Loop over all directories in the source directory
    for directory in "$source_directory"/*; do

       # Check if the directory is a directory
       if [ -d "$directory" ]; then

       # Get the modification date of the directory
           modification_date=$(stat -c %y "$directory")

       # Check if the directory was modified within the specified number of days
            if [[ $(date -d "$modification_date" +%s) -ge $(date -d "$date - $days days" +%s) ]]; then
       
            directory_name=$(basename "$directory")
       # Create a tar.gz file of the directory
            tar -czf "$new_backup_directory/$directory_name.tgz" "$directory"

       # Encrypt the tar.gz file
            gpg --batch --yes --passphrase="$gpg_key" -c "$new_backup_directory/$directory_name.tgz"

       # Delete the original tar.gz file
           rm "$new_backup_directory/$directory_name.tgz"
            fi
        fi
    done
 
    tar -cf "$new_backup_directory/files" --files-from /dev/null

    for file in "$source_directory"/*; do
    
       # Check if the directory is a directory
       if [ -f "$file" ]; then

       # Get the modification date of the directory
           modification_date=$(stat -c %y "$directory")

       # Check if the directory was modified within the specified number of days
            if [[ $(date -d "$modification_date" +%s) -ge $(date -d "$date - $days days" +%s) ]]; then
       
            file_name=$(basename "$file")
       # Create a tar.gz file of the directory
            tar -czf "$new_backup_directory/$file_name.tgz" "$file"
            tar -uf  "$new_backup_directory/files" "$file"
       # Encrypt the tar.gz file
            gpg --batch --yes --passphrase="$gpg_key" -c "$new_backup_directory/$file_name.tgz"
            
       # Delete the original tar.gz file
           rm "$new_backup_directory/$file_name.tgz"
            fi 
        fi
             
      done
      
    # Compress the tar archive using gzip
      gzip "$new_backup_directory/files"

    #Encrypt the tar.gz file using gnupg 
      gpg --batch --passphrase --passphrase="$gpg_key"  -c  "$new_backup_directory/files.gz"

    # Delete the tar.gz file    
      rm  "$new_backup_directory/files.gz"
      

    scp "$new_backup_directory"/*.gpg    username@remote_server:/path
    #ex:
    #scp "$new_backup_directory"/*.gpg     esraa@192.168.132.135:/home/esraa/remote_backup                                    

    if [[ $? -ne 0 ]];
    then
       echo "Copy to remote server failed. Exiting."
       exit 1
    fi

    echo "Backup copied to remote server successfully."

    echo "Script execution complete."

}

# Validate restore parameters
validate_restore_params() {

    if [ $# -eq 0 ]; then
      echo "Usage: $0 <source_directory> <backup_directory> <encryption_key> <days>"
      exit 1
    fi

    if [ $# -ne 3 ]; then
        echo "Error: Incorrect number of parameters provided."
        echo "Usage: $0 <backup_directory> <restore_directory> <decryption_key>"
        exit 1
    fi

    backup_directory="$1"
    restore_directory="$2"
    decryption_key="$3"

    if [ ! -d "$backup_directory" ]; then
        echo "Error: Backup directory '$backup_directory' does not exist."
        exit 1
    fi

    if [ ! -d "$restore_directory" ]; then
        echo "Error: Restore directory '$restore_directory' does not exist."
        exit 1
    fi
}

# Restore function
restore() {
    backup_directory="$1"
    restore_directory="$2"
    decryption_key="$3"

    temp_directory="$restore_directory/temp"
    mkdir "$temp_directory"

    for file in "$backup_directory"/*.gpg; do
        gpg --batch --yes --passphrase="$decryption_key" -o "$temp_directory/$(basename "$file")" -d "$file"
    done

    for file in "$temp_directory"/*; do
        tar -xz -C "$restore_directory" -f "$file"
    done

    rm -rf "$temp_directory"
}

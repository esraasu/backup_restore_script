#!/bin/bash

# Backup Script

# Source the backup_restore_lib.sh library
source backup_restore_lib.sh

# Validate backup parameters
validate_backup_params "$@"

# Backup using the backup function from the library
backup "$@"

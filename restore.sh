#!/bin/bash

# Restore Script

# Source the backup_restore_lib.sh library
source backup_restore_lib.sh

# Validate restore parameters
validate_restore_params "$@"

# Restore using the restore function from the library
restore "$@"

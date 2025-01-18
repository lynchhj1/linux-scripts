#!/bin/bash

# Configuration file
CONFIG_FILE="config2.env"
EXCLUDE_FILE=".rsync-exclude"

# Load configuration from file if it exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Config file $CONFIG_FILE not found!"
    exit 1
fi

# Script version
VERSION="1.0.0"

# Help function
show_help() {
    cat << EOF
Media Sync Script v${VERSION}
Usage: $(basename "$0") [OPTIONS]

Options:
    -n          Dry run mode - no files will be transferred
    -h          Show this help message
    -c FILE     Use specific config file (default: config.env)

This script synchronizes media files between servers using rsync.
EOF
    exit 0
}

# Parse command line arguments
DRY_RUN=false
while getopts "nhc:" opt; do
    case $opt in
        n)
            DRY_RUN=true
            echo "*** DRY RUN MODE - No files will be transferred ***"
            ;;
        h)
            show_help
            ;;
        c)
            CONFIG_FILE="$OPTARG"
            if [ -f "$CONFIG_FILE" ]; then
                source "$CONFIG_FILE"
            else
                echo "Error: Config file $CONFIG_FILE not found!"
                exit 1
            fi
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help
            ;;
    esac
done

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to rsync entire directories (for TV and Cartoons)
rsync_directory() {
    local dir_name="$1"
    log "Syncing entire $dir_name directory"
    
    # Build rsync command based on dry run flag
    local cmd="rsync -av --no-g --recursive --ignore-existing --info=progress2 --exclude-from=$EXCLUDE_FILE"
    if [ "$DRY_RUN" = true ]; then
        cmd="$cmd --dry-run"
    fi
    
    $cmd "$SOURCE_BASE/$dir_name/" "$TARGET_BASE/$dir_name/"
}

# Main execution
log "Starting media sync"

# First sync TV
log "=== Syncing TV Shows ==="
rsync_directory "TV"

# Then Cartoons
log "=== Syncing Cartoons ==="
rsync_directory "Cartoons"

# Then Docs
log "=== Syncing Docs ==="
rsync_directory "Docs"

# Then sync Movies
log "=== Syncing Movies ==="
rsync_directory "Movies"

# Then sync Books 
log "=== Syncing Books ==="
rsync_directory "Books"

# Then sync Comics
log "=== Syncing Comics ==="
rsync_directory "Comics"

# Then sync Audio Books 
log "=== Syncing Audio Books ==="
rsync_directory "Audio.Books"

# Then sync config
log "=== Syncing Plex Config ==="
rsync_directory "config"

log "All transfers completed!"


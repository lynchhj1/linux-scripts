#!/bin/bash

# Configuration file
CONFIG_FILE="config.env"

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

# Function to rsync files matching a pattern for movies
rsync_movies_pattern() {
    local pattern="$1"
    local target_dir="$2"
    log "Syncing movie files matching $pattern to Movies/$target_dir"
    
    # Build rsync command based on dry run flag
    local cmd="rsync -av --recursive --ignore-existing --info=progress2"
    if [ "$DRY_RUN" = true ]; then
        cmd="$cmd --dry-run"
    fi
    
    # Quote the source path pattern
    $cmd "$SOURCE_BASE/Movies/"$pattern "$TARGET_USER@$TARGET_IP:$TARGET_BASE/Movies/$target_dir/"
}

# Function to rsync entire directories (for TV and Cartoons)
rsync_directory() {
    local dir_name="$1"
    log "Syncing entire $dir_name directory"
    
    # Build rsync command based on dry run flag
    local cmd="rsync -av --recursive --ignore-existing --info=progress2"
    if [ "$DRY_RUN" = true ]; then
        cmd="$cmd --dry-run"
    fi
    
    $cmd "$SOURCE_BASE/$dir_name/" "$TARGET_USER@$TARGET_IP:$TARGET_BASE/$dir_name/"
}

# Main execution
log "Starting media sync"

# First sync TV and Cartoons (entire directories)
log "=== Syncing TV Shows ==="
rsync_directory "TV"

log "=== Syncing Cartoons ==="
rsync_directory "Cartoons"

# Then sync Movies by alphabetical ranges
log "=== Syncing Movies ==="

# Sync numeric files to A-E directory
log "Syncing numeric files..."
rsync_movies_pattern "[0-9]*" "A-E"

# Sync alphabetic ranges
log "Syncing A-E files..."
rsync_movies_pattern "[A-Ea-e]*" "A-E"

log "Syncing F-J files..."
rsync_movies_pattern "[F-Jf-j]*" "F-J"

log "Syncing K-O files..."
rsync_movies_pattern "[K-Ok-o]*" "K-O"

log "Syncing P-T files..."
rsync_movies_pattern "[P-Tp-t]*" "P-T"

log "Syncing U-Z files..."
rsync_movies_pattern "[U-Zu-z]*" "U-Z"

log "All transfers completed!"
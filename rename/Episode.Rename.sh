#!/bin/bash
# Function to display usage
usage() {
    echo "Usage: $0 [-d directory] [-n] [-h]"
    echo "Options:"
    echo "  -d directory  : Directory to process (default: current directory)"
    echo "  -n           : Dry run (show what would be done without making changes)"
    echo "  -h           : Show this help message"
    exit 1
}

# Set default values
TARGET_DIR="."
DRY_RUN=false

# Parse command line arguments
while getopts "d:nh" opt; do
    case $opt in
        d)
            TARGET_DIR="${OPTARG//\\/ }"  # Replace backslashes with spaces
            ;;
        n)
            DRY_RUN=true
            echo "*** DRY RUN MODE - No files will be renamed ***"
            ;;
        h)
            usage
            ;;
        \?)
            usage
            ;;
    esac
done

# Check if directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    exit 1
fi

# Change to target directory
cd "$TARGET_DIR" || exit 1

# Check if any files match the pattern
shopt -s nullglob

# Define video formats
video_formats="mkv|mp4|avi|m4v|wmv|mov|flv"

# Function to format episode number
format_episode() {
    local name="$1"
    local extension="$2"
    
    # Handle "1x01" format
    if [[ $name =~ ([0-9]+)x([0-9]+)[[:space:]]*-[[:space:]]*(.*)\.(${video_formats})$ ]]; then
        # Convert season/episode to decimal numbers first to avoid octal issues
        season=$((10#${BASH_REMATCH[1]}))
        episode=$((10#${BASH_REMATCH[2]}))
        
        # Now format as two-digit numbers
        season=$(printf "%02d" $season)
        episode=$(printf "%02d" $episode)
        
        # Get show name (everything before the - 1x01)
        show_name=$(echo "$name" | sed -E 's/[[:space:]]*-[[:space:]]*[0-9]+x[0-9]+.*//')
        
        # Convert spaces to dots and remove any duplicate dots
        show_name=$(echo "$show_name" | tr ' ' '.' | sed 's/\.\.*/./g')
        
        new_name="${show_name}.s${season}e${episode}.${extension}"
        echo "$new_name"
        return 0
    fi
    
    # Handle "SxxExx" format
    if [[ $name =~ S[0-9]{2}E[0-9]{2} ]]; then
        # Get the base name up to the season/episode part
        base_name=$(echo "$name" | sed -E 's/\.S[0-9]{2}E[0-9]{2}\..*$//')
        
        # Extract the season and episode numbers while converting S and E to lowercase
        season_ep=$(echo "$name" | grep -o 'S[0-9]\{2\}E[0-9]\{2\}' | tr 'SE' 'se')
        
        new_name="${base_name}.${season_ep}.${extension}"
        echo "$new_name"
        return 0
    fi
    
    return 1
}

# Loop through all video files in target directory
for file in *; do
    # Check if file is a video file
    if [[ $file =~ \.(${video_formats})$ ]]; then
        extension="${file##*.}"
        new_name=$(format_episode "$file" "$extension")
        
        if [ $? -eq 0 ] && [ "$file" != "$new_name" ]; then
            if [ "$DRY_RUN" = true ]; then
                echo "[DRY RUN] Would rename: $file -> $new_name"
            else
                echo "Renaming: $file -> $new_name"
                mv "$file" "$new_name"
            fi
        fi
    fi
done

# Return to original directory
cd - > /dev/null

# Summary
if [ "$DRY_RUN" = true ]; then
    echo "Dry run completed. No files were actually renamed."
else
    echo "Renaming completed."
fi
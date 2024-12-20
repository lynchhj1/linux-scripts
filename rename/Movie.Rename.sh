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

# Function to format movie name
format_movie() {
    local filename="$1"
    local extension="$2"
    
    # Extract title and year
    if [[ $filename =~ ^(.+)\.([12][0-9]{3})\. ]]; then
        title="${BASH_REMATCH[1]}"
        year="${BASH_REMATCH[2]}"
        
        # Clean up title (replace dots with spaces, then back to dots)
        title=$(echo "$title" | tr '.' ' ' | sed 's/  */ /g' | sed 's/ /./g')
        
        new_name="${title}.(${year}).${extension}"
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
        new_name=$(format_movie "$file" "$extension")
        
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

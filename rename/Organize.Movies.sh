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

# Variables
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

# Check if the provided directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

# Process movie files
while IFS= read -r -d '' FILE; do
    # Extract the base filename (without path)
    BASENAME=$(basename "$FILE")
    EXTENSION="${FILE##*.}"
    
    # Match the title and year pattern
    if [[ "$BASENAME" =~ ^(.+)[[:space:]]*\(([0-9]{4})\)\..+$ ]]; then
        MOVIE_TITLE="${BASH_REMATCH[1]}"
        MOVIE_YEAR="${BASH_REMATCH[2]}"
        
        # Clean up the movie title and create folder name
        MOVIE_FOLDER="${MOVIE_TITLE}(${MOVIE_YEAR})"
        MOVIE_FOLDER="${MOVIE_FOLDER%"${MOVIE_FOLDER##*[![:space:]]}"}" # Remove trailing spaces
        
        # Target folder path
        DESTINATION="$TARGET_DIR/$MOVIE_FOLDER"
        
        # Create the folder if it doesn't exist
        if [[ "$DRY_RUN" == "false" ]]; then
            mkdir -p "$DESTINATION"
        else
            echo "[Dry-run] Would create directory: \"$DESTINATION\""
        fi
        
        # Find and move related files
        while IFS= read -r -d '' RELATED_FILE; do
            if [[ "$DRY_RUN" == "false" ]]; then
                mv "$RELATED_FILE" "$DESTINATION/"
                echo "Moved: \"$RELATED_FILE\" -> \"$DESTINATION/\""
            else
                echo "[Dry-run] Would move: \"$RELATED_FILE\" -> \"$DESTINATION/\""
            fi
        done < <(find "$TARGET_DIR" -maxdepth 1 -type f -name "${BASENAME%.*}*" -print0)
    else
        echo "Skipping: \"$BASENAME\" (does not match naming convention)"
    fi
done < <(find "$TARGET_DIR" -maxdepth 1 -type f -print0)

echo "Processing complete!"
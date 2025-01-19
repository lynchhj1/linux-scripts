#!/bin/bash
# Usage: ./organize_movies.sh [directory] [-n]

# Variables
DRY_RUN=false
TARGET_DIR="$1"

# Check if dry-run flag is set
if [[ "$2" == "-n" ]]; then
    DRY_RUN=true
    echo "Dry-run mode enabled. No changes will be made."
fi

# Check if a directory is provided
if [[ -z "$TARGET_DIR" ]]; then
    echo "Usage: $0 [directory] [-n]"
    exit 1
fi

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
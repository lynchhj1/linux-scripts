import os
import re
import argparse
from tmdbv3api import TMDb, Movie
import time
import configparser
from pathlib import Path

def load_config():
    config_path = Path.home() / '.config' / 'config.ini'
    
    if not config_path.exists():
        # Create default config
        config_path.parent.mkdir(parents=True, exist_ok=True)
        config = configparser.ConfigParser()
        config['TMDB'] = {'api_key': ''}
        with open(config_path, 'w') as f:
            config.write(f)
        print(f"Please add your TMDB API key to {config_path}")
        exit(1)
    
    # Try as INI file first
    try:
        config = configparser.ConfigParser()
        config.read(config_path)
        return config['TMDB']['api_key']
    except Exception:
        # If INI format fails, try as plain text
        try:
            with open(config_path, 'r') as f:
                api_key = f.read().strip()
                if api_key:
                    return api_key
                else:
                    print(f"Error: No API key found in {config_path}")
                    exit(1)
        except Exception:
            print(f"Error reading config file. Please ensure {config_path} contains your TMDB API key")
            exit(1)

def setup_tmdb():
    tmdb = TMDb()
    tmdb.api_key = load_config()
    return Movie()

def extract_title(filename):
    # Remove common video extensions and language codes
    name = re.sub(r'\.(mp4|mkv|avi|webm|ts|sub|srt|idx)$', '', filename)
    name = re.sub(r'\.en$', '', name)  # Remove language code
    
    # Extract and preserve edition information if it exists after year
    edition_match = re.search(r'\(\d{4}\)\{([^}]+)\}', name)
    edition = edition_match.group(1) if edition_match else None
    
    # Remove existing year and edition if present
    name = re.sub(r'\(\d{4}\)(\{[^}]+\})?', '', name)
    
    # Clean up the title
    name = name.replace('.', ' ').strip()
    return name, edition

def has_four_digit_year(filename):
    # Check if filename contains a 4-digit number that's not in parentheses
    # Ignore years that are part of movie titles like "2001.A.Space.Odyssey"
    year_matches = re.finditer(r'(?<!\()\d{4}(?!\))', filename)
    for match in year_matches:
        # Check if the year is part of a CD designation (cd1, cd2, etc.)
        if re.search(r'cd\d+', filename.lower()):
            return False
        # Check if it's surrounded by dots (likely part of the title)
        surrounding_text = filename[max(0, match.start()-1):min(len(filename), match.end()+1)]
        if not '.' in surrounding_text:
            return True
    return False

def get_movie_year(movie_api, title):
    try:
        search = movie_api.search(title)
        if search:
            return search[0].release_date[:4]
    except Exception as e:
        print(f"Error searching for {title}: {e}")
    return None

def get_user_approval(old_name, new_name):
    while True:
        response = input(f"\nRename:\n  From: {old_name}\n  To: {new_name}\nApprove? (y/n/q) or enter year: ").lower()
        if response == 'q':
            return 'q', None
        elif response == 'n':
            return 'n', None
        elif response == 'y':
            return 'y', None
        elif response.isdigit() and len(response) == 4:
            return 'y', response
        else:
            print("Please enter 'y' for yes, 'n' for no, 'q' to quit, or a 4-digit year")

def is_multi_cd(filename):
    return bool(re.search(r'cd\d+', filename.lower()))

def rename_movies(directory, interactive=False):
    movie_api = setup_tmdb()
    
    # Get all files
    files = [f for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f))]
    
    # Group files by their base name (without extension)
    file_groups = {}
    for filename in files:
        # Check if file ends with any of our target extensions
        if not any(filename.endswith(ext) for ext in ['.mp4', '.mkv', '.avi', '.webm', '.ts', '.sub', 'en.srt', 'en.idx', '.en.srt']):
            continue
            
        # Skip files that have 4-digit years not in parentheses
        if has_four_digit_year(filename):
            print(f"Skipping file with 4-digit year: {filename}")
            continue
            
        # Skip multi-CD files
        if is_multi_cd(filename):
            print(f"Skipping multi-CD file: {filename}")
            continue
        
        # Get base name (everything before the extension)
        base, ext = os.path.splitext(filename)
        if ext == '.srt' and base.endswith('.en'):
            base = base[:-3]  # Remove '.en' for subtitle files
        
        if base not in file_groups:
            file_groups[base] = []
        file_groups[base].append(filename)
    
    # Process each group of related files
    for base, files in file_groups.items():
        # Skip if any file in the group already has a year in parentheses
        if any(re.search(r'\(\d{4}\)', f) for f in files):
            continue
        
        # Get the year using the base name
        title, edition = extract_title(base)
        year = get_movie_year(movie_api, title)
        
        if not year:
            print(f"Could not find year for base name: {base}")
            continue
        
        # Rename all related files
        for filename in files:
            try:
                # Add edition back if it existed
                edition_str = f"{{{edition}}}" if edition else ""
                
                # Get the original extension(s)
                if filename.endswith('.en.srt'):
                    new_filename = f"{base}.({year}){edition_str}.en.srt"
                else:
                    original_ext = os.path.splitext(filename)[1]
                    new_filename = f"{base}.({year}){edition_str}{original_ext}"
                
                old_path = os.path.join(directory, filename)
                new_path = os.path.join(directory, new_filename)
                
                if os.path.exists(new_path):
                    print(f"Warning: {new_filename} already exists, skipping...")
                    continue
                
                if interactive:
                    response, manual_year = get_user_approval(filename, new_filename)
                    if response == 'q':
                        print("Quitting...")
                        return
                    elif response == 'n':
                        print("Skipping...")
                        continue
                    # If a manual year was provided, update the filename
                    if manual_year:
                        new_filename = new_filename.replace(f"({year})", f"({manual_year})")
                        new_path = os.path.join(directory, new_filename)
                
                print(f"Renaming: {filename} -> {new_filename}")
                os.rename(old_path, new_path)
                
            except Exception as e:
                print(f"Error renaming {filename}: {e}")
        
        # Sleep briefly to avoid hitting API rate limits
        time.sleep(0.25)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Rename movie files to include their release year.')
    parser.add_argument('directory', nargs='?', default="/data/plex/Movies",
                      help='Directory containing movie files (default: /data/plex/Movies)')
    parser.add_argument('-i', '--interactive', action='store_true',
                      help='Enable interactive mode to approve each rename')
    
    args = parser.parse_args()
    rename_movies(args.directory, args.interactive)

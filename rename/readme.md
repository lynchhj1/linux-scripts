# Media File Renaming Scripts

A collection of scripts to help standardize the naming of your media files. These scripts handle TV episodes and movies separately, ensuring consistent naming patterns across your media library.

## Scripts

### Episode.Rename.sh

Standardizes TV episode filenames into a consistent format. The script handles common patterns like `ShowName - 1x01` or files containing `SxxExx` and converts them to a standardized format:

```
ShowName.s01e01.extension
```

#### Supported Input Formats:
- `Show Name - 1x01`: Gets converted to `Show.Name.s01e01`
- Files containing `SxxExx`: Gets converted to lowercase `sxxexx`

### Movie.Rename.sh

Standardizes movie filenames to include the title and year in a consistent format:

```
Movie.Title.(2024).extension
```

The script expects movies to have the year in the filename and will reformat them to the standard pattern.

### Organize.Movies.sh

Organizes movie files into individual folders based on their names. The script creates a folder for each movie using its name and year, then moves the movie file and any related files (like subtitles) into that folder.

#### Features:
- Creates folders in the format: `Movie Title (2024)`
- Moves all related files with the same base name
- Support for dry run mode to preview changes
- Handles spaces and special characters in filenames
- Non-recursive (only processes files in the specified directory)

#### Usage:
```bash
# Basic usage
./Organize.Movies.sh /path/to/movies

# Dry run to preview changes
./Organize.Movies.sh /path/to/movies -n
```

#### Example:
Before:
```
/movies/
  The.Matrix.(1999).mkv
  The.Matrix.(1999).srt
  Inception.(2010).mp4
```

After:
```
/movies/
  The Matrix (1999)/
    The.Matrix.(1999).mkv
    The.Matrix.(1999).srt
  Inception (2010)/
    Inception.(2010).mp4
```

### Movie.Year.py

A Python script that automatically adds release years to movie filenames by querying The Movie Database (TMDB) API. It handles multiple file formats and their associated subtitle files:

```
Movie.Title.(2024).extension
```

#### Features:
- Automatic year lookup using TMDB API
- Handles multiple video formats (mp4, mkv, avi, webm, ts)
- Processes associated subtitle files (srt, sub, idx)
- Preserves special edition information in curly braces
- Interactive mode for approval of changes
- Configurable API key through config file
- Groups related files (video + subtitles) for consistent renaming
- Skips files that already have years or are multi-CD

#### Requirements:
- Python 3
- tmdbv3api library
- TMDB API key

#### Configuration:
Create a config file at `~/.config/config.ini` with your TMDB API key:
```ini
[TMDB]
api_key = your_api_key_here
```

#### Usage:
```bash
# Basic usage (default directory: /data/plex/Movies)
python Movie.Year.py

# Specify custom directory
python Movie.Year.py /path/to/movies

# Interactive mode
python Movie.Year.py -i

# Both custom directory and interactive mode
python Movie.Year.py -i /path/to/movies
```

## Features

All scripts include:
- Dry run mode to preview changes (bash scripts)
- Support for multiple video formats (mkv, mp4, avi, m4v, wmv, mov, flv)
- Directory specification option
- Help documentation
- Safe filename handling

## Usage

### General Options

The bash scripts support the following command-line options:

```bash
Usage: ./script.sh [-d directory] [-n] [-h]
Options:
  -d directory  : Directory to process (default: current directory)
  -n           : Dry run (show what would be done without making changes)
  -h           : Show this help message
```

### Examples

#### TV Episodes

```bash
# Rename episodes in current directory
./Episode.Rename.sh

# Dry run in specific directory
./Episode.Rename.sh -n -d "/path/to/tv/shows"
```

Before:
```
Show Name - 1x01 - Episode Title.mkv
Another.Show.S01E02.mkv
```

After:
```
Show.Name.s01e01.mkv
Another.Show.s01e02.mkv
```

#### Movies

```bash
# Rename movies in current directory
./Movie.Rename.sh

# Dry run in specific directory
./Movie.Rename.sh -n -d "/path/to/movies"
```

Before:
```
Movie Title 1080p.mkv
Another Movie HDRip.mp4
```

After (using Movie.Year.py):
```
Movie.Title.(2024).mkv
Another.Movie.(2023).mp4
```

## Installation

1. Download the scripts to your desired location
2. Make the bash scripts executable:
```bash
chmod +x Episode.Rename.sh Movie.Rename.sh Organize.Movies.sh
```
3. Install Python dependencies for Movie.Year.py:
```bash
pip install tmdbv3api
```
4. Configure your TMDB API key as described above

## Safety Features

- Dry run mode (`-n`) to preview changes (bash scripts)
- Interactive mode (-i) for approval of changes (Movie.Year.py)
- No recursive processing (only processes files in the specified directory)
- Original filenames are displayed during renaming
- Error handling for non-existent directories
- Handles spaces and special characters in filenames

## Requirements

- Bash shell (for bash scripts)
- Basic Unix utilities (sed, tr)
- Python 3 (for Movie.Year.py)
- Write permissions in the target directory
- TMDB API key (for Movie.Year.py)
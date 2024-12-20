# Media File Renaming Scripts

A collection of Bash scripts to help standardize the naming of your media files. These scripts handle TV episodes and movies separately, ensuring consistent naming patterns across your media library.

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

## Features

Both scripts include:
- Dry run mode to preview changes
- Support for multiple video formats (mkv, mp4, avi, m4v, wmv, mov, flv)
- Directory specification option
- Help documentation
- Safe filename handling

## Usage

### General Options

Both scripts support the following command-line options:

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
Movie.Title.2024.1080p.mkv
Another.Movie.2023.HDRip.mp4
```

After:
```
Movie.Title.(2024).mkv
Another.Movie.(2023).mp4
```

## Installation

1. Download both scripts to your desired location
2. Make them executable:
```bash
chmod +x Episode.Rename.sh Movie.Rename.sh
```

## Safety Features

- Dry run mode (`-n`) to preview changes before making them
- No recursive processing (only processes files in the specified directory)
- Original filenames are displayed during renaming
- Error handling for non-existent directories
- Handles spaces and special characters in filenames

## Requirements

- Bash shell
- Basic Unix utilities (sed, tr)
- Write permissions in the target directory
# Media Sync Script

This script synchronizes media files between servers using rsync. It handles TV shows, cartoons, and movies (sorted alphabetically).

## Requirements

- rsync
- bash
- SSH access to target server (configured SSH keys recommended)

## Installation

1. Clone this repository
2. Copy `config.env.example` to `config.env`
3. Edit `config.env` with your specific settings
4. Make the script executable: `chmod +x media-sync.sh`

## Usage

Basic usage:
```bash
./rsync.sh
```

Options:
- `-n`: Dry run mode (no files transferred)
- `-h`: Show help message
- `-c FILE`: Use specific config file

## Configuration

Edit `config.env` to set:
- `SOURCE_BASE`: Source directory containing media
- `TARGET_USER`: Username on target server
- `TARGET_IP`: IP address of target server
- `TARGET_BASE`: Base directory on target server

## Directory Structure

The script expects the following directory structure:
```
TARGET_BASE/
├── TV/
├── Cartoons/
└── Movies/
    ├── A-E/
    ├── F-J/
    ├── K-O/
    ├── P-T/
    └── U-Z/
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request
# Docker Services Setup

This repository contains Docker Compose configurations for running Plex Media Server and Watchtower services.

## Services

### Plex Media Server
Media server for streaming your digital media library across devices.

### Watchtower
Automatic Docker container updater that checks for updated images and refreshes your containers.

## Prerequisites

- Docker installed
- Docker Compose installed
- Sufficient disk space for media storage
- A [Plex claim token](https://plex.tv/claim) (for first-time Plex setup only)

## Configuration

### 1. Plex Configuration
Copy the example environment file:
```bash
cp .env.example .env
```

Edit `.env` with your settings:
```env
PUID=1000
PGID=1000
PLEX_VERSION=latest
PLEX_CLAIM=claim-xxxxxxxxxxxxx  # Only needed for first setup

# Path configurations
PLEX_CONFIG=/data/plex/config
PLEX_TV=/data/plex/TV
PLEX_CARTOONS=/data/plex/Cartoons
PLEX_MOVIES=/data/plex/Movies
PLEX_PRON=/data/plex/Pron
PLEX_PRON_SCENES=/data/plex/Pron.Scenes
PLEX_DOCS=/data/plex/Docs
PLEX_PICS=/data/plex/Pics
TRANSCODE_PATH=/dev/shm
```

### 2. Watchtower Configuration
No additional configuration needed. By default, it's set to update the Plex container at 2 AM daily.

## Usage

### Starting Services

Start Plex:
```bash
docker-compose -f plex-compose.yml up -d
```

Start Watchtower:
```bash
docker-compose -f watchtower-compose.yml up -d
```

Start both services:
```bash
docker-compose -f plex-compose.yml -f watchtower-compose.yml up -d
```

### Stopping Services

Stop Plex:
```bash
docker-compose -f plex-compose.yml down
```

Stop Watchtower:
```bash
docker-compose -f watchtower-compose.yml down
```

Stop both services:
```bash
docker-compose -f plex-compose.yml -f watchtower-compose.yml down
```

### Checking Service Status
```bash
# View all services status
docker-compose -f plex-compose.yml -f watchtower-compose.yml ps

# View status of specific service
docker-compose -f plex-compose.yml ps  # for Plex
docker-compose -f watchtower-compose.yml ps  # for Watchtower

# View logs for Plex
docker-compose -f plex-compose.yml logs plex

# View logs for Watchtower
docker-compose -f watchtower-compose.yml logs watchtower
```

## Directory Structure
```
.
├── README.md
├── .env                    # Environment variables (git ignored)
├── .env.example           # Example environment file
├── plex-compose.yml       # Plex Docker Compose configuration
└── watchtower-compose.yml # Watchtower Docker Compose configuration
```

## Maintenance

### Update Containers
Watchtower will automatically update the Plex container daily at 2 AM. To manually update:
```bash
# Update specific service
docker-compose -f plex-compose.yml pull
docker-compose -f plex-compose.yml up -d

# Update all services
docker-compose -f plex-compose.yml -f watchtower-compose.yml pull
docker-compose -f plex-compose.yml -f watchtower-compose.yml up -d
```

### View Logs
```bash
# Follow Plex logs
docker-compose -f plex-compose.yml logs -f plex

# Follow Watchtower logs
docker-compose -f watchtower-compose.yml logs -f watchtower
```

### Backup
Before making any changes, backup your Plex configuration:
```bash
sudo cp -r /data/plex/config /data/plex/config.backup
```

## Troubleshooting

1. **Container Won't Start**
   - Check logs: `docker-compose -f [compose-file] logs`
   - Ensure no port conflicts: `docker ps`
   - Verify permissions on mounted volumes

2. **Plex Not Accessible**
   - Verify network mode is host
   - Check Plex server settings
   - Ensure firewall allows Plex ports (32400)

3. **Media Not Showing**
   - Verify volume mount paths
   - Check file permissions
   - Scan library in Plex

4. **Watchtower Not Updating**
   - Check Watchtower logs
   - Verify docker.sock mount
   - Confirm cron schedule setting
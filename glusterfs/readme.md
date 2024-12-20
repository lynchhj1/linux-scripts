# GlusterFS Setup and Management Guide

This guide provides instructions for setting up and managing a GlusterFS distributed filesystem with replica configuration.

## Prerequisites

Install required packages:

```bash
sudo apt install gdisk xfsprogs glusterfs-server
```

## Network Configuration

### Host Configuration

Add the following entries to `/etc/hosts`:

```bash
10.0.1.1 gfs01
10.0.1.2 gfs02
10.0.1.3 gfs03
10.0.1.4 gfs04
```

## Storage Setup

### Disk Partitioning

1. Create new partition using gdisk:
```bash
sudo gdisk /dev/sda
```

2. Follow these steps in gdisk:
   - Enter `n` for new partition
   - Press Enter to accept defaults
   - Enter `w` to write changes

3. Verify partition alignment:
```bash
sudo fdisk -l /dev/sda
```

4. Format the partition with XFS:
```bash
sudo mkfs.xfs -f /dev/sda1
```

### Mount Configuration

1. Create the brick directory:
```bash
sudo mkdir -p /gfs/brick1
```

2. Add to `/etc/fstab`:
```bash
/dev/sda1 /gfs/brick1 xfs defaults 0 1
```

3. Mount all filesystems:
```bash
sudo mount -a
```

4. Verify mounts:
```bash
df -h
```

## GlusterFS Configuration

### Volume Creation

Create and start replicated volume:

```bash
sudo gluster volume create gvol0 replica 2 \
    gfs01:/gfs/brick1/gvol0 \
    gfs02:/gfs/brick1/gvol0 \
    gfs03:/gfs/brick1/gvol0 \
    gfs04:/gfs/brick1/gvol0

sudo gluster volume start gvol0
```

Check volume information:
```bash
sudo gluster volume info gvol0
```

### Client Configuration

Add to client's `/etc/fstab` (replace gfsXX with appropriate hostname):
```bash
gfsXX:/gvol0 /mnt/gfs glusterfs defaults,_netdev 0 0
```

### NFS Access

Mount via NFS v3:
```bash
mkdir /mnt/nfs/
sudo mount -t nfs -o vers=3,mountproto=tcp gfs01:/gvol0 /mnt/nfs
# Alternative method
sudo mount -t nfs -o nfsvers=3 10.0.1.1:/gvol0 /mnt/gfs
```

## Management Scripts

### Start Script (gluster.sh)

This script handles the startup sequence for GlusterFS:

```bash
#!/bin/bash

# Start rpcbind service
if ! service rpcbind start; then
    echo "Failed to start rpcbind service"
    exit 1
fi

# Start gluster volume
if ! gluster volume start gvol0; then
    echo "Failed to start gluster volume gvol0"
    exit 1
fi

# Check volume status
if ! gluster volume status gvol0; then
    echo "Failed to get gluster volume status"
    exit 1
fi

# Mount all entries from fstab
if ! mount -a; then
    echo "Failed to mount all entries"
    exit 1
fi
```

Make executable and run:
```bash
chmod +x gluster.sh
sudo ./gluster.sh
```

### Stop Script (stop-gluster.sh)

This script safely stops the GlusterFS volume:

```bash
#!/bin/bash

# Unmount all Gluster filesystems first to prevent busy volume errors
if grep -q gvol0 /proc/mounts; then
    echo "Unmounting Gluster filesystems..."
    umount -a -t glusterfs
fi

# Stop the Gluster volume
echo "Stopping Gluster volume gvol0..."
if ! gluster volume stop gvol0 force; then
    echo "Failed to stop gluster volume gvol0"
    exit 1
fi

echo "Gluster volume stopped successfully"
```

Make executable and run:
```bash
chmod +x stop-gluster.sh
sudo ./stop-gluster.sh
```

## Troubleshooting

Follow these steps to diagnose common issues:

1. Check GlusterFS service status:
```bash
systemctl status glusterd
```

2. Verify volume listing and status:
```bash
gluster volume list
gluster volume status
```

3. Check mount points:
```bash
df -h
mount | grep gluster
```

4. Review brick directory permissions:
```bash
ls -la /path/to/brick
```

5. Check logs:
```bash
tail -f /var/log/glusterfs/*
journalctl -u glusterd
```

6. Verify peer status:
```bash
gluster peer status
```

7. Check version compatibility:
```bash
glusterfs --version
```

If the GlusterFS daemon isn't running:
```bash
sudo systemctl start glusterd
sudo systemctl enable glusterd  # Enable on boot
sudo systemctl status glusterd
```

For detailed daemon logs:
```bash
journalctl -u glusterd --since today
```

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

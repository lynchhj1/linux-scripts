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

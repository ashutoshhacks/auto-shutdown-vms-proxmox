#!/bin/bash

echo "Starting VM shutdown process..."
for vmid in $(qm list | awk 'NR>1 {print $1}'); do
    echo "Shutting down VM ID $vmid..."
    qm shutdown $vmid
    sleep 5
done

echo "Waiting for all vms to shut down..."
timeout=30
elapsed=0
while qm list | grep -q running; do
    sleep 5
    elapsed=$((elapsed + 5))
    if [ $elapsed -ge $timeout ]; then
        echo "Some VMs did not shut down gracefully. Forcing shutdown..."
        break
    fi
done

for vmid in $(qm list | awk 'NR>1 && $3=="running" {print $1}'); do
    echo "Force stopping VM ID $vmid"
    qm stop $vmid
done

echo "All vms are shut down. Shutting down the MAIN node..."
shutdown -h now

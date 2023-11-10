#!/usr/bin/env bash

# This script is used to rebuild the environment for the LIMA project.
# It is intended to be run from the root of the LIMA project.

GIT_ROOT=$(git rev-parse --show-toplevel)

# Remove the old lima VMs

# Get the list of VMs
VM_LIST=$(limactl list --format '{{ .Name }}' | grep kubespray)
CP_COUNT=$(limactl list --format '{{ .Name }}' | grep -c kubespray-control-plane)
WK_COUNT=$(limactl list --format '{{ .Name }}' | grep -c kubespray-worker)

# Delete the VMs
for VM in $VM_LIST; do
    echo "Deleting $VM"
    limactl stop "$VM"
    limactl delete "$VM"
    sleep 1
done

# Create the new lima VMs
"$GIT_ROOT"/contrib/lima-setup/setup.sh create "$CP_COUNT" "$WK_COUNT"

ansible-playbook -i contrib/lima-setup/inventory/inventory.ini --become cluster.yml -vvv

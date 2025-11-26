#!/bin/bash

# Cleanup script to stop and delete the VM
# Uses variables from config.sh

source ./config.sh

echo "===================================================================="
echo "VM CLEANUP - Delete $VM_NAME"
echo "===================================================================="
echo ""

# Check if VM exists
if ! VBoxManage showvminfo "$VM_NAME" &> /dev/null; then
    echo "✗ VM '$VM_NAME' not found"
    exit 1
fi

echo ""
echo "VM found: $VM_NAME"
echo ""

# Ask for confirmation
read -p "Are you sure you want to DELETE '$VM_NAME'? This cannot be undone. (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Deleting VM..."

# Stop the VM if it's running
echo "  Stopping VM..."
VBoxManage controlvm "$VM_NAME" poweroff 2>/dev/null
sleep 2

# Unregister and delete the VM
echo "  Unregistering VM..."
VBoxManage unregistervm "$VM_NAME" --delete

if [ $? -eq 0 ]; then
    echo ""
    echo "===================================================================="
    echo "✓ VM '$VM_NAME' successfully deleted"
    echo "===================================================================="
else
    echo ""
    echo "===================================================================="
    echo "✗ Error deleting VM"
    echo "===================================================================="
    exit 1
fi

echo ""
echo "Optional cleanup:"
echo "  • Remove shared folder: rm -rf $SHARED_FOLDER_HOST"

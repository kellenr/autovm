#!/bin/bash

# Start VM script - Starts the VirtualBox VM
# Uses configuration from config.sh

source ./config.sh

echo "===================================================================="
echo "Starting VM: $VM_NAME"
echo "===================================================================="
echo ""

# Check if VM exists
if ! VBoxManage showvminfo "$VM_NAME" &> /dev/null; then
    echo "✗ VM '$VM_NAME' not found"
    echo "Run 'bash create-vm.sh' to create it first"
    exit 1
fi

# Check if already running
if VBoxManage list runningvms | grep -q "\"$VM_NAME\""; then
    echo "✗ VM '$VM_NAME' is already running"
    exit 1
fi

# Start the VM
echo "Booting VM..."
VBoxManage startvm "$VM_NAME"

if [ $? -eq 0 ]; then
    echo ""
    echo "===================================================================="
    echo "✓ VM started successfully!"
    echo "===================================================================="
    echo ""
    echo "VM: $VM_NAME"
    echo "SSH: ssh -p 2222 root@localhost (after installation)"
    echo "SSH: ssh -p 2222 kellenr@localhost (regular user)"
    echo ""
    echo "Installation:"
    echo "  1. Select 'Automated install' from boot menu"
    echo "  2. When prompted for preseed URL, enter:"
    echo "     http://10.0.2.2:8000/preseed.cfg"
    echo ""
    echo "To stop the VM:"
    echo "  VBoxManage controlvm $VM_NAME poweroff"
    echo "===================================================================="
else
    echo "✗ Error starting VM"
    exit 1
fi

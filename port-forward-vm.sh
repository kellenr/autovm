#!/bin/bash

source ./config.sh

echo "Stopping VM..."
VBoxManage controlvm "$VM_NAME" poweroff 2>/dev/null
sleep 2

echo "Configuring NAT port forwarding..."
echo " .. HTTP  8080 -> 80"
VBoxManage modifyvm "$VM_NAME" --natpf1 "http,tcp,,8080,,80"
echo " .. HTTPS 4443 -> 443"
VBoxManage modifyvm "$VM_NAME" --natpf1 "https,tcp,,4443,,443"

## Show current port forwarding rules
VBoxManage showvminfo "$VM_NAME" | grep "NIC 1 Rule"

echo "Booting VM..."
VBoxManage startvm "$VM_NAME"

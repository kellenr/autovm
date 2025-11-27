#!/usr/bin/env sh

# Configuration variables
VM_NAME="debian-xfce-docker"
VM_MEMORY=4096  # 4GB RAM
VM_CPUS=4
VM_DISK_SIZE=5000  # 30GB
VM_VRAM=128  # Video memory in MB
VM_BASE_FOLDER="/home/${USER}/vms/${VM_NAME}"

# Debian ISO configuration
# https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.2.0-amd64-netinst.iso
DEBIAN_VERSION="13.2.0"
DEBIAN_ISO_NAME="debian-${DEBIAN_VERSION}-amd64-netinst.iso"
DEBIAN_ISO_PATH="./iso/$DEBIAN_ISO_NAME"
DEBIAN_ISO_URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/$DEBIAN_ISO_NAME"

SHARED_FOLDER_HOST="${VM_BASE_FOLDER}/vm-shared"  # Folder on your host machine
SHARED_FOLDER_NAME="shared"

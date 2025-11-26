#!/bin/bash

source ./config.sh

# Function to download Debian ISO
download_debian_iso() {
    echo "Checking for Debian ISO..."

    if [ -f "$DEBIAN_ISO_PATH" ]; then
        echo "✓ Debian ISO found: $DEBIAN_ISO_PATH"
    else
        echo "Debian ISO not found. Downloading..."
        echo "URL: $DEBIAN_ISO_URL"
        echo "This may take a few minutes..."

        # Download with wget (with progress bar) or curl
        if command -v wget &> /dev/null; then
            wget -O "$DEBIAN_ISO_PATH" "$DEBIAN_ISO_URL"
        elif command -v curl &> /dev/null; then
            curl -L -o "$DEBIAN_ISO_PATH" "$DEBIAN_ISO_URL"
        else
            echo "Error: Neither wget nor curl found. Please install one of them."
            exit 1
        fi

        if [ $? -eq 0 ]; then
            echo "✓ Download completed: $DEBIAN_ISO_PATH"
        else
            echo "✗ Error downloading ISO"
            exit 1
        fi
    fi

    # Verify the file exists and has reasonable size (> 100MB)
    if [ -f "$DEBIAN_ISO_PATH" ]; then
        FILE_SIZE=$(stat -c%s "$DEBIAN_ISO_PATH" 2>/dev/null || stat -f%z "$DEBIAN_ISO_PATH" 2>/dev/null)
        if [ "$FILE_SIZE" -lt 100000000 ]; then
            echo "✗ Error: Downloaded ISO seems too small (${FILE_SIZE} bytes). Removing..."
            rm "$DEBIAN_ISO_PATH"
            exit 1
        fi
        echo "✓ ISO file size: $(numfmt --to=iec-i --suffix=B $FILE_SIZE 2>/dev/null || echo "${FILE_SIZE} bytes")"
    fi
}

# Create shared folder on host if it doesn't exist
mkdir -p "$SHARED_FOLDER_HOST"

# Download ISO if needed
download_debian_iso

# Check if VM already exists
if VBoxManage showvminfo "$VM_NAME" &> /dev/null; then
    echo "✗ VM '$VM_NAME' already exists!"
    read -p "Do you want to delete it and create a new one? (yes/no): " answer
    if [ "$answer" = "yes" ]; then
        echo "Stopping and removing existing VM..."
        VBoxManage controlvm "$VM_NAME" poweroff 2>/dev/null
        sleep 2
        VBoxManage unregistervm "$VM_NAME" --delete
    else
        echo "Exiting..."
        exit 1
    fi
fi

# Create the VM
echo "Creating VM: $VM_NAME"
VBoxManage createvm --name "$VM_NAME" --ostype "Debian_64" --register

# Configure VM settings
echo "Configuring VM settings..."
VBoxManage modifyvm "$VM_NAME" \
    --memory $VM_MEMORY \
    --cpus $VM_CPUS \
    --vram $VM_VRAM \
    --boot1 dvd \
    --boot2 disk \
    --boot3 none \
    --boot4 none \
    --audio-driver none \
    --nic1 nat \
    --natpf1 "ssh,tcp,,2222,,22"

# Create hard disk
echo "Creating virtual hard disk..."
VM_FOLDER=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "CfgFile" | cut -d'"' -f2 | sed 's|/[^/]*$||')
VBoxManage createhd --filename "$VM_FOLDER/$VM_NAME.vdi" --size $VM_DISK_SIZE --variant Standard

# Add SATA controller
echo "Adding storage controllers..."
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci --portcount 2

# Attach hard disk
VBoxManage storageattach "$VM_NAME" \
    --storagectl "SATA Controller" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "$VM_FOLDER/$VM_NAME.vdi"

# Attach Debian ISO
echo "Attaching Debian ISO..."
VBoxManage storageattach "$VM_NAME" \
    --storagectl "SATA Controller" \
    --port 1 \
    --device 0 \
    --type dvddrive \
    --medium "$DEBIAN_ISO_PATH"

# Start HTTP server for preseed
echo "Starting HTTP server to serve preseed file..."
# Kill any existing HTTP servers on port 8000
pkill -f "python3 -m http.server 8000" 2>/dev/null || true
sleep 1
python3 -m http.server 8000 &
HTTP_SERVER_PID=$!
echo "✓ HTTP server started (PID: $HTTP_SERVER_PID)"

# Give the server a moment to start
sleep 2

echo ""
echo "===================================================================="
echo "VM created successfully!"
echo "===================================================================="
echo ""
echo "IMPORTANT: When the Debian installer boots, press ESC at the boot menu"
echo "and enter the following boot parameters:"
echo ""
echo "    auto url=http://10.0.2.2:8000/preseed.cfg"
echo ""
echo "(10.0.2.2 is the host machine from the VM's NAT perspective)"
echo ""
echo "VM Details:"
echo "  Name: $VM_NAME"
echo "  Memory: ${VM_MEMORY}MB"
echo "  CPUs: $VM_CPUS"
echo "  Disk: ${VM_DISK_SIZE}MB (~30GB)"
echo "  ISO: $DEBIAN_ISO_PATH"
echo "  SSH: localhost:2222 (forwards to VM port 22)"
echo "  User: debian / Password: debian"
echo "  Root: root / Password: root"
echo ""
echo "Software to be installed:"
echo "  - XFCE Desktop Environment"
echo "  - Docker Engine"
echo "  - SSH Server"
echo ""
echo "Starting VM..."
VBoxManage startvm "$VM_NAME"

echo ""
echo "Installation will proceed automatically..."
echo "HTTP server will continue running. Stop it with: pkill -f 'python3 -m http.server'"

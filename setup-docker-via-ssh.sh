#!/bin/bash

# Setup SSH key-based authentication for VM access
# Generates a keypair and adds public key to VM

source ./config.sh

SSH_PORT="2222"
SSH_HOST="localhost"
SSH_USER="kellenr"
KEY_NAME="autovm_key"
KEY_PATH="$HOME/.ssh/$KEY_NAME"

echo "=========================================="
echo "Setting up SSH Key Authentication"
echo "=========================================="
echo ""

# Check if key already exists
if [ -f "$KEY_PATH" ]; then
    echo "⚠ Key already exists: $KEY_PATH"
    read -p "Use existing key? (y/n): " use_existing
    if [ "$use_existing" != "y" ]; then
        echo "Deleting old key..."
        rm -f "$KEY_PATH" "$KEY_PATH.pub"
    fi
fi

# Generate SSH key if it doesn't exist
if [ ! -f "$KEY_PATH" ]; then
    echo "Generating SSH key pair..."
    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "autovm-$USER"
    chmod 600 "$KEY_PATH"
    chmod 644 "$KEY_PATH.pub"
    echo "✓ Key generated: $KEY_PATH"
else
    echo "✓ Using existing key: $KEY_PATH"
fi

echo ""
echo "Adding public key to VM..."

# Add public key to VM's authorized_keys
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "mkdir -p ~/.ssh && chmod 700 ~/.ssh"

cat "$KEY_PATH.pub" | ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

if [ $? -eq 0 ]; then
    echo "✓ Public key added to VM"
else
    echo "✗ Error adding public key"
    exit 1
fi

echo ""
echo "Testing SSH key authentication..."
ssh -i "$KEY_PATH" -p $SSH_PORT $SSH_USER@$SSH_HOST "echo 'SSH key auth works!'"

if [ $? -eq 0 ]; then
    echo "✓ SSH key authentication verified"
else
    echo "✗ SSH key authentication failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "✓ SSH Key Setup Complete!"
echo "=========================================="
echo ""
echo "Run these commands to use Docker:"
echo ""
echo "  export SSH_KEY=$KEY_PATH"
echo "  export DOCKER_HOST=ssh://$SSH_USER@$SSH_HOST:$SSH_PORT"
echo ""
echo "Then test:"
echo "  docker ps"
echo "  docker run hello-world"
echo ""
echo "=========================================="

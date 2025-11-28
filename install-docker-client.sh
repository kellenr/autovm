#!/bin/bash

# Docker Client and Docker Compose Installer
# This script downloads Docker client and docker-compose binaries to ./bin

set -e  # Exit on any error

# Configuration
DOCKER_VERSION="27.4.0"
COMPOSE_VERSION="2.30.3"  # Latest stable version
INSTALL_DIR="./bin"
DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz"
COMPOSE_URL="https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-linux-x86_64"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}➜ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check architecture
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    print_error "This script is configured for x86_64 architecture."
    print_error "Your architecture is: $ARCH"
    print_info "You may need to modify the download URLs for your architecture."
    exit 1
fi

# Create installation directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    print_info "Creating directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
    print_success "Directory created"
else
    print_info "Directory $INSTALL_DIR already exists"
    if [ -f "$INSTALL_DIR/docker" ] || [ -f "$INSTALL_DIR/docker-compose" ]; then
        read -p "Binaries already exist. Do you want to overwrite? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled."
            exit 0
        fi
    fi
fi

cd "$INSTALL_DIR"

# Download Docker client
print_info "Downloading Docker client version $DOCKER_VERSION..."
if curl -fsSL "$DOCKER_URL" -o docker.tgz; then
    print_success "Docker download complete"
else
    print_error "Failed to download Docker client"
    exit 1
fi

# Extract only the docker client binary
print_info "Extracting Docker client binary..."
if tar xzvf docker.tgz --strip-components=1 docker/docker; then
    print_success "Docker extraction complete"
else
    print_error "Failed to extract Docker client"
    exit 1
fi

# Clean up Docker archive
rm docker.tgz
print_success "Cleaned up Docker archive"

# Make docker executable
chmod +x docker
print_success "Made docker binary executable"

# Download docker-compose
print_info "Downloading docker-compose version $COMPOSE_VERSION..."
if curl -fsSL "$COMPOSE_URL" -o docker-compose; then
    print_success "docker-compose download complete"
else
    print_error "Failed to download docker-compose"
    exit 1
fi

# Make docker-compose executable
chmod +x docker-compose
print_success "Made docker-compose binary executable"

# Get absolute path
ABSOLUTE_PATH=$(pwd)

# Detect shell configuration file
SHELL_CONFIG=""
if [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    case "$SHELL" in
        */bash)
            SHELL_CONFIG="$HOME/.bashrc"
            ;;
        */zsh)
            SHELL_CONFIG="$HOME/.zshrc"
            ;;
        *)
            SHELL_CONFIG="$HOME/.profile"
            ;;
    esac
fi

# Add to PATH if not already present
PATH_EXPORT="export PATH=\"$ABSOLUTE_PATH:\$PATH\""
if grep -q "$ABSOLUTE_PATH" "$SHELL_CONFIG" 2>/dev/null; then
    print_info "PATH already configured in $SHELL_CONFIG"
else
    print_info "Would you like to add $ABSOLUTE_PATH to your PATH in $SHELL_CONFIG? (y/n)"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Docker binaries" >> "$SHELL_CONFIG"
        echo "$PATH_EXPORT" >> "$SHELL_CONFIG"
        print_success "Added to PATH in $SHELL_CONFIG"
    else
        print_info "Skipped adding to PATH. You can run binaries with: $ABSOLUTE_PATH/docker"
    fi
fi

# Test the installation
export PATH="$ABSOLUTE_PATH:$PATH"
print_info "Testing installations..."

echo ""
print_info "Docker client version:"
if ./docker --version; then
    print_success "Docker client works!"
else
    print_error "Docker client test failed"
fi

echo ""
print_info "docker-compose version:"
if ./docker-compose version; then
    print_success "docker-compose works!"
else
    print_error "docker-compose test failed"
fi

# Final instructions
echo ""
print_success "Installation complete!"
echo ""
echo "Installed to: $ABSOLUTE_PATH"
echo "  - docker: $ABSOLUTE_PATH/docker"
echo "  - docker-compose: $ABSOLUTE_PATH/docker-compose"
echo ""
echo "To use the binaries immediately, run:"
echo "  export PATH=\"$ABSOLUTE_PATH:\$PATH\""
echo ""
echo "Or source your shell config:"
echo "  source $SHELL_CONFIG"
echo ""
echo "Or simply open a new terminal."
echo ""
print_info "IMPORTANT: About using Docker without installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "The Docker CLIENT is just a tool to talk to the Docker daemon."
echo ""
echo "These binaries will work if:"
echo "  ✓ Architecture matches (you have x86_64)"
echo "  ✓ You have access to a Docker daemon (local or remote)"
echo ""
echo "The Docker client does NOT need Docker libraries installed."
echo "It's a statically-linked binary that works standalone."
echo ""
echo "However, you STILL NEED a Docker daemon running somewhere:"
echo "  - Locally: Docker Engine must be installed and running"
echo "  - Remotely: Set DOCKER_HOST=tcp://remote-host:2376"
echo ""
echo "For your Inception project, you'll need full Docker Engine"
echo "installed in your VM, but you can use this client to control it."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

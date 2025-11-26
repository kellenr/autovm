# AutoVM

Automated Debian VM with Docker pre-installed.

## Quick Start

```bash
# 1. Create and start VM
bash create-vm.sh
bash start-vm.sh

# 2. Wait ~15 min for installation

# 3. Setup Docker via SSH
bash setup-docker-via-ssh.sh

# 4. Copy the two export commands from output
export SSH_KEY=~/.ssh/autovm_key
export DOCKER_HOST=ssh://kellenr@localhost:2222

# 5. Use Docker
docker ps

# 6. Cleanup when done
bash stop-and-delete.sh
```

## Scripts

- `create-vm.sh` - Create VM
- `start-vm.sh` - Start VM
- `setup-docker-via-ssh.sh` - Setup Docker + SSH keys
- `stop-and-delete.sh` - Delete VM

## SSH Access

```bash
ssh -p 2222 kellenr@localhost
ssh -p 2222 root@localhost
```

Credentials: `root/root` and `kellenr/kellenr`

## Customize

Edit `config.sh` to change VM settings:

```bash
VM_NAME="debian-xfce-docker"
VM_MEMORY=4096
VM_CPUS=2
VM_DISK_SIZE=30000
```

## Requirements

- VirtualBox
- Bash
- wget or curl
- Internet connection

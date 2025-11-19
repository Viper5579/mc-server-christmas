# Server Management Scripts

This directory will contain helper scripts for server management.

## Scripts Included in setup.sh

The main `setup.sh` script in the root directory creates these scripts automatically:

### 1. `start.sh`
- Location: `~/minecraft/start.sh`
- Purpose: Starts the Minecraft server with optimized JVM flags
- Created by: `setup.sh` during installation

### 2. `monitor-players.sh`
- Location: `~/monitor-players.sh`
- Purpose: Monitors player count and shuts down server after 10 minutes of inactivity
- Created by: `setup.sh` during installation

## Additional Useful Scripts

You can create additional helper scripts in your `~/minecraft/` directory:

### Backup Script

```bash
#!/bin/bash
# ~/minecraft/backup.sh

DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/minecraft/backups"

echo "Stopping server..."
sudo systemctl stop minecraft

echo "Creating backup..."
cd ~/minecraft
tar -czf "$BACKUP_DIR/backup-$DATE.tar.gz" \
    world world_nether world_the_end \
    server.properties ops.json whitelist.json

echo "Starting server..."
sudo systemctl start minecraft

echo "Backup complete: backup-$DATE.tar.gz"
```

### Quick OP Script

```bash
#!/bin/bash
# ~/minecraft/op-player.sh

if [ -z "$1" ]; then
    echo "Usage: ./op-player.sh USERNAME"
    exit 1
fi

RCON_PASSWORD=$(cat ~/rcon-password.txt)
mcrcon -H localhost -P 25575 -p "$RCON_PASSWORD" "op $1"
echo "Gave OP to $1"
```

### Server Status Script

```bash
#!/bin/bash
# ~/minecraft/status.sh

echo "=== Server Status ==="
systemctl status minecraft --no-pager | head -3

echo ""
echo "=== Player Count ==="
RCON_PASSWORD=$(cat ~/rcon-password.txt)
mcrcon -H localhost -P 25575 -p "$RCON_PASSWORD" "list"

echo ""
echo "=== Resource Usage ==="
free -h | grep "Mem:"
df -h | grep "/$"

echo ""
echo "=== Public IP ==="
curl -s ifconfig.me
echo ""
```

### Install Mod Script

```bash
#!/bin/bash
# ~/minecraft/install-mod.sh

if [ -z "$1" ]; then
    echo "Usage: ./install-mod.sh MOD_URL"
    echo "Example: ./install-mod.sh https://example.com/mod.jar"
    exit 1
fi

cd ~/minecraft/mods
wget "$1"

echo "Mod downloaded. Restart server to load:"
echo "sudo systemctl restart minecraft"
```

## Making Scripts Executable

```bash
chmod +x ~/minecraft/*.sh
```

## Running Scripts

```bash
# Backup
~/minecraft/backup.sh

# OP a player
~/minecraft/op-player.sh PlayerName

# Check status
~/minecraft/status.sh

# Install mod
~/minecraft/install-mod.sh https://example.com/mod.jar
```

## Systemd Services

The setup creates these systemd services:

### minecraft.service
- Manages the Minecraft server
- Auto-starts on boot
- Auto-restarts on failure

### minecraft-autoshutdown.service
- Monitors player count
- Shuts down EC2 instance after 10 minutes of inactivity

## Service Management

```bash
# Start/stop/restart
sudo systemctl start minecraft
sudo systemctl stop minecraft
sudo systemctl restart minecraft

# Enable/disable auto-start
sudo systemctl enable minecraft
sudo systemctl disable minecraft

# View logs
sudo journalctl -u minecraft -f
```

## Scheduled Tasks (Cron)

Add automated backups:

```bash
# Edit crontab
crontab -e

# Add daily backup at 3 AM
0 3 * * * ~/minecraft/backup.sh

# Add hourly world save
0 * * * * mcrcon -H localhost -P 25575 -p $(cat ~/rcon-password.txt) "save-all"
```

## Advanced: Screen Sessions

Run server in screen for manual control:

```bash
# Start server in screen
screen -S minecraft
cd ~/minecraft
./start.sh

# Detach: Ctrl+A then D

# Re-attach
screen -r minecraft

# List screens
screen -ls
```

## Docker Alternative

If you prefer Docker, you can use:

```bash
# Install Docker
sudo apt-get install -y docker.io

# Run Minecraft in Docker
docker run -d \
  --name minecraft \
  -p 25565:25565 \
  -v ~/minecraft:/data \
  -e EULA=TRUE \
  -e TYPE=FORGE \
  -e VERSION=1.21 \
  itzg/minecraft-server
```

---

For more help, see the main [README.md](../README.md)

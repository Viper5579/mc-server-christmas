# Manual Installation Guide

This guide provides step-by-step manual installation instructions if you prefer not to use the automated `setup.sh` script.

**Platform**: Amazon Linux 2023 on t4g.medium (ARM64/Graviton2)

---

## Prerequisites

- AWS EC2 instance running Amazon Linux 2023 (ARM64)
- Instance type: t4g.medium or larger
- SSH access to the instance
- Basic command line knowledge

---

## Step 1: Connect to Your Server

```bash
chmod 400 your-key-pair.pem
ssh -i "your-key-pair.pem" ec2-user@YOUR-ELASTIC-IP
```

**Note**: Amazon Linux uses `ec2-user` as the default user

---

## Step 2: Update System

```bash
# Amazon Linux 2023 uses dnf (Amazon Linux 2 uses yum - both work)
sudo dnf update -y
sudo dnf upgrade -y
sudo dnf install -y wget curl unzip screen htop net-tools git tar gzip
```

**Note**: Amazon Linux 2023 uses `dnf`, Amazon Linux 2 uses `yum`. Both commands work on both versions.

---

## Step 3: Install Java 21 (Amazon Corretto)

```bash
# Install Amazon Corretto 21 (optimized for ARM64/Graviton2)
sudo dnf install -y java-21-amazon-corretto-devel

# Verify installation
java -version
# Should show "Corretto-21.x.x" - Amazon's optimized OpenJDK
```

**Why Corretto?** Amazon Corretto is optimized for ARM64/Graviton2 and provides better performance on t4g instances.

---

## Step 4: Create Minecraft Directory

```bash
mkdir -p ~/minecraft
cd ~/minecraft
mkdir -p mods backups resource-packs
```

---

## Step 5: Download Forge Server

```bash
cd ~/minecraft

# Download Forge installer for Minecraft 1.21
# Note: Update this URL when 1.21.10 is released
FORGE_VERSION="1.21-51.0.33"
wget -O forge-installer.jar "https://maven.minecraftforge.net/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar"

# Run installer
java -jar forge-installer.jar --installServer

# Clean up installer
rm forge-installer.jar
```

---

## Step 6: Accept EULA

```bash
echo "eula=true" > eula.txt
```

---

## Step 7: Download Configuration Files

```bash
# Clone the repository to get config files
cd ~
git clone https://github.com/Viper5579/mc-server-christmas.git

# Copy server.properties
cp ~/mc-server-christmas/configs/server.properties ~/minecraft/server.properties
```

---

## Step 8: Set RCON Password

```bash
# Generate secure RCON password
RCON_PASSWORD=$(openssl rand -base64 12)
echo "$RCON_PASSWORD" > ~/rcon-password.txt

# Update server.properties
sed -i "s/rcon.password=.*/rcon.password=$RCON_PASSWORD/" ~/minecraft/server.properties

echo "RCON password saved to ~/rcon-password.txt"
```

---

## Step 9: Create Start Script

```bash
cd ~/minecraft

cat > start.sh << 'EOF'
#!/bin/bash
# Minecraft Server Start Script

# Find forge jar
FORGE_JAR=$(ls -1 forge-*-*.jar | grep -v installer | head -n 1)

# Start server with optimized flags
java -Xms1G -Xmx3G \
  -XX:+UseG1GC \
  -XX:+ParallelRefProcEnabled \
  -XX:MaxGCPauseMillis=200 \
  -XX:+UnlockExperimentalVMOptions \
  -XX:+DisableExplicitGC \
  -XX:+AlwaysPreTouch \
  -XX:G1NewSizePercent=30 \
  -XX:G1MaxNewSizePercent=40 \
  -XX:G1HeapRegionSize=8M \
  -XX:G1ReservePercent=20 \
  -XX:G1HeapWastePercent=5 \
  -XX:G1MixedGCCountTarget=4 \
  -XX:InitiatingHeapOccupancyPercent=15 \
  -XX:G1MixedGCLiveThresholdPercent=90 \
  -XX:G1RSetUpdatingPauseTimePercent=5 \
  -XX:SurvivorRatio=32 \
  -XX:+PerfDisableSharedMem \
  -XX:MaxTenuringThreshold=1 \
  -jar $FORGE_JAR nogui
EOF

chmod +x start.sh
```

---

## Step 10: Create Systemd Service

```bash
sudo tee /etc/systemd/system/minecraft.service > /dev/null << EOF
[Unit]
Description=Minecraft Christmas Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/minecraft
ExecStart=$HOME/minecraft/start.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable auto-start
sudo systemctl enable minecraft
```

---

## Step 11: Install MCRCON (for auto-shutdown)

```bash
# Install development tools for compiling
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y gcc make

# Clone and build mcrcon
cd /tmp
git clone https://github.com/Tiiffi/mcrcon.git
cd mcrcon
make
sudo make install

# Verify installation
which mcrcon
```

---

## Step 12: Create Auto-Shutdown Script

```bash
cat > ~/monitor-players.sh << 'EOF'
#!/bin/bash
# Auto-shutdown monitor for Minecraft server

RCON_PASSWORD=$(cat ~/rcon-password.txt)
IDLE_TIME=0
MAX_IDLE=600  # 10 minutes in seconds

while true; do
    # Get player count via RCON
    PLAYERS=$(mcrcon -H localhost -P 25575 -p "$RCON_PASSWORD" "list" 2>/dev/null | grep -oP '\d+(?= of)' || echo "0")

    if [ "$PLAYERS" -eq 0 ]; then
        IDLE_TIME=$((IDLE_TIME + 60))
        echo "$(date): No players online. Idle for $IDLE_TIME seconds..."

        if [ "$IDLE_TIME" -ge "$MAX_IDLE" ]; then
            echo "$(date): Shutting down instance to save money..."
            sudo shutdown -h now
        fi
    else
        IDLE_TIME=0
        echo "$(date): $PLAYERS players online. Server active."
    fi

    sleep 60
done
EOF

chmod +x ~/monitor-players.sh
```

---

## Step 13: Create Auto-Shutdown Service

```bash
sudo tee /etc/systemd/system/minecraft-autoshutdown.service > /dev/null << EOF
[Unit]
Description=Minecraft Auto-Shutdown Monitor
After=minecraft.service

[Service]
Type=simple
User=$USER
ExecStart=$HOME/monitor-players.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload and enable
sudo systemctl daemon-reload
sudo systemctl enable minecraft-autoshutdown
```

---

## Step 14: Configure Firewall

```bash
# Amazon Linux uses firewalld (but AWS Security Groups are primary)
# These are backup firewall rules on the instance itself

# Start and enable firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Open ports
sudo firewall-cmd --permanent --add-port=22/tcp       # SSH
sudo firewall-cmd --permanent --add-port=25565/tcp    # Minecraft
sudo firewall-cmd --permanent --add-port=25575/tcp    # RCON
sudo firewall-cmd --permanent --add-port=8443/tcp     # Crafty GUI

# Reload firewall
sudo firewall-cmd --reload

# Check status
sudo firewall-cmd --list-all
```

**Important**: AWS Security Groups are your primary firewall. Make sure you configured those when creating the EC2 instance!

---

## Step 15: First Server Start

```bash
cd ~/minecraft

# Start server manually for first time
timeout 120 bash start.sh &
SERVER_PID=$!

# Wait for initial generation
sleep 60

# Stop server
kill $SERVER_PID 2>/dev/null || true

# Wait for clean shutdown
sleep 10
```

---

## Step 16: Start Services

```bash
# Start Minecraft server
sudo systemctl start minecraft

# Start auto-shutdown monitor
sudo systemctl start minecraft-autoshutdown

# Check status
sudo systemctl status minecraft
sudo systemctl status minecraft-autoshutdown
```

---

## Step 17: Make Yourself Server Operator

```bash
# Replace YOUR_USERNAME with your Minecraft username
RCON_PASSWORD=$(cat ~/rcon-password.txt)
mcrcon -H localhost -P 25575 -p "$RCON_PASSWORD" "op YOUR_USERNAME"
```

---

## Optional: Install Crafty Controller GUI

```bash
# Install dependencies (Amazon Linux package names)
sudo dnf install -y python3 python3-pip python3-devel

# Download installer
cd ~
wget -O crafty-installer.sh https://gitlab.com/crafty-controller/crafty-installer-4.0/-/raw/main/install_crafty.sh

# Make executable
chmod +x crafty-installer.sh

# Run installer (interactive)
sudo ./crafty-installer.sh

# Follow prompts:
# - Install directory: /home/ec2-user/crafty
# - Create admin user
# - Set admin password

# Access GUI at: https://YOUR-IP:8443
```

---

## Optional: Install Web Server for Resource Packs

```bash
# Install nginx
sudo dnf install -y nginx

# Create directory
sudo mkdir -p /var/www/html/resourcepacks
sudo chmod 755 /var/www/html/resourcepacks

# Upload your resource pack
# (from local machine)
# scp -i your-key.pem pack.zip ec2-user@YOUR-IP:/tmp/
# Then move it:
# sudo mv /tmp/pack.zip /var/www/html/resourcepacks/

# Allow HTTP traffic through firewalld
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload

# Start nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

## Verification Steps

### 1. Check Java Installation

```bash
java -version
# Should show: openjdk version "21.x.x"
```

### 2. Check Forge Installation

```bash
ls ~/minecraft/forge-*.jar
# Should show forge jar file
```

### 3. Check Server Running

```bash
sudo systemctl status minecraft
# Should show: "active (running)"
```

### 4. Check Server Logs

```bash
sudo journalctl -u minecraft -n 50
# Should show server startup logs
```

### 5. Check Players Can Connect

From Minecraft client:
- Add server: `YOUR-ELASTIC-IP:25565`
- Try to connect
- Should see the world!

### 6. Check RCON Working

```bash
RCON_PASSWORD=$(cat ~/rcon-password.txt)
mcrcon -H localhost -P 25575 -p "$RCON_PASSWORD" "list"
# Should show: "There are 0 of a max of 20 players online"
```

### 7. Check Auto-Shutdown

```bash
sudo systemctl status minecraft-autoshutdown
# Should show: "active (running)"

# Check logs
sudo journalctl -u minecraft-autoshutdown -n 10
```

---

## Server Management Commands

### Start/Stop/Restart

```bash
# Start server
sudo systemctl start minecraft

# Stop server
sudo systemctl stop minecraft

# Restart server
sudo systemctl restart minecraft

# Check status
sudo systemctl status minecraft
```

### View Logs

```bash
# View live logs
sudo journalctl -u minecraft -f

# View last 100 lines
sudo journalctl -u minecraft -n 100

# View errors only
sudo journalctl -u minecraft -p err
```

### Send Console Commands

```bash
# Using RCON
RCON_PASSWORD=$(cat ~/rcon-password.txt)

# List players
mcrcon -H localhost -P 25575 -p "$RCON_PASSWORD" "list"

# Give item
mcrcon -H localhost -P 25575 -p "$RCON_PASSWORD" "give @p diamond 64"

# Change time
mcrcon -H localhost -P 25575 -p "$RCON_PASSWORD" "time set day"

# Teleport
mcrcon -H localhost -P 25575 -p "$RCON_PASSWORD" "tp PlayerName 0 100 0"
```

### Backup World

```bash
# Stop server
sudo systemctl stop minecraft

# Create backup
cd ~/minecraft
tar -czf ~/backups/world-backup-$(date +%Y%m%d-%H%M%S).tar.gz world world_nether world_the_end

# Start server
sudo systemctl start minecraft

# List backups
ls -lh ~/backups/
```

### Restore Backup

```bash
# Stop server
sudo systemctl stop minecraft

# Backup current world (safety)
mv ~/minecraft/world ~/minecraft/world.old

# Extract backup
cd ~/minecraft
tar -xzf ~/backups/world-backup-YYYYMMDD-HHMMSS.tar.gz

# Start server
sudo systemctl start minecraft
```

---

## Updating Server

### Update Minecraft/Forge

```bash
# Stop server
sudo systemctl stop minecraft

# Backup
cd ~/minecraft
tar -czf ~/backups/server-backup-$(date +%Y%m%d).tar.gz .

# Download new Forge version
cd ~/minecraft
wget -O forge-installer.jar "https://maven.minecraftforge.net/net/minecraftforge/forge/NEW-VERSION/forge-NEW-VERSION-installer.jar"

# Install
java -jar forge-installer.jar --installServer

# Start server
sudo systemctl start minecraft
```

### Update Mods

```bash
# Stop server
sudo systemctl stop minecraft

# Backup mods
cp -r ~/minecraft/mods ~/minecraft/mods.backup

# Remove old mod
rm ~/minecraft/mods/old-mod.jar

# Add new mod (upload via scp or wget)
# ... upload new-mod.jar to ~/minecraft/mods/

# Start server
sudo systemctl start minecraft
```

---

## Troubleshooting

### Server Won't Start

```bash
# Check logs
sudo journalctl -u minecraft -n 100

# Check if Java is installed
java -version

# Check if forge jar exists
ls ~/minecraft/forge-*.jar

# Check permissions
ls -la ~/minecraft/

# Fix permissions if needed
sudo chown -R $USER:$USER ~/minecraft/
```

### Out of Memory Errors

```bash
# Increase RAM allocation
nano ~/minecraft/start.sh
# Change -Xmx3G to -Xmx6G (requires larger EC2 instance)

# Restart
sudo systemctl restart minecraft
```

### Can't Connect to Server

```bash
# Check server is running
sudo systemctl status minecraft

# Check firewall (Amazon Linux uses firewalld)
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=25565/tcp
sudo firewall-cmd --reload

# Check AWS security group (this is more important!)
# - Port 25565 should be open to 0.0.0.0/0 in Security Group

# Check public IP
curl ifconfig.me
```

### Auto-Shutdown Not Working

```bash
# Check service status
sudo systemctl status minecraft-autoshutdown

# Check logs
sudo journalctl -u minecraft-autoshutdown -n 50

# Restart service
sudo systemctl restart minecraft-autoshutdown

# Test RCON manually
RCON_PASSWORD=$(cat ~/rcon-password.txt)
mcrcon -H localhost -P 25575 -p "$RCON_PASSWORD" "list"
```

---

## Next Steps

1. **Configure server** - Edit `~/minecraft/server.properties`
2. **Add mods** - Upload to `~/minecraft/mods/`
3. **Install resource pack** - See resource-packs/README.md
4. **Set up auto-startup** - See docs/AUTO_STARTUP_GUIDE.md
5. **Make yourself OP** - Use RCON to op yourself
6. **Invite friends** - Share your server IP!

---

## Summary

You've manually installed:

✅ Java 21
✅ Minecraft Forge 1.21
✅ Server with world seed -123456793079414942
✅ Systemd service for auto-start
✅ Auto-shutdown monitor
✅ RCON for remote management
✅ Firewall configuration

**Your server is ready!**

Access at: `YOUR-ELASTIC-IP:25565`

---

## Additional Resources

- Main README: [README.md](../README.md)
- Modding Guide: [MODDING_GUIDE.md](./MODDING_GUIDE.md)
- Resource Packs: [resource-packs/README.md](../resource-packs/README.md)
- Auto-Startup: [AUTO_STARTUP_GUIDE.md](./AUTO_STARTUP_GUIDE.md)

---

Happy holidays! 🎄

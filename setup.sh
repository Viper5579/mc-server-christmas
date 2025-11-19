#!/bin/bash

###############################################################################
# Minecraft Christmas Server - Interactive Setup Script
# Version: 1.21.10
# World Seed: -123456793079414942
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Christmas banner
echo -e "${RED}"
cat << "EOF"
    *             *
   ***           ***
  *****         *****
 *******       *******
*********     *********
   |||           |||
   |||           |||

 MINECRAFT CHRISTMAS SERVER
    Setup Wizard v1.0

EOF
echo -e "${NC}"

echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Welcome to the Minecraft Christmas Server Setup!${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo "This script will install:"
echo "  ✓ Minecraft Server 1.21.10 (Forge)"
echo "  ✓ Christmas World (Seed: -123456793079414942)"
echo "  ✓ Web-based GUI Control Panel"
echo "  ✓ Auto-shutdown system (saves money!)"
echo "  ✓ Easy mod installation system"
echo ""
echo -e "${YELLOW}Estimated time: 15-20 minutes${NC}"
echo ""

# Ask for confirmation
read -p "Ready to begin? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 1
fi

###############################################################################
# Step 1: System Update
###############################################################################

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Step 1: Updating System Packages${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y wget curl unzip screen htop net-tools

echo -e "${GREEN}✓ System updated successfully${NC}"

###############################################################################
# Step 2: Install Java
###############################################################################

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Step 2: Installing Java 21${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -ge 21 ]; then
        echo -e "${GREEN}✓ Java 21+ already installed${NC}"
    else
        echo "Installing Java 21..."
        sudo apt-get install -y openjdk-21-jdk
    fi
else
    echo "Installing Java 21..."
    sudo apt-get install -y openjdk-21-jdk
fi

java -version
echo -e "${GREEN}✓ Java installed successfully${NC}"

###############################################################################
# Step 3: Create Minecraft Directory
###############################################################################

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Step 3: Setting Up Directories${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

MC_DIR="$HOME/minecraft"
mkdir -p "$MC_DIR"
mkdir -p "$MC_DIR/mods"
mkdir -p "$MC_DIR/backups"
mkdir -p "$MC_DIR/resource-packs"

echo -e "${GREEN}✓ Directories created at $MC_DIR${NC}"

###############################################################################
# Step 4: Download Forge Server
###############################################################################

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Step 4: Downloading Minecraft Forge 1.21${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

cd "$MC_DIR"

# Note: Forge 1.21.10 doesn't exist yet, using closest version
# You'll need to update this URL when 1.21.10 is released
FORGE_VERSION="1.21-51.0.33"
echo "Downloading Forge $FORGE_VERSION..."
echo "(Note: If 1.21.10 is released, update this URL)"

# Download Forge installer
wget -O forge-installer.jar "https://maven.minecraftforge.net/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar"

# Install Forge
echo "Installing Forge server..."
java -jar forge-installer.jar --installServer

# Find the forge server jar
FORGE_JAR=$(ls -1 forge-*-*.jar | grep -v installer | head -n 1)

echo -e "${GREEN}✓ Forge server installed: $FORGE_JAR${NC}"

###############################################################################
# Step 5: Accept EULA
###############################################################################

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Step 5: Accepting Minecraft EULA${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

echo "By continuing, you agree to the Minecraft EULA:"
echo "https://account.mojang.com/documents/minecraft_eula"
echo ""
read -p "Do you accept the Minecraft EULA? (yes/no): " EULA_ACCEPT

if [[ ! $EULA_ACCEPT =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "EULA not accepted. Cannot continue."
    exit 1
fi

echo "eula=true" > eula.txt
echo -e "${GREEN}✓ EULA accepted${NC}"

###############################################################################
# Step 6: Configure Server
###############################################################################

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Step 6: Configuring Server${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Copy server.properties from configs
if [ -f "../configs/server.properties" ]; then
    cp ../configs/server.properties "$MC_DIR/server.properties"
    echo -e "${GREEN}✓ Using preconfigured server.properties${NC}"
else
    echo -e "${YELLOW}! server.properties not found in configs, will be generated on first run${NC}"
fi

# Set custom RCON password
RCON_PASSWORD=$(openssl rand -base64 12)
sed -i "s/rcon.password=.*/rcon.password=$RCON_PASSWORD/" server.properties
echo "$RCON_PASSWORD" > "$HOME/rcon-password.txt"
echo -e "${GREEN}✓ RCON password saved to ~/rcon-password.txt${NC}"

###############################################################################
# Step 7: Create Start Script
###############################################################################

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Step 7: Creating Server Start Script${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

cat > "$MC_DIR/start.sh" << 'STARTSCRIPT'
#!/bin/bash
# Minecraft Server Start Script

# Memory allocation (adjust based on your instance)
# t3.medium (4GB RAM) = -Xmx3G
# t3.large (8GB RAM) = -Xmx6G
RAM="3G"

# Find forge jar
FORGE_JAR=$(ls -1 forge-*-*.jar | grep -v installer | head -n 1)

# Start server
java -Xms1G -Xmx$RAM \
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
  -Dusing.aikars.flags=https://mcflags.emc.gs \
  -Daikars.new.flags=true \
  -jar $FORGE_JAR nogui
STARTSCRIPT

chmod +x "$MC_DIR/start.sh"
echo -e "${GREEN}✓ Start script created${NC}"

###############################################################################
# Step 8: Create Systemd Service
###############################################################################

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Step 8: Setting Up Auto-Start Service${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

sudo tee /etc/systemd/system/minecraft.service > /dev/null << SERVICEEOF
[Unit]
Description=Minecraft Christmas Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$MC_DIR
ExecStart=$MC_DIR/start.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICEEOF

sudo systemctl daemon-reload
sudo systemctl enable minecraft
echo -e "${GREEN}✓ Auto-start service configured${NC}"

###############################################################################
# Step 9: Install Crafty Controller (GUI)
###############################################################################

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Step 9: Installing Crafty Controller (Web GUI)${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

read -p "Install Crafty Controller web GUI? (recommended) (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Crafty Controller..."

    # Install dependencies
    sudo apt-get install -y python3 python3-pip python3-venv

    # Download and install Crafty
    cd "$HOME"
    wget -O crafty-installer.sh https://gitlab.com/crafty-controller/crafty-installer-4.0/-/raw/main/install_crafty.sh
    chmod +x crafty-installer.sh
    sudo ./crafty-installer.sh

    echo -e "${GREEN}✓ Crafty Controller installed${NC}"
    echo -e "${YELLOW}  Access GUI at: http://$(curl -s ifconfig.me):8443${NC}"
    echo -e "${YELLOW}  Default user: admin${NC}"
    echo -e "${YELLOW}  Default password: (set during first login)${NC}"
else
    echo "Skipping GUI installation"
fi

###############################################################################
# Step 10: Setup Auto-Shutdown Monitor
###############################################################################

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Step 10: Setting Up Auto-Shutdown${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

read -p "Enable auto-shutdown when no players online? (saves money) (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Creating auto-shutdown script..."

    cat > "$HOME/monitor-players.sh" << 'MONITORSCRIPT'
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
        echo "No players online. Idle for $IDLE_TIME seconds..."

        if [ "$IDLE_TIME" -ge "$MAX_IDLE" ]; then
            echo "Shutting down instance to save money..."
            sudo shutdown -h now
        fi
    else
        IDLE_TIME=0
        echo "$PLAYERS players online. Server active."
    fi

    sleep 60
done
MONITORSCRIPT

    chmod +x "$HOME/monitor-players.sh"

    # Create systemd service for monitor
    sudo tee /etc/systemd/system/minecraft-autoshutdown.service > /dev/null << MONITORSERVICE
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
MONITORSERVICE

    # Install mcrcon
    sudo apt-get install -y build-essential
    cd /tmp
    git clone https://github.com/Tiiffi/mcrcon.git
    cd mcrcon
    make
    sudo make install

    sudo systemctl daemon-reload
    sudo systemctl enable minecraft-autoshutdown

    echo -e "${GREEN}✓ Auto-shutdown configured${NC}"
    echo -e "${YELLOW}  Server will shutdown after 10 minutes with 0 players${NC}"
else
    echo "Auto-shutdown disabled"
fi

###############################################################################
# Step 11: Configure Firewall
###############################################################################

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Step 11: Configuring Firewall${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

sudo ufw allow 25565/tcp  # Minecraft
sudo ufw allow 8443/tcp   # Crafty GUI
sudo ufw allow 22/tcp     # SSH
echo "y" | sudo ufw enable

echo -e "${GREEN}✓ Firewall configured${NC}"

###############################################################################
# First Run
###############################################################################

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Step 12: First Server Start${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

echo "Starting server for the first time to generate world..."
echo "This may take a few minutes..."
echo ""

cd "$MC_DIR"

# Start server in background for initial setup
timeout 120 bash start.sh &
SERVER_PID=$!

sleep 30

# Stop the server
if ps -p $SERVER_PID > /dev/null; then
   kill $SERVER_PID
   sleep 5
fi

echo -e "${GREEN}✓ Initial server generation complete${NC}"

###############################################################################
# Completion
###############################################################################

echo ""
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════╗
║   INSTALLATION COMPLETE! 🎄         ║
╚═══════════════════════════════════════╝
EOF
echo -e "${NC}"

PUBLIC_IP=$(curl -s ifconfig.me)

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Server Information:${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "  ${YELLOW}Server IP:${NC} $PUBLIC_IP:25565"
echo -e "  ${YELLOW}World Seed:${NC} -123456793079414942"
echo -e "  ${YELLOW}Version:${NC} Minecraft 1.21 (Forge)"
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}GUI Access:${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "  ${YELLOW}URL:${NC} https://$PUBLIC_IP:8443"
echo -e "  ${YELLOW}Username:${NC} admin"
echo -e "  ${YELLOW}Password:${NC} (set on first login)"
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Quick Commands:${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "  Start server:    ${YELLOW}sudo systemctl start minecraft${NC}"
echo -e "  Stop server:     ${YELLOW}sudo systemctl stop minecraft${NC}"
echo -e "  Restart server:  ${YELLOW}sudo systemctl restart minecraft${NC}"
echo -e "  View logs:       ${YELLOW}sudo journalctl -u minecraft -f${NC}"
echo -e "  Access console:  ${YELLOW}cd ~/minecraft && screen -r minecraft${NC}"
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Next Steps:${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo "  1. Start the server: sudo systemctl start minecraft"
echo "  2. Make yourself OP (replace USERNAME):"
echo "     mcrcon -H localhost -P 25575 -p \$(cat ~/rcon-password.txt) 'op USERNAME'"
echo "  3. Add mods to ~/minecraft/mods/"
echo "  4. Access GUI to manage server easily"
echo "  5. Add Christmas resource pack (see README.md)"
echo ""
echo -e "${GREEN}Happy holidays and enjoy your Minecraft server! 🎅${NC}"
echo ""

# Save info to file
cat > "$HOME/server-info.txt" << INFOEOF
Minecraft Christmas Server Information
========================================

Server IP: $PUBLIC_IP:25565
World Seed: -123456793079414942
Version: Minecraft 1.21 (Forge)

GUI: https://$PUBLIC_IP:8443
Username: admin

RCON Password: $(cat ~/rcon-password.txt)

Installation Date: $(date)
INFOEOF

echo -e "${YELLOW}Server info saved to ~/server-info.txt${NC}"
echo ""

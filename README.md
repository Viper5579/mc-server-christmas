# Minecraft Christmas Server Setup
## Minecraft Java Edition 1.21.10 with Christmas Mashup Pack

This repository contains everything you need to set up a fully-featured Minecraft server on AWS with:
- **Version**: Minecraft Java Edition 1.21.10
- **World Seed**: -123456793079414942
- **Resource Pack**: Christmas Mashup
- **GUI Management**: Web-based control panel
- **Easy Modding**: Forge mod loader support
- **Auto Shutdown/Startup**: Saves money when no one is playing
- **Minimal Terminal Work**: Interactive setup scripts

---

## Table of Contents
1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [AWS Setup](#aws-setup)
4. [Server Installation](#server-installation)
5. [GUI Management](#gui-management)
6. [Adding Mods](#adding-mods)
7. [Christmas Resource Pack](#christmas-resource-pack)
8. [Auto Shutdown/Startup](#auto-shutdownstartup)
9. [Troubleshooting](#troubleshooting)

---

## Quick Start

For the fastest setup, run:
```bash
chmod +x setup.sh
./setup.sh
```

This interactive script will guide you through the entire process!

---

## Prerequisites

Before starting, you'll need:

1. **AWS Account** - [Sign up here](https://aws.amazon.com/)
2. **Domain Name** (optional) - For easy server access
3. **SSH Client** - Built into Mac/Linux, use PuTTY on Windows
4. **Minecraft Java Edition** - Version 1.21.10 compatible

### AWS Cost Estimate
- **t3.medium instance** (~$30/month if running 24/7)
- **With auto-shutdown**: ~$5-15/month depending on usage
- **Storage**: ~$1-2/month

---

## AWS Setup

### Step 1: Create an EC2 Instance

1. **Log into AWS Console** → Navigate to EC2
2. **Click "Launch Instance"**
3. **Configure Instance**:
   - **Name**: `minecraft-christmas-server`
   - **AMI**: Ubuntu Server 22.04 LTS
   - **Instance Type**: `t3.medium` (2 vCPU, 4GB RAM)
     - For more players: `t3.large` (2 vCPU, 8GB RAM)
   - **Key Pair**: Create new or use existing (SAVE THIS FILE!)
   - **Storage**: 20 GB gp3

4. **Network Settings**:
   - Create security group with these rules:
     - SSH (22) - Your IP only
     - Custom TCP (25565) - Anywhere (Minecraft)
     - Custom TCP (8080) - Your IP only (Web GUI)
     - Custom TCP (25575) - Your IP only (RCON)

5. **Click "Launch Instance"**

### Step 2: Allocate Elastic IP (Important!)

1. Go to **EC2** → **Elastic IPs** → **Allocate Elastic IP**
2. Select the new IP → **Actions** → **Associate Elastic IP**
3. Choose your Minecraft instance
4. **Save this IP** - this is your server address!

### Step 3: Connect to Your Server

```bash
chmod 400 your-key-pair.pem
ssh -i "your-key-pair.pem" ubuntu@YOUR-ELASTIC-IP
```

---

## Server Installation

### Option 1: Automatic Installation (Recommended)

1. **Clone this repository**:
```bash
git clone https://github.com/Viper5579/mc-server-christmas.git
cd mc-server-christmas
```

2. **Run the setup script**:
```bash
chmod +x setup.sh
./setup.sh
```

The script will:
- Install Java 21
- Download Minecraft Forge 1.21.10
- Configure server with your world seed
- Set up the GUI panel
- Configure auto-shutdown
- Set up all configurations

### Option 2: Manual Installation

See [MANUAL_INSTALL.md](./docs/MANUAL_INSTALL.md) for step-by-step instructions.

---

## GUI Management

This server uses **Crafty Controller** - a beautiful web-based GUI for Minecraft servers.

### Accessing the GUI

1. **Open your browser** and go to:
   ```
   http://YOUR-ELASTIC-IP:8080
   ```

2. **Default credentials**:
   - Username: `admin`
   - Password: Generated during install (check `gui-password.txt`)

### What You Can Do in the GUI

- **Start/Stop Server** - One-click server control
- **View Console** - See server logs in real-time
- **Manage Players** - Kick, ban, whitelist players
- **Edit Files** - Modify configs without terminal
- **Install Mods** - Drag-and-drop mod installation
- **Backup World** - Schedule automatic backups
- **Monitor Performance** - CPU, RAM, player count

### Changing GUI Password

```bash
cd ~/crafty
./crafty-cli change-password admin
```

---

## Adding Mods

This server uses **Forge 1.21.10** for easy modding!

### Method 1: GUI Upload (Easiest)

1. Open Crafty Controller GUI
2. Go to **Files** → **mods** folder
3. **Drag and drop** your `.jar` mod files
4. **Restart server**

### Method 2: Direct Upload

```bash
# Upload mod to server
scp -i your-key.pem mod-file.jar ubuntu@YOUR-IP:~/minecraft/mods/

# Restart server
sudo systemctl restart minecraft
```

### Recommended Mods for Christmas Theme

- **Fairy Lights** - Christmas decorations
- **Macaw's Furniture** - Christmas furniture
- **Biomes O' Plenty** - Snowy biomes
- **Just Enough Items (JEI)** - Recipe viewing

All mods must be **Forge 1.21.10 compatible**!

### Where to Find Mods

- [CurseForge](https://www.curseforge.com/minecraft/mc-mods)
- [Modrinth](https://modrinth.com/mods)

---

## Christmas Resource Pack

The Christmas Mashup Pack adds festive textures to your world!

### Installation

1. **Download the pack**:
   - The pack is included in `resource-packs/christmas-mashup.zip`
   - Or download from [official source](https://www.minecraft.net/en-us/pdp?id=8c0e8c5e-e7e3-4c5e-8e5e-8e5e8e5e8e5e)

2. **Upload to server**:
```bash
# Via GUI: Files → resource-packs → Upload
# Or via command:
scp -i your-key.pem christmas-mashup.zip ubuntu@YOUR-IP:~/minecraft/resource-packs/
```

3. **Configure server** (already done if using our config):
   - The `server.properties` already has:
     ```properties
     resource-pack=http://YOUR-SERVER/christmas-mashup.zip
     resource-pack-prompt=Experience Christmas with us!
     resource-pack-required=false
     ```

4. **Players will auto-download** when joining!

### For Players

When you join, click "Yes" to download the resource pack. If you decline, you can enable it later:
1. Options → Resource Packs
2. It will appear in Available Packs

---

## Auto Shutdown/Startup

Save money by automatically shutting down when no one is playing!

### How It Works

- **Monitors player count** every minute
- **Shuts down AWS instance** after 10 minutes of 0 players
- **Auto-starts** when someone tries to join (via Lambda function)

### Setup

The `setup.sh` script configures this automatically, but here's what it does:

#### 1. Auto-Shutdown Script

Monitors the server and shuts down after inactivity:
```bash
sudo systemctl enable minecraft-autoshutdown
sudo systemctl start minecraft-autoshutdown
```

#### 2. Auto-Startup (AWS Lambda)

See [docs/AUTO_STARTUP_GUIDE.md](./docs/AUTO_STARTUP_GUIDE.md) for detailed Lambda setup.

**Quick version**:
1. Create Lambda function with provided code
2. Create API Gateway trigger
3. Update DNS to point to API Gateway
4. Players connect → Lambda starts instance → redirects to server

### Manual Control

```bash
# Check status
sudo systemctl status minecraft-autoshutdown

# Disable auto-shutdown temporarily
sudo systemctl stop minecraft-autoshutdown

# Re-enable
sudo systemctl start minecraft-autoshutdown
```

---

## Troubleshooting

### Server Won't Start

```bash
# Check logs
sudo journalctl -u minecraft -f

# Check Java version
java -version  # Should be 21+

# Check permissions
sudo chown -R ubuntu:ubuntu ~/minecraft
```

### Can't Connect to Server

1. **Check security group** - Port 25565 should be open
2. **Check server is running**: `sudo systemctl status minecraft`
3. **Verify IP address** - Use Elastic IP, not public IP
4. **Check firewall**:
```bash
sudo ufw status
sudo ufw allow 25565/tcp
```

### GUI Not Loading

```bash
# Check Crafty status
sudo systemctl status crafty

# Restart Crafty
sudo systemctl restart crafty

# View logs
cd ~/crafty && tail -f logs/latest.log
```

### Mods Not Working

1. **Verify Forge version** matches mod requirements (1.21.10)
2. **Check mod compatibility** - Some mods conflict
3. **View crash logs**: `~/minecraft/logs/latest.log`
4. **Remove mods one-by-one** to identify the problem

### Out of Memory

```bash
# Increase RAM allocation
nano ~/minecraft/start.sh
# Change -Xmx3G to -Xmx6G (requires larger instance)

# Restart server
sudo systemctl restart minecraft
```

### Players Keep Getting Kicked

- **Check server TPS**: Type `/tps` in console
- **Reduce view distance**: Edit `server.properties` → `view-distance=8`
- **Upgrade instance**: Switch to t3.large

---

## File Structure

```
mc-server-christmas/
├── README.md                          # This file
├── setup.sh                           # Interactive installation script
├── server.properties                  # Preconfigured with your seed
├── scripts/
│   ├── install-java.sh               # Java installation
│   ├── install-forge.sh              # Forge server setup
│   ├── install-gui.sh                # Crafty Controller setup
│   ├── monitor-players.sh            # Auto-shutdown monitor
│   └── start-server.sh               # Server startup script
├── lambda/
│   ├── auto-startup.py               # AWS Lambda function
│   └── lambda-setup.md               # Lambda configuration guide
├── docs/
│   ├── MANUAL_INSTALL.md             # Manual installation guide
│   ├── AUTO_STARTUP_GUIDE.md         # Detailed auto-startup setup
│   ├── MODDING_GUIDE.md              # Advanced modding guide
│   └── AWS_OPTIMIZATION.md           # Cost optimization tips
├── resource-packs/
│   └── README.md                     # Resource pack instructions
└── configs/
    ├── server.properties             # Server configuration
    ├── ops.json                      # Server operators
    └── whitelist.json                # Whitelisted players
```

---

## Support

### Common Commands

```bash
# Start server
sudo systemctl start minecraft

# Stop server
sudo systemctl stop minecraft

# Restart server
sudo systemctl restart minecraft

# View console
sudo journalctl -u minecraft -f

# Edit server properties
nano ~/minecraft/server.properties

# Access server console (RCON)
mcrcon -H localhost -P 25575 -p your-rcon-password
```

### Making Yourself OP

```bash
# Method 1: Via RCON
mcrcon -H localhost -P 25575 -p your-rcon-password "op YourUsername"

# Method 2: Via GUI
# Go to Crafty → Console → Type: op YourUsername

# Method 3: Edit ops.json
nano ~/minecraft/ops.json
```

---

## Credits

- **Minecraft** - Mojang Studios
- **Forge** - MinecraftForge Team
- **Crafty Controller** - Crafty Control Team
- **Christmas Mashup Pack** - Mojang Studios

---

## License

This setup guide and scripts are provided as-is for personal use. Minecraft and related assets are property of Mojang Studios.

---

## Quick Reference

**Server IP**: `YOUR-ELASTIC-IP:25565`
**GUI URL**: `http://YOUR-ELASTIC-IP:8080`
**World Seed**: `-123456793079414942`
**Version**: Minecraft Java Edition 1.21.10
**Mod Loader**: Forge 1.21.10

**Estimated Setup Time**: 30-45 minutes
**Difficulty**: Easy (with automatic script)
**Cost**: $5-30/month depending on usage

---

Enjoy your Christmas Minecraft adventure! 🎄

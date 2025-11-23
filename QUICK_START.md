# Quick Start Guide

Get your Christmas Minecraft server running in under 30 minutes!

**Platform**: Amazon Linux 2023 on t4g.medium (ARM64/Graviton2)

---

## ⚡ Super Quick Setup

### 1. Create AWS EC2 Instance (5 minutes)

1. Go to AWS EC2 Console
2. Click "Launch Instance"
3. Settings:
   - Name: `minecraft-christmas`
   - OS: **Amazon Linux 2023 AMI (ARM64)**
   - Instance: **t4g.medium** (ARM64/Graviton2)
   - Storage: 20GB
   - Security: Open ports 22, 25565, 8443
4. Create/download key pair
5. Launch!

### 2. Get Elastic IP (2 minutes)

1. EC2 → Elastic IPs → Allocate
2. Associate with your instance
3. **Write down this IP!**

### 3. Connect & Install (20 minutes)

```bash
# Connect (Amazon Linux uses ec2-user, not ubuntu)
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@YOUR-ELASTIC-IP

# Clone repo
git clone https://github.com/Viper5579/mc-server-christmas.git
cd mc-server-christmas

# Run installer (optimized for Amazon Linux + ARM64)
chmod +x setup.sh
./setup.sh
```

Answer the prompts and wait for installation!

### 4. Start Server (1 minute)

```bash
sudo systemctl start minecraft
```

### 5. Make Yourself OP

```bash
RCON_PASSWORD=$(cat ~/rcon-password.txt)
mcrcon -H localhost -P 25575 -p "$RCON_PASSWORD" "op YOUR_MINECRAFT_USERNAME"
```

### 6. Connect!

In Minecraft:
- Multiplayer → Add Server
- Address: `YOUR-ELASTIC-IP:25565`
- Join and play!

---

## 🎄 You're Done!

Server running with:
- ✅ Minecraft 1.21 (Forge)
- ✅ World seed: -123456793079414942
- ✅ Auto-shutdown (saves money!)
- ✅ Web GUI at: `https://YOUR-IP:8443`

---

## 📋 Quick Commands

```bash
# Start server
sudo systemctl start minecraft

# Stop server
sudo systemctl stop minecraft

# View logs
sudo journalctl -u minecraft -f

# Add mod (via GUI)
# Open https://YOUR-IP:8443 → Files → mods → Upload

# Or upload mod via command
scp -i key.pem mod.jar ec2-user@YOUR-IP:~/minecraft/mods/
```

---

## 🎮 Next Steps

1. **Add mods** - See [MODDING_GUIDE.md](docs/MODDING_GUIDE.md)
2. **Add resource pack** - See [resource-packs/README.md](resource-packs/README.md)
3. **Set up auto-startup** - See [AUTO_STARTUP_GUIDE.md](docs/AUTO_STARTUP_GUIDE.md)
4. **Invite friends!**

---

## 💰 Monthly Cost (t4g.medium ARM64)

- **Without auto-shutdown**: ~$24/month (20% cheaper than t3!)
- **With auto-shutdown**: ~$4-12/month
- **Savings**: Up to 83%!
- **ARM64 Bonus**: Better performance per dollar!

---

## ❓ Problems?

### Server won't start
```bash
sudo journalctl -u minecraft -n 50
```

### Can't connect
- Check security group has port 25565 open
- Use Elastic IP, not public IP
- Wait 2 minutes after starting

### Need help?
See [README.md](README.md) for detailed troubleshooting!

---

**Happy Holidays! 🎅**

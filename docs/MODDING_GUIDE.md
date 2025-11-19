# Minecraft Server Modding Guide

This guide will help you easily add mods to your Christmas Minecraft server. We've made modding as simple as possible - most of the time it's just drag-and-drop!

---

## Table of Contents

1. [Quick Start - Adding Mods](#quick-start---adding-mods)
2. [Understanding Forge](#understanding-forge)
3. [Finding Mods](#finding-mods)
4. [Recommended Christmas Mods](#recommended-christmas-mods)
5. [Installing Mods](#installing-mods)
6. [Troubleshooting](#troubleshooting)
7. [Creating Mod Packs](#creating-mod-packs)

---

## Quick Start - Adding Mods

### Method 1: Using Crafty GUI (Easiest!)

1. **Open Crafty** in your browser: `http://YOUR-IP:8443`
2. **Go to Files** → Navigate to `mods` folder
3. **Drag and drop** your `.jar` mod files
4. **Restart server** using the GUI

Done! That's it!

### Method 2: Using SCP (Terminal)

```bash
# From your local computer
scp -i your-key.pem mod-file.jar ubuntu@YOUR-IP:~/minecraft/mods/

# SSH into server
ssh -i your-key.pem ubuntu@YOUR-IP

# Restart server
sudo systemctl restart minecraft
```

### Method 3: Using wget (On Server)

```bash
# SSH into server
ssh -i your-key.pem ubuntu@YOUR-IP

# Download mod directly to mods folder
cd ~/minecraft/mods/
wget https://example.com/path/to/mod.jar

# Restart server
sudo systemctl restart minecraft
```

---

## Understanding Forge

Your server uses **Forge** - the most popular mod loader for Minecraft.

### What is Forge?

- **Mod Loader**: Lets you run multiple mods together
- **Compatibility**: Most Minecraft mods use Forge
- **Version Specific**: Mods must match your Minecraft version (1.21)

### Important Version Info

- **Minecraft Version**: 1.21
- **Forge Version**: 1.21-51.0.33 (or latest)
- **Mods MUST be**: Compatible with Minecraft 1.21 AND Forge

### Checking Mod Compatibility

Before downloading a mod, verify:

1. **Minecraft Version**: Must say 1.21 or 1.21.x
2. **Mod Loader**: Must say "Forge" (not Fabric, not vanilla)
3. **Forge Version**: Check if specific Forge version required

---

## Finding Mods

### Best Mod Websites

#### 1. CurseForge (Most Popular)
- **URL**: https://www.curseforge.com/minecraft/mc-mods
- **Pros**: Largest selection, well-maintained
- **Cons**: Some ads

**How to use**:
1. Go to CurseForge
2. Filter by:
   - Game Version: **1.21**
   - Mod Loader: **Forge**
3. Download `.jar` file

#### 2. Modrinth (Clean, Modern)
- **URL**: https://modrinth.com/mods
- **Pros**: Clean interface, open-source, no ads
- **Cons**: Smaller selection

**How to use**:
1. Go to Modrinth
2. Select **Filters**:
   - Loaders: **Forge**
   - Game versions: **1.21**
3. Download `.jar` file

#### 3. Planet Minecraft
- **URL**: https://www.planetminecraft.com/mods/
- **Pros**: Community-focused, creative mods
- **Cons**: Mixed quality

### Mod Safety Tips

✅ **Safe**:
- Mods from CurseForge or Modrinth
- Mods with many downloads
- Mods with recent updates
- Verified mod authors

❌ **Avoid**:
- Random file-sharing sites
- Mods without source links
- "Cracked" or "free" versions of paid mods
- Mods with no description or screenshots

---

## Recommended Christmas Mods

Perfect mods to enhance your Christmas world!

### 🎄 Decoration Mods

#### 1. **Fairy Lights**
- **What**: String lights, fairy lights, hanging lights
- **Perfect for**: Christmas decorations
- **Download**: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/fairy-lights)

#### 2. **Macaw's Furniture**
- **What**: Tons of furniture including Christmas items
- **Perfect for**: Decorating interiors
- **Download**: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/macaws-furniture)

#### 3. **Chipped**
- **What**: Thousands of block variants
- **Perfect for**: Building variety
- **Download**: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/chipped)

### ❄️ Biome & Weather Mods

#### 4. **Biomes O' Plenty**
- **What**: Adds amazing new biomes including snowy ones
- **Perfect for**: Christmas-themed landscapes
- **Download**: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/biomes-o-plenty)
- **Note**: Best if added BEFORE world generation!

#### 5. **Snow! Real Magic!**
- **What**: Better snow mechanics, snow buildup
- **Perfect for**: Winter wonderland feel
- **Download**: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/snow-real-magic)

### 🎁 Gameplay Mods

#### 6. **Just Enough Items (JEI)**
- **What**: Recipe viewer
- **Perfect for**: Seeing all mod recipes
- **Download**: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/jei)
- **Essential**: Highly recommended!

#### 7. **Waystones**
- **What**: Teleportation stones
- **Perfect for**: Fast travel between Christmas builds
- **Download**: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/waystones)

#### 8. **The Twilight Forest**
- **What**: Magical dimension with bosses
- **Perfect for**: Adventure and exploration
- **Download**: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/the-twilight-forest)

### 🔧 Utility Mods

#### 9. **JourneyMap**
- **What**: In-game map and waypoints
- **Perfect for**: Navigation
- **Download**: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/journeymap)

#### 10. **AppleSkin**
- **What**: Shows food values and saturation
- **Perfect for**: Better food management
- **Download**: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/appleskin)

### ⚙️ Performance Mods (Server-Side)

#### 11. **AI Improvements**
- **What**: Optimizes mob AI
- **Perfect for**: Better server performance
- **Download**: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/ai-improvements)

#### 12. **Clumps**
- **What**: Merges XP orbs to reduce lag
- **Perfect for**: Performance
- **Download**: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/clumps)

---

## Installing Mods

### Step-by-Step: GUI Method (Recommended)

1. **Download mod** `.jar` file to your computer

2. **Open Crafty GUI**:
   ```
   http://YOUR-SERVER-IP:8443
   ```

3. **Login** with your admin credentials

4. **Navigate to Files**:
   - Click **Files** in left sidebar
   - Open **mods** folder

5. **Upload mod**:
   - Click **Upload** button
   - Select your `.jar` file
   - Wait for upload to complete

6. **Verify upload**:
   - Mod should appear in file list
   - Check file size matches download

7. **Restart server**:
   - Go back to **Dashboard**
   - Click **Restart Server**
   - Wait 1-2 minutes

8. **Verify mod loaded**:
   - Go to **Console**
   - Look for mod name in startup logs
   - You should see: "Loaded X mods"

### Step-by-Step: Command Line Method

```bash
# 1. Download mod to your computer
# (Use browser or wget)

# 2. Upload to server
scp -i your-key.pem mod-file.jar ubuntu@YOUR-IP:~/minecraft/mods/

# 3. SSH into server
ssh -i your-key.pem ubuntu@YOUR-IP

# 4. Verify mod is there
ls -lh ~/minecraft/mods/

# 5. Restart server
sudo systemctl restart minecraft

# 6. Check logs
sudo journalctl -u minecraft -f
# Look for: "Loaded X mods" or your mod name
```

### Installing Multiple Mods at Once

**GUI Method**:
1. Select all `.jar` files in file browser
2. Drag and drop all at once
3. Crafty will upload all simultaneously
4. Restart once after all uploads complete

**Command Line Method**:
```bash
# Upload all mods in one command
scp -i your-key.pem *.jar ubuntu@YOUR-IP:~/minecraft/mods/

# Or use rsync for faster transfers
rsync -avz -e "ssh -i your-key.pem" ./mods/*.jar ubuntu@YOUR-IP:~/minecraft/mods/
```

---

## Mod Dependencies

Some mods require other mods to work. These are called **dependencies**.

### Common Dependencies

#### 1. **Forge** (Already Installed!)
- Required by: ALL Forge mods
- Already installed on your server

#### 2. **Architectury API**
- Required by: Many modern mods
- Download: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/architectury-api)

#### 3. **Cloth Config**
- Required by: Mods with config GUIs
- Download: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/cloth-config)

#### 4. **GeckoLib**
- Required by: Mods with complex animations
- Download: [CurseForge](https://www.curseforge.com/minecraft/mc-mods/geckolib)

### How to Know Dependencies

When downloading a mod:
1. Read the mod description
2. Look for "Dependencies" or "Required" section
3. Download all listed dependencies
4. Install dependencies BEFORE the main mod

### Example: Installing JourneyMap

```
1. Check dependencies: None! ✅
2. Download journeymap-1.21-x.x.x-forge.jar
3. Upload to mods folder
4. Restart
5. Done!
```

### Example: Installing a mod that needs Architectury

```
1. Check dependencies: Requires Architectury API
2. Download architectury-1.21-x.x.x-forge.jar
3. Download the-mod-1.21-x.x.x-forge.jar
4. Upload BOTH to mods folder
5. Restart
6. Done!
```

---

## Troubleshooting

### Server Won't Start After Adding Mod

**Problem**: Server crashes or won't start

**Solutions**:

1. **Check logs**:
```bash
sudo journalctl -u minecraft -n 100
# or
tail -n 100 ~/minecraft/logs/latest.log
```

2. **Common errors and fixes**:

**Error**: "Missing dependency"
- **Fix**: Install the required dependency mod

**Error**: "Duplicate mod"
- **Fix**: Remove one copy of the mod

**Error**: "Incompatible Forge version"
- **Fix**: Download mod for your Forge version or update Forge

**Error**: "Mod X is incompatible with Mod Y"
- **Fix**: Remove one of the conflicting mods

3. **Remove problematic mod**:
```bash
# Move mod out of mods folder
mv ~/minecraft/mods/problematic-mod.jar ~/minecraft/problematic-mod.jar.backup

# Restart
sudo systemctl restart minecraft
```

### Mod Installed But Not Working

**Problem**: Mod is in folder but doesn't appear in-game

**Check**:

1. **Verify mod is for server**:
   - Some mods are CLIENT-ONLY
   - Check mod page for "Server-side" or "Client-side"
   - If "Client-side only", players need it, not server

2. **Check mod loaded**:
```bash
# View loaded mods in logs
grep "Loaded" ~/minecraft/logs/latest.log
```

3. **Version mismatch**:
   - Ensure mod is for Minecraft 1.21
   - Ensure mod is for Forge (not Fabric)

### Performance Issues After Adding Mods

**Problem**: Server is laggy with mods

**Solutions**:

1. **Increase RAM allocation**:
```bash
nano ~/minecraft/start.sh
# Change -Xmx3G to -Xmx6G
# Requires larger EC2 instance (t3.large)
```

2. **Add performance mods**:
   - AI Improvements
   - Clumps
   - Chunk Pregenerator

3. **Reduce view distance**:
```bash
nano ~/minecraft/server.properties
# Change: view-distance=6
```

4. **Remove heavy mods**:
   - Large biome mods
   - Mods with many entities
   - Graphics-heavy mods

### Players Can't Connect After Mods

**Problem**: Players get kicked when connecting

**Solutions**:

1. **Ensure players have same mods**:
   - Share your mod list
   - Players need client-side mods
   - Use a modpack (see below)

2. **Check mod compatibility**:
   - Server mods don't require client mods
   - But some mods need to be on both

### Finding Which Mod Causes Issues

**Binary search method**:

1. Remove HALF of your mods
2. Restart server
3. If issue persists: Problem is in remaining half
4. If issue gone: Problem is in removed half
5. Repeat until you find the problematic mod

**Example**:
```
10 mods total
Remove 5 → Still crashes
Remove 2 more of remaining 5 → Works!
Add back 1 → Works
Add back 1 more → Crashes! ← Found the problem mod
```

---

## Creating Mod Packs

Make it easy for players to join with all mods!

### Using CurseForge App

1. **Create modpack**:
   - Download CurseForge App
   - Create new profile
   - Add your mods
   - Export as modpack

2. **Share with players**:
   - Upload `.zip` to Google Drive/Dropbox
   - Share link
   - Players import into CurseForge App

### Manual Modpack

1. **Create folder structure**:
```
MyChristmasModpack/
├── mods/
│   ├── mod1.jar
│   ├── mod2.jar
│   └── ...
├── config/ (optional)
└── README.txt
```

2. **Write README.txt**:
```
Christmas Minecraft Server Modpack
===================================

Installation:
1. Install Minecraft 1.21
2. Install Forge 1.21-51.0.33
3. Copy 'mods' folder to .minecraft/
4. Launch Minecraft with Forge profile
5. Connect to SERVER-IP:25565

Mod List:
- Fairy Lights
- Just Enough Items
- ... (list all mods)
```

3. **Zip and share**:
```bash
zip -r ChristmasModpack.zip MyChristmasModpack/
```

### Creating Manifest

Create `modlist.txt` for easy reference:

```bash
# On server
cd ~/minecraft/mods
ls -1 *.jar > ../modlist.txt
cat ../modlist.txt
```

Share this with players so they know what to install.

---

## Client-Side vs Server-Side Mods

### Server-Side Only
These mods ONLY need to be on the server:

- AI Improvements (performance)
- Clumps (performance)
- Some admin/utility mods

**Players don't need to install these!**

### Client-Side Only
These mods ONLY need to be on the player's client:

- OptiFine (graphics)
- Shaders
- MiniMap mods
- Some UI mods

**Don't install these on the server!**

### Both Sides Required
These mods need to be on BOTH server AND client:

- Biomes O' Plenty
- The Twilight Forest
- Most content mods (new items/blocks/mobs)

**Players must install these to connect!**

### How to Tell

Check the mod page:
- Look for "Environment" or "Side" label
- Read the description
- If unsure, install on both

---

## Advanced: Mod Configuration

### Editing Configs via GUI

1. **Crafty GUI** → **Files** → **config** folder
2. **Find mod config** (usually `modname.toml` or `.cfg`)
3. **Click to edit** in web editor
4. **Save** and **restart server**

### Editing Configs via Command Line

```bash
# SSH into server
ssh -i your-key.pem ubuntu@YOUR-IP

# Navigate to configs
cd ~/minecraft/config

# Edit config (example: JourneyMap)
nano journeymap-server.toml

# Save: Ctrl+X, Y, Enter

# Restart
sudo systemctl restart minecraft
```

### Common Config Changes

**Increase spawn rates**:
```toml
# config/forge-common.toml
[general]
    spawnRate = 2.0
```

**Change difficulty**:
```properties
# server.properties
difficulty=hard
```

**Customize mod features**:
```toml
# Example: config/waystones-server.toml
[waystones]
    teleportCost = 0  # Free teleports!
```

---

## Mod Update Best Practices

### Updating Mods

1. **Backup first**!
```bash
cp -r ~/minecraft/mods ~/minecraft/mods-backup-$(date +%Y%m%d)
```

2. **Download new version** of mod

3. **Remove old version**:
```bash
rm ~/minecraft/mods/old-mod-version.jar
```

4. **Add new version**:
```bash
# Upload via SCP or GUI
```

5. **Test on backup server first** (if possible)

6. **Restart and test**

### Automatic Update Checking

Create a script to check for updates:

```bash
# ~/check-mod-updates.sh
#!/bin/bash

echo "Installed mods:"
ls -1 ~/minecraft/mods/*.jar | sed 's/.*\///'

echo ""
echo "Check for updates at:"
echo "https://www.curseforge.com/minecraft/mc-mods"
echo "https://modrinth.com/mods"
```

---

## Summary

### Quick Reference

**Add mod via GUI**:
1. Download `.jar`
2. Crafty → Files → mods → Upload
3. Restart server

**Add mod via terminal**:
```bash
scp -i key.pem mod.jar ubuntu@IP:~/minecraft/mods/
ssh -i key.pem ubuntu@IP
sudo systemctl restart minecraft
```

**Remove mod**:
```bash
rm ~/minecraft/mods/mod-name.jar
sudo systemctl restart minecraft
```

**Check loaded mods**:
```bash
grep "Loaded" ~/minecraft/logs/latest.log
```

### Modding is Easy!

With the GUI and these instructions, modding your server is as simple as:
1. **Download**
2. **Upload**
3. **Restart**

Have fun customizing your Christmas server! 🎄

---

## Support

**Mod not working?**
- Check mod page for known issues
- Join mod Discord server
- Check our troubleshooting section

**Need mod recommendations?**
- Browse CurseForge categories
- Check "Most Downloaded" mods
- Ask in Minecraft forums

**Performance problems?**
- See AWS_OPTIMIZATION.md
- Consider upgrading instance
- Remove heavy mods

Happy modding! 🎮

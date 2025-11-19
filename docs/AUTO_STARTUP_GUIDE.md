# Auto-Startup Setup Guide

This guide will help you set up automatic server startup when players try to connect. This is the magic that makes your server cost-effective!

## How It Works

```
Player tries to connect
       ↓
Hits API Gateway
       ↓
Triggers Lambda Function
       ↓
Starts EC2 Instance
       ↓
Player connects to server
```

The server automatically shuts down after 10 minutes of inactivity, and automatically starts when someone tries to join!

---

## Prerequisites

- EC2 instance running (created in main setup)
- AWS CLI configured (optional, can use console)
- Basic understanding of AWS IAM

---

## Setup Steps

### Step 1: Create IAM Role for Lambda

1. **Go to AWS Console** → **IAM** → **Roles** → **Create Role**

2. **Select trusted entity**:
   - Choose: **AWS Service**
   - Use case: **Lambda**
   - Click **Next**

3. **Add permissions**:
   - Click **Create Policy** (opens new tab)
   - Select **JSON** tab
   - Paste this policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
```

   - Click **Next**
   - Name: `MinecraftServerStartPolicy`
   - Click **Create Policy**

4. **Back to role creation**:
   - Refresh policies
   - Search for `MinecraftServerStartPolicy`
   - Select it
   - Click **Next**

5. **Name and create**:
   - Role name: `MinecraftServerStartRole`
   - Click **Create Role**

---

### Step 2: Create Lambda Function

1. **Go to AWS Console** → **Lambda** → **Create Function**

2. **Configure function**:
   - Choose: **Author from scratch**
   - Function name: `minecraft-server-startup`
   - Runtime: **Python 3.12**
   - Architecture: **x86_64**
   - Execution role: **Use an existing role**
   - Select: `MinecraftServerStartRole`
   - Click **Create Function**

3. **Upload function code**:
   - In the Code source section, delete the default code
   - Copy the code from `lambda/auto-startup.py`
   - Paste it into the Lambda editor

4. **Configure environment variables**:
   - Scroll down to **Configuration** → **Environment variables**
   - Click **Edit** → **Add environment variable**
   - Add:
     - Key: `INSTANCE_ID`
     - Value: Your EC2 instance ID (e.g., `i-1234567890abcdef`)
   - Add:
     - Key: `REGION`
     - Value: Your AWS region (e.g., `us-east-1`)

5. **Update timeout**:
   - Go to **Configuration** → **General configuration**
   - Click **Edit**
   - Timeout: **2 minutes**
   - Click **Save**

6. **Test the function**:
   - Click **Test** tab
   - Create new test event
   - Event name: `test-startup`
   - Click **Save**
   - Click **Test**
   - Should see success message!

---

### Step 3: Create API Gateway

1. **In Lambda Console** → Click **Add Trigger**

2. **Select trigger**:
   - Choose: **API Gateway**
   - Intent: **Create a new API**
   - API type: **HTTP API**
   - Security: **Open** (or configure API key if you prefer)
   - Click **Add**

3. **Get API endpoint**:
   - After creation, you'll see an **API endpoint** URL
   - Copy this URL (e.g., `https://xxxxx.execute-api.us-east-1.amazonaws.com/default/minecraft-server-startup`)
   - **Save this URL!**

---

### Step 4: Test the Auto-Startup

1. **Stop your EC2 instance** manually:
```bash
aws ec2 stop-instances --instance-ids i-YOUR-INSTANCE-ID
```

Or use AWS Console → EC2 → Stop instance

2. **Trigger the Lambda**:
   - Open your API Gateway URL in a browser
   - Or use curl:
```bash
curl https://YOUR-API-GATEWAY-URL
```

3. **Verify**:
   - Should see JSON response: "Server is starting up!"
   - Check EC2 console - instance should be starting
   - Wait 1-2 minutes, then try connecting to Minecraft

---

## Method 1: DNS-Based Auto-Startup (Recommended)

This is the cleanest approach - players connect to your domain, which triggers startup if needed.

### Using Route 53 (AWS DNS)

1. **Register domain** or transfer existing domain to Route 53

2. **Create health check**:
   - Go to Route 53 → Health Checks → Create
   - Monitor: Your EC2 instance IP
   - Port: 25565
   - Name: `minecraft-health`

3. **Create failover record**:
   - Go to Hosted Zones → Your domain → Create Record
   - Record name: `minecraft` or `play`
   - Record type: A
   - Routing policy: Failover
   - Create two records:
     - **Primary**: Your Elastic IP (when server is running)
     - **Secondary**: API Gateway endpoint (triggers startup)

4. **Players connect to**: `minecraft.yourdomain.com:25565`

---

## Method 2: Scheduled Startup (Simple Alternative)

If you play at predictable times, schedule auto-startup:

1. **Go to EventBridge** → **Rules** → **Create Rule**

2. **Configure**:
   - Name: `minecraft-evening-startup`
   - Rule type: **Schedule**
   - Schedule pattern: **Cron expression**
   - Cron: `0 18 * * ? *` (6 PM daily)

3. **Select target**:
   - Target: **Lambda function**
   - Function: `minecraft-server-startup`

4. **Create rule**

Now server auto-starts at 6 PM every day!

---

## Method 3: Discord Bot Startup

Let players start the server from Discord!

### Quick Discord Bot Setup

1. **Create bot** at [Discord Developer Portal](https://discord.com/developers/applications)

2. **Install dependencies** on EC2:
```bash
pip3 install discord.py boto3
```

3. **Create bot script** (`discord-bot.py`):
```python
import discord
import boto3
import os

TOKEN = 'YOUR_DISCORD_BOT_TOKEN'
INSTANCE_ID = 'i-YOUR-INSTANCE-ID'
REGION = 'us-east-1'

intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)
ec2 = boto3.client('ec2', region_name=REGION)

@client.event
async def on_message(message):
    if message.content == '!start':
        await message.channel.send('🎄 Starting Christmas Minecraft server...')
        ec2.start_instances(InstanceIds=[INSTANCE_ID])
        await message.channel.send('✅ Server starting! Connect in 1-2 minutes!')

client.run(TOKEN)
```

4. **Run bot**:
```bash
python3 discord-bot.py
```

5. **Players type** `!start` in Discord to start server!

---

## Cost Savings Calculator

### Without Auto-Shutdown
- **t3.medium**: $0.0416/hour × 730 hours = **$30.37/month**

### With Auto-Shutdown (10 hours/week usage)
- **t3.medium**: $0.0416/hour × 40 hours = **$1.66/month**
- **Elastic IP**: $3.60/month (when not attached)
- **Total**: **~$5.26/month**

**Savings**: **$25/month** or **82% cost reduction!**

---

## Monitoring Auto-Startup

### CloudWatch Logs

View Lambda execution logs:
```bash
aws logs tail /aws/lambda/minecraft-server-startup --follow
```

Or in AWS Console: CloudWatch → Log Groups → `/aws/lambda/minecraft-server-startup`

### Set Up Alerts

Get notified when server starts:

1. **CloudWatch** → **Alarms** → **Create Alarm**
2. **Metric**: Lambda → Invocations
3. **Condition**: Greater than 0
4. **Action**: Send SNS notification to your email

---

## Troubleshooting

### Lambda Times Out

**Problem**: Function times out before instance starts

**Solution**: Increase timeout to 3 minutes:
- Lambda → Configuration → General → Timeout → 180 seconds

### Permission Denied

**Problem**: Lambda can't start instance

**Solution**: Check IAM role has EC2 permissions:
```bash
aws iam get-role-policy --role-name MinecraftServerStartRole --policy-name MinecraftServerStartPolicy
```

### Instance Doesn't Start

**Problem**: API returns success but instance stays stopped

**Solution**: Check CloudWatch logs for errors:
```bash
aws logs tail /aws/lambda/minecraft-server-startup --follow
```

### Players Can't Connect After Startup

**Problem**: Players connect too soon, before Minecraft starts

**Solution**:
- Increase wait time in Lambda (already set to 2 min)
- Tell players to wait 2 minutes after API call
- Set up Route 53 health check (Method 1 above)

---

## Advanced: Custom Status Page

Create a simple status page players can check:

1. **Create S3 bucket** for static website
2. **Create `index.html`**:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Christmas Minecraft Server Status</title>
    <script>
        async function checkStatus() {
            const response = await fetch('YOUR-API-GATEWAY-URL');
            const data = await response.json();
            document.getElementById('status').innerHTML =
                `Status: ${data.status}<br>Message: ${data.message}`;
        }
        checkStatus();
        setInterval(checkStatus, 30000); // Check every 30 seconds
    </script>
</head>
<body>
    <h1>🎄 Christmas Minecraft Server</h1>
    <div id="status">Checking status...</div>
    <button onclick="checkStatus()">Refresh</button>
</body>
</html>
```

3. **Enable static website hosting** on S3 bucket
4. **Share URL** with players!

---

## Security Considerations

### API Key Protection (Optional)

Add API key requirement:

1. **API Gateway** → **Your API** → **API Keys**
2. **Create API Key**
3. **Usage Plans** → Create plan → Add API key
4. **Update API** to require key

Players must include key in header:
```bash
curl -H "x-api-key: YOUR-KEY" https://YOUR-API-URL
```

### IP Whitelisting

Restrict Lambda to only your IP:

1. **Lambda** → **Configuration** → **VPC**
2. **Configure VPC** with security groups
3. **Add inbound rules** for your IP only

---

## Alternative: Using AWS CLI

Start server directly from terminal:

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure
aws configure

# Start server
aws ec2 start-instances --instance-ids i-YOUR-INSTANCE-ID

# Check status
aws ec2 describe-instances --instance-ids i-YOUR-INSTANCE-ID --query 'Reservations[0].Instances[0].State.Name'
```

Create alias for easy startup:
```bash
echo "alias mcstart='aws ec2 start-instances --instance-ids i-YOUR-INSTANCE-ID'" >> ~/.bashrc
source ~/.bashrc

# Now just type:
mcstart
```

---

## Summary

You now have automatic server startup! Choose the method that works best for you:

- **Method 1 (DNS)**: Most professional, seamless for players
- **Method 2 (Scheduled)**: Simple, great for predictable play times
- **Method 3 (Discord)**: Fun, community-driven approach

Combined with auto-shutdown, you'll save **80%+ on hosting costs** while maintaining a great player experience!

🎄 **Happy holidays and happy gaming!** 🎄

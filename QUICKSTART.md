# ProXDefend XDR Quick Start Guide

This guide will help you quickly set up and start using ProXDefend XDR.

## 1. Server Setup (10-15 minutes)

### Prerequisites
- Python 3.8 or higher
- MongoDB 4.4 or higher
- OpenSSL

### Installation Options

#### Option 1: One-line Installation (Recommended)
```bash
curl -sSL https://get.proxdefend.com | sudo bash -s -- --component server
```

#### Option 2: Manual Installation
1. Clone repository:
```bash
git clone https://github.com/your-org/proxdefend.git
cd proxdefend
```

2. Install server:
```bash
# Basic installation
python setup.py --component server

# Skip systemd service creation (for custom service management)
python setup.py --component server --no-systemd
```

### Post-Installation Steps

1. Configure MongoDB (if not already set up):
```bash
# Start MongoDB
sudo systemctl start mongodb
sudo systemctl enable mongodb

# Verify MongoDB is running
sudo systemctl status mongodb
```

2. Configure SSL certificates (if using custom certs):
```bash
# Place your certificates in
/etc/proxdefend/certs/server.crt
/etc/proxdefend/certs/server.key

# Set proper permissions
sudo chmod 600 /etc/proxdefend/certs/server.key
sudo chmod 644 /etc/proxdefend/certs/server.crt
```

3. Update server configuration (optional):
```bash
sudo vim /etc/proxdefend/server_config.yaml
# Modify settings as needed
```

### Start and Enable Server

1. Start the service:
```bash
sudo systemctl start proxdefend-server
```

2. Enable auto-start on boot:
```bash
sudo systemctl enable proxdefend-server
```

3. Verify service status:
```bash
sudo systemctl status proxdefend-server
```

### Verify Installation

1. Check server health:
```bash
curl https://localhost:8443/health
# Should return: {"status": "healthy", "version": "1.0.0", ...}
```

2. Check server logs:
```bash
sudo journalctl -u proxdefend-server -f
```

3. Test API access:
```bash
# Get authentication token
curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"username": "admin", "password": "proxdefend"}' \
     https://localhost:8443/api/v1/auth/login

# Use token to test API
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://localhost:8443/api/v1/server/status
```

### Troubleshooting Server Installation

1. Permission issues:
```bash
# Check ownership and permissions
sudo ls -l /etc/proxdefend/
sudo ls -l /var/log/proxdefend/
sudo ls -l /var/lib/proxdefend/

# Fix if needed
sudo chown -R proxdefend:proxdefend /etc/proxdefend/
sudo chmod 750 /etc/proxdefend/
```

2. Service won't start:
```bash
# Check detailed service status
sudo systemctl status proxdefend-server -l

# Check journal logs
sudo journalctl -u proxdefend-server -n 100 --no-pager
```

3. MongoDB connection issues:
```bash
# Verify MongoDB is running
sudo systemctl status mongodb

# Check MongoDB logs
sudo tail -f /var/log/mongodb/mongodb.log
```

4. SSL certificate issues:
```bash
# Verify certificate validity
openssl x509 -in /etc/proxdefend/certs/server.crt -text -noout

# Check certificate permissions
ls -l /etc/proxdefend/certs/
```

## 2. Agent Setup (3 minutes per system)

### Windows
1. Download installer:
   ```powershell
   Invoke-WebRequest -Uri "https://get.proxdefend.com/agent/windows" -OutFile "proxdefend-agent.exe"
   ```

2. Install:
   ```powershell
   .\proxdefend-agent.exe --server https://your-xdr-server:8443
   ```

### Unix/Linux
```bash
curl -sSL https://get.proxdefend.com/agent/unix | sudo bash -s -- --server https://your-xdr-server:8443
```

### Verify Agent
```bash
# Windows
sc query ProXDefendAgent

# Unix
systemctl status proxdefend-agent
```

## 3. Web Dashboard (2 minutes)

1. Access dashboard:
   ```
   https://your-xdr-server:3000
   ```

2. Default credentials:
   ```
   Username: admin
   Password: proxdefend
   ```

3. Change password immediately after first login

## 4. First Steps

### 1. View Security Alerts
- Click "Security Alerts" in the dashboard
- Review any existing alerts
- Test alert generation:
  ```bash
  # On agent system
  nc -l 4444  # This should trigger a suspicious port alert
  ```

### 2. Monitor Systems
- Click "System Monitoring"
- View connected agents
- Check system metrics
- Review process activity

### 3. Configure Policies
1. Go to Settings > Policies
2. Enable basic policies:
   - Process monitoring
   - Network monitoring
   - File integrity monitoring

### 4. Test Response Actions
1. Select an agent
2. Click "Actions"
3. Try:
   - Get system info
   - List processes
   - Get file contents

## 5. Common Operations

### View Agent Status
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://your-xdr-server:8443/api/v1/agents
```

### Get Recent Alerts
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://your-xdr-server:8443/api/v1/alerts?hours=24
```

### Isolate Compromised System
```bash
curl -X POST \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"action": "isolate"}' \
     https://your-xdr-server:8443/api/v1/response/AGENT_ID
```

## 6. Troubleshooting

### Server Issues
Check logs:
```bash
sudo journalctl -u proxdefend-server -f
```

### Agent Issues
Check logs:
```bash
# Windows
type "C:\Program Files\ProXDefend\logs\agent.log"

# Unix
tail -f /var/log/proxdefend/agent.log
```

### Common Problems

1. Agent won't connect:
   - Check network connectivity
   - Verify SSL certificates
   - Check firewall rules

2. Missing alerts:
   - Verify agent is running
   - Check alert thresholds
   - Review monitoring policies

3. Dashboard access issues:
   - Clear browser cache
   - Check CORS settings
   - Verify API endpoint configuration

## 7. Next Steps

1. Configure additional monitoring:
   - Custom file paths
   - Process blacklists/whitelists
   - Network rules

2. Set up integrations:
   - Email notifications
   - SIEM integration
   - Ticketing system

3. Review security documentation:
   - Hardening guide
   - Best practices
   - Compliance requirements

## Support

- Documentation: https://docs.proxdefend.com
- Community: https://community.proxdefend.com
- Email: support@proxdefend.com

For urgent issues:
```bash
proxdefend-support diagnose > support.zip
# Send support.zip to support@proxdefend.com

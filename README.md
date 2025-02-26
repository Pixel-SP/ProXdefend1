# ProXDefend XDR

ProXDefend XDR is a comprehensive security monitoring and response platform that provides:

- Real-time system monitoring
- Security event detection and correlation
- Automated threat response
- Cross-platform agent support (Windows and Unix)
- Centralized management and reporting

## Architecture

The system consists of three main components:

1. **XDR Server**: Central management server that:
   - Receives and processes security events
   - Performs event correlation and threat detection
   - Manages agents and policies
   - Provides REST API for integration

2. **Agents**: Lightweight monitoring agents for Windows and Unix systems that:
   - Monitor system activity (processes, files, network, etc.)
   - Detect security events
   - Execute response actions
   - Communicate securely with XDR server

3. **Web Interface**: Modern web dashboard that provides:
   - Real-time security alerts
   - System monitoring
   - Threat analytics
   - Agent management

## Prerequisites

- Python 3.8 or higher
- MongoDB 4.4 or higher
- Node.js 14 or higher (for web interface)
- OpenSSL for certificate generation
- System requirements:
  - Server: 4 CPU cores, 8GB RAM, 100GB storage
  - Agents: 2 CPU cores, 4GB RAM, 20GB storage

### Additional Requirements

#### Windows Agent:
- Windows 7/Server 2012 R2 or higher
- Administrator privileges
- Python for Windows
- Visual C++ Build Tools

#### Unix Agent:
- Linux kernel 3.10 or higher
- Root privileges
- Python development headers
- Build tools (gcc, make)

## Installation

### Server Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/proxdefend.git
   cd proxdefend
   ```

2. Install MongoDB:
   ```bash
   # Ubuntu/Debian
   sudo apt install mongodb

   # CentOS/RHEL
   sudo yum install mongodb-org
   ```

3. Run the server setup:
   ```bash
   python setup.py --component server
   ```

4. Start the server:
   ```bash
   # Using systemd
   sudo systemctl start proxdefend-server

   # Manual start
   python server/xdr_server.py
   ```

### Agent Setup

1. Copy agent files to target system:
   ```bash
   # Windows
   copy agent/windows/* C:\Program Files\ProXDefend\

   # Unix
   cp -r agent/unix/* /opt/proxdefend/
   ```

2. Run agent setup:
   ```bash
   python setup.py --component agent
   ```

3. Start the agent:
   ```bash
   # Windows (as service)
   net start ProXDefendAgent

   # Unix (using systemd)
   sudo systemctl start proxdefend-agent
   ```

### Web Interface Setup

1. Install dependencies:
   ```bash
   cd frontend
   npm install
   ```

2. Configure environment:
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

3. Start development server:
   ```bash
   npm run dev
   ```

4. Build for production:
   ```bash
   npm run build
   ```

## Configuration

### Server Configuration

Edit `server/config/server_config.yaml`:
```yaml
server:
  host: '0.0.0.0'
  port: 8443
  ssl_cert: 'certs/server.crt'
  ssl_key: 'certs/server.key'

database:
  uri: 'mongodb://localhost:27017'
  name: 'proxdefend_xdr'
```

### Agent Configuration

Edit agent configuration in the respective platform directory:
```bash
# Windows
C:\Program Files\ProXDefend\config.yaml

# Unix
/opt/proxdefend/config.yaml
```

## Usage

### Managing Agents

1. Register new agent:
   ```bash
   curl -X POST https://xdr-server:8443/api/v1/agent/register \
        -H "Content-Type: application/json" \
        -d '{"system_info": {...}}'
   ```

2. List agents:
   ```bash
   curl https://xdr-server:8443/api/v1/agents
   ```

3. Get agent details:
   ```bash
   curl https://xdr-server:8443/api/v1/agents/{agent_id}
   ```

### Viewing Alerts

1. Access web interface:
   ```
   https://xdr-server:3000
   ```

2. API access:
   ```bash
   curl https://xdr-server:8443/api/v1/alerts
   ```

### Response Actions

1. Isolate system:
   ```bash
   curl -X POST https://xdr-server:8443/api/v1/response/{agent_id} \
        -H "Content-Type: application/json" \
        -d '{"action": "isolate"}'
   ```

2. Kill process:
   ```bash
   curl -X POST https://xdr-server:8443/api/v1/response/{agent_id} \
        -H "Content-Type: application/json" \
        -d '{"action": "kill_process", "params": {"pid": 1234}}'
   ```

## Development

### Running Tests

```bash
# Server tests
cd server
pytest

# Agent tests
cd agent
pytest
```

### Code Style

```bash
# Format code
black .

# Check style
flake8

# Type checking
mypy .
```

## Security

- All communication is encrypted using TLS 1.3
- Agents authenticate using JWT tokens
- File integrity monitoring enabled by default
- Regular security updates provided

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please:
1. Check the documentation
2. Search existing issues
3. Open a new issue if needed

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

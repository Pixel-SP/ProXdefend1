#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: Please run as root${NC}"
    exit 1
fi

# Function to print status
print_status() {
    echo -e "${GREEN}[*]${NC} $1"
}

# Function to print error
print_error() {
    echo -e "${RED}[!] Error:${NC} $1"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}[!] Warning:${NC} $1"
}

# Check Python version
check_python() {
    print_status "Checking Python version..."
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed"
        exit 1
    fi
    
    python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    if (( $(echo "$python_version < 3.8" | bc -l) )); then
        print_error "Python 3.8 or higher is required (found $python_version)"
        exit 1
    fi
}

# Install system dependencies
install_dependencies() {
    print_status "Installing system dependencies..."
    
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        apt-get update
        apt-get install -y python3-dev python3-pip mongodb nodejs npm build-essential
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL
        yum install -y python3-devel python3-pip mongodb-org nodejs gcc gcc-c++ make
    else
        print_error "Unsupported distribution"
        exit 1
    fi
    
    # Install Python dependencies
    pip3 install -r requirements.txt
}

# Create necessary directories
create_directories() {
    print_status "Creating directories..."
    
    mkdir -p /opt/proxdefend/{bin,config,logs,data}
    mkdir -p /var/log/proxdefend
    mkdir -p /etc/proxdefend
}

# Setup server
setup_server() {
    print_status "Setting up XDR server..."
    
    # Generate SSL certificates
    if [ ! -f /etc/proxdefend/server.crt ]; then
        openssl req -x509 -newkey rsa:4096 \
            -keyout /etc/proxdefend/server.key \
            -out /etc/proxdefend/server.crt \
            -days 365 -nodes \
            -subj "/CN=proxdefend-xdr"
        
        chmod 600 /etc/proxdefend/server.key
        chmod 644 /etc/proxdefend/server.crt
    fi
    
    # Copy server files
    cp -r server/* /opt/proxdefend/
    cp server/config/server_config.yaml /etc/proxdefend/
    
    # Create service file
    cat > /etc/systemd/system/proxdefend-server.service << EOF
[Unit]
Description=ProXDefend XDR Server
After=network.target mongodb.service

[Service]
Type=simple
User=proxdefend
ExecStart=/usr/bin/python3 /opt/proxdefend/xdr_server.py
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF
    
    # Create user
    useradd -r -s /bin/false proxdefend
    
    # Set permissions
    chown -R proxdefend:proxdefend /opt/proxdefend
    chown -R proxdefend:proxdefend /var/log/proxdefend
    
    # Enable and start services
    systemctl daemon-reload
    systemctl enable mongodb
    systemctl enable proxdefend-server
    systemctl start mongodb
    systemctl start proxdefend-server
}

# Setup agent
setup_agent() {
    print_status "Setting up XDR agent..."
    
    # Copy agent files
    cp -r agent/unix/* /opt/proxdefend/
    
    # Create service file
    cat > /etc/systemd/system/proxdefend-agent.service << EOF
[Unit]
Description=ProXDefend Security Agent
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /opt/proxdefend/agent.py
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF
    
    # Set permissions
    chmod 700 /opt/proxdefend/agent.py
    
    # Enable and start service
    systemctl daemon-reload
    systemctl enable proxdefend-agent
    systemctl start proxdefend-agent
}

# Main setup
main() {
    print_status "Starting ProXDefend XDR setup..."
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --component)
                COMPONENT="$2"
                shift 2
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    if [ -z "$COMPONENT" ]; then
        print_error "Please specify component (--component server|agent)"
        exit 1
    fi
    
    # Run setup steps
    check_python
    install_dependencies
    create_directories
    
    case $COMPONENT in
        server)
            setup_server
            ;;
        agent)
            setup_agent
            ;;
        *)
            print_error "Invalid component: $COMPONENT"
            exit 1
            ;;
    esac
    
    print_status "Setup completed successfully!"
}

# Run main function with all arguments
main "$@"

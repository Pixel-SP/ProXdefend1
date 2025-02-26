import os
import sys
import platform
import subprocess
import argparse
import logging
from pathlib import Path
from setuptools import setup, find_packages

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('ProXDefend-Setup')

def check_python_version():
    """Check if Python version is compatible"""
    if sys.version_info < (3, 8):
        logger.error("Python 3.8 or higher is required")
        sys.exit(1)

def create_directories():
    """Create necessary directories"""
    dirs = [
        'logs',
        'config',
        'certs',
        'data'
    ]
    
    for dir_name in dirs:
        Path(dir_name).mkdir(parents=True, exist_ok=True)
        logger.info(f"Created directory: {dir_name}")

def install_dependencies():
    """Install required packages"""
    try:
        # Upgrade pip
        subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade", "pip"])
        
        # Install requirements
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        logger.info("Dependencies installed successfully")
        
    except subprocess.CalledProcessError as e:
        logger.error(f"Error installing dependencies: {e}")
        sys.exit(1)

def setup_agent():
    """Setup agent based on platform"""
    system = platform.system().lower()
    
    if system == "windows":
        setup_windows_agent()
    elif system in ["linux", "darwin"]:
        setup_unix_agent()
    else:
        logger.error(f"Unsupported platform: {system}")
        sys.exit(1)

def setup_windows_agent():
    """Setup Windows agent"""
    try:
        # Create service
        service_path = os.path.abspath("agent/windows/agent.py")
        subprocess.check_call([
            "sc", "create", "ProXDefendAgent",
            "binPath=", f'"{sys.executable} {service_path}"',
            "start=", "auto",
            "DisplayName=", "ProXDefend Security Agent"
        ])
        
        # Set recovery options
        subprocess.check_call([
            "sc", "failure", "ProXDefendAgent",
            "reset=", "0",
            "actions=", "restart/60000/restart/60000/restart/60000"
        ])
        
        logger.info("Windows agent service created successfully")
        
    except subprocess.CalledProcessError as e:
        logger.error(f"Error setting up Windows agent: {e}")
        sys.exit(1)

def setup_unix_agent():
    """Setup Unix agent"""
    try:
        # Create systemd service file
        service_content = f"""[Unit]
Description=ProXDefend Security Agent
After=network.target

[Service]
Type=simple
User=root
ExecStart={sys.executable} {os.path.abspath("agent/unix/agent.py")}
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
"""
        
        service_path = "/etc/systemd/system/proxdefend-agent.service"
        with open(service_path, "w") as f:
            f.write(service_content)
            
        # Reload systemd and enable service
        subprocess.check_call(["systemctl", "daemon-reload"])
        subprocess.check_call(["systemctl", "enable", "proxdefend-agent"])
        
        logger.info("Unix agent service created successfully")
        
    except Exception as e:
        logger.error(f"Error setting up Unix agent: {e}")
        sys.exit(1)

def setup_server():
    """Setup XDR server"""
    try:
        # Run the dedicated server installation script
        server_install_script = os.path.join("server", "install_server.py")
        if not os.path.exists(server_install_script):
            raise FileNotFoundError("Server installation script not found")
            
        logger.info("Running server installation script...")
        subprocess.check_call([sys.executable, server_install_script])
        
        logger.info("Server setup completed successfully")
        
    except Exception as e:
        logger.error(f"Error setting up server: {e}")
        sys.exit(1)

def main():
    """Main setup function"""
    parser = argparse.ArgumentParser(description="ProXDefend XDR Setup")
    parser.add_argument("--component", choices=["agent", "server"], required=True,
                      help="Component to install (agent or server)")
    parser.add_argument("--no-systemd", action="store_true",
                      help="Skip systemd service installation (server only)")
    args = parser.parse_args()
    
    try:
        logger.info("Starting ProXDefend setup...")
        
        # Check Python version
        check_python_version()
        
        # Create directories
        create_directories()
        
        # Install dependencies
        install_dependencies()
        
        # Setup component
        if args.component == "agent":
            setup_agent()
        else:
            # Pass no-systemd flag to server installation if specified
            if args.no_systemd:
                server_install_script = os.path.join("server", "install_server.py")
                subprocess.check_call([sys.executable, server_install_script, "--no-systemd"])
            else:
                setup_server()
            
        logger.info("Setup completed successfully")
        
    except Exception as e:
        logger.error(f"Setup failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

# Setup configuration
setup(
    name="proxdefend",
    version="1.0.0",
    packages=find_packages(),
    install_requires=[
        "flask>=2.0.0",
        "pymongo>=4.0.0",
        "pyyaml>=5.4.0",
        "requests>=2.26.0",
        "aiohttp>=3.8.0",
        "motor>=2.5.0",
        "cryptography>=3.4.0",
        "PyJWT>=2.3.0",
        "argparse>=1.4.0",
        "python-dotenv>=0.19.0"
    ],
    entry_points={
        'console_scripts': [
            'proxdefend-server=server.xdr_server:main',
        ],
    },
)

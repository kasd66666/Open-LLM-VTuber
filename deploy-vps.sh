#!/bin/bash

# VPS Deployment Script per Open-LLM-VTuber
# Compatibile con Ubuntu 20.04/22.04, Debian 11/12, CentOS 8+

set -e

echo "🚀 Deployment Open-LLM-VTuber su VPS..."

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
fi

# Install dependencies based on OS
install_dependencies() {
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        sudo apt update
        sudo apt install -y python3 python3-pip python3-venv git nginx ffmpeg curl
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        sudo yum update -y
        sudo yum install -y python3 python3-pip git nginx ffmpeg curl
    fi
}

# Create user and directories
setup_user() {
    sudo useradd -m -s /bin/bash vtuber || true
    sudo mkdir -p /opt/open-llm-vtuber
    sudo chown vtuber:vtuber /opt/open-llm-vtuber
}

# Install application
install_app() {
    cd /opt/open-llm-vtuber
    
    # Clone repository
    sudo -u vtuber git clone https://github.com/t41372/Open-LLM-VTuber.git .
    
    # Create virtual environment
    sudo -u vtuber python3 -m venv venv
    sudo -u vtuber ./venv/bin/pip install --upgrade pip
    
    # Install dependencies
    sudo -u vtuber ./venv/bin/pip install -r requirements.txt
    
    # Copy your configurations
    echo "📁 Copia le tue configurazioni..."
    # sudo cp /path/to/your/characters/* ./characters/
    # sudo cp /path/to/your/conf.yaml ./conf.yaml
    # sudo chown -R vtuber:vtuber ./characters ./conf.yaml
}

# Setup systemd service
setup_service() {
    sudo tee /etc/systemd/system/open-llm-vtuber.service > /dev/null <<EOF
[Unit]
Description=Open-LLM-VTuber AI Assistant
After=network.target

[Service]
Type=simple
User=vtuber
Group=vtuber
WorkingDirectory=/opt/open-llm-vtuber
Environment=PATH=/opt/open-llm-vtuber/venv/bin
ExecStart=/opt/open-llm-vtuber/venv/bin/python run_server.py
Restart=always
RestartSec=10

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/open-llm-vtuber

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable open-llm-vtuber
}

# Setup Nginx reverse proxy
setup_nginx() {
    sudo tee /etc/nginx/sites-available/open-llm-vtuber > /dev/null <<EOF
server {
    listen 80;
    server_name your-domain.com;  # Cambia con il tuo dominio

    location / {
        proxy_pass http://127.0.0.1:12393;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

    sudo ln -sf /etc/nginx/sites-available/open-llm-vtuber /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl restart nginx
}

# Setup firewall
setup_firewall() {
    if command -v ufw &> /dev/null; then
        sudo ufw allow 22/tcp
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        sudo ufw --force enable
    elif command -v firewall-cmd &> /dev/null; then
        sudo firewall-cmd --permanent --add-service=ssh
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --permanent --add-service=https
        sudo firewall-cmd --reload
    fi
}

# Main deployment
main() {
    echo "📦 Installing dependencies..."
    install_dependencies
    
    echo "👤 Setting up user..."
    setup_user
    
    echo "📥 Installing application..."
    install_app
    
    echo "⚙️ Setting up service..."
    setup_service
    
    echo "🌐 Setting up Nginx..."
    setup_nginx
    
    echo "🛡️ Setting up firewall..."
    setup_firewall
    
    echo "🚀 Starting services..."
    sudo systemctl start open-llm-vtuber
    sudo systemctl start nginx
    
    echo "✅ Deployment completato!"
    echo "🌐 Il tuo VTuber è disponibile su: http://$(curl -s ifconfig.me)"
    echo "📊 Controlla i logs con: sudo journalctl -u open-llm-vtuber -f"
}

main "$@"

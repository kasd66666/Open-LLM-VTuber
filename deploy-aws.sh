#!/bin/bash

# AWS EC2 Deployment Script per Open-LLM-VTuber
# Esegui questo script su una istanza EC2 Ubuntu 22.04

set -e

echo "🚀 Iniziando deployment AWS EC2..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Nginx (se non usi Docker Compose)
sudo apt install -y nginx certbot python3-certbot-nginx

# Clone repository (se non già presente)
if [ ! -d "Open-LLM-VTuber" ]; then
    git clone https://github.com/t41372/Open-LLM-VTuber.git
    cd Open-LLM-VTuber
else
    cd Open-LLM-VTuber
    git pull
fi

# Copy your custom configurations
echo "📁 Copia le tue configurazioni personalizzate..."
# cp /path/to/your/characters/* ./characters/
# cp /path/to/your/conf.yaml ./conf.yaml

# Build and start services
echo "🐳 Building Docker containers..."
docker-compose build

echo "🚀 Starting services..."
docker-compose up -d

# Setup SSL with Let's Encrypt (opzionale)
echo "🔒 Setup SSL certificate..."
# sudo certbot --nginx -d your-domain.com

# Setup firewall
echo "🛡️ Configurando firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 12393/tcp
sudo ufw --force enable

# Setup systemd service per auto-restart
echo "⚙️ Setup systemd service..."
sudo tee /etc/systemd/system/open-llm-vtuber.service > /dev/null <<EOF
[Unit]
Description=Open-LLM-VTuber
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/Open-LLM-VTuber
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable open-llm-vtuber
sudo systemctl start open-llm-vtuber

echo "✅ Deployment completato!"
echo "🌐 Il tuo VTuber è disponibile su: http://$(curl -s ifconfig.me):12393"
echo "📊 Controlla i logs con: docker-compose logs -f"

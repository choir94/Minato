#!/bin/bash

curl -s https://raw.githubusercontent.com/choir94/Airdropguide/refs/heads/main/logo.sh | bash
sleep 5

# Function to check if a package is installed
check_and_install() {
    if ! dpkg -s "$1" &> /dev/null; then
        echo -e "\033[1;33mInstalling $1...\033[0m"
        sudo apt install -y "$1"
    else
        echo -e "\033[1;32m$1 is already installed.\033[0m"
    fi
}

# Update and install necessary packages
echo -e "\033[1;34mUpdating system and installing essential packages...\033[0m"
sudo apt update && sudo apt upgrade -y
check_and_install curl
check_and_install git
check_and_install jq
check_and_install build-essential
check_and_install gcc
check_and_install unzip
check_and_install wget
check_and_install lz4

# Install Docker using the official Docker installation script
echo -e "\033[1;34mInstalling Docker...\033[0m"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | bash
    sudo usermod -aG docker "$USER"
    echo -e "\033[1;32mDocker installed and user added to Docker group. Please log out and log back in for the changes to take effect.\033[0m"
else
    echo -e "\033[1;32mDocker is already installed.\033[0m"
fi

# Check Docker version
echo -e "\033[1;34mChecking Docker version...\033[0m"
docker --version

# Install Docker Compose
echo -e "\033[1;34mInstalling Docker Compose...\033[0m"
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "\033[1;32mDocker Compose installed.\033[0m"
else
    echo -e "\033[1;32mDocker Compose is already installed.\033[0m"
fi

# Clone the Soneium repository and navigate to the minato directory
echo -e "\033[1;34mCloning Soneium repository...\033[0m"
git clone https://github.com/Soneium/soneium-node.git
cd soneium-node/minato || exit

# Generate JWT secret
echo -e "\033[1;34mGenerating JWT secret...\033[0m"
openssl rand -hex 32 > jwt.txt
echo -e "\033[1;32mJWT secret saved to jwt.txt\033[0m"

# Rename sample.env to .env
echo -e "\033[1;34mRenaming sample.env to .env...\033[0m"
mv sample.env .env

# Prompt user for RPC details
echo -e "\033[1;34mPlease enter the following RPC details:\033[0m"
read -p "L1_URL: " L1_URL
read -p "L1_BEACON: " L1_BEACON
read -p "P2P_ADVERTISE_IP: " P2P_ADVERTISE_IP

# Update .env file with RPC details
echo -e "\033[1;34mConfiguring .env file with RPC details...\033[0m"
sed -i "s|^L1_URL=.*|L1_URL=$L1_URL|" .env
sed -i "s|^L1_BEACON=.*|L1_BEACON=$L1_BEACON|" .env
sed -i "s|^P2P_ADVERTISE_IP=.*|P2P_ADVERTISE_IP=$P2P_ADVERTISE_IP|" .env

# Automatically retrieve the public IP of the VPS
NODE_PUBLIC_IP=$(curl -s https://api.ipify.org)

echo -e "\033[1;34mDetected public IP: $NODE_PUBLIC_IP\033[0m"

# Replace <your_node_public_ip> in the docker-compose.yml file with the detected public IP
echo -e "\033[1;34mConfiguring docker-compose.yml with node public IP...\033[0m"

# Replace placeholder with the detected node public IP
sed -i "s|<your_node_public_ip>|$NODE_PUBLIC_IP|" docker-compose.yml

# Start Docker Compose
echo -e "\033[1;34mStarting Docker Compose...\033[0m"
docker-compose up -d

# Check service status
echo -e "\033[1;34mChecking status of services...\033[0m"
docker-compose ps

# Tail logs for the main services
echo -e "\033[1;34mDisplaying logs for op-node-minato...\033[0m"
docker-compose logs -f op-node-minato &

echo -e "\033[1;34mDisplaying logs for op-geth-minato...\033[0m"
docker-compose logs -f op-geth-minato &

#!/bin/bash

# Function to check if a package is installed
check_and_install() {
    if ! dpkg -s "$1" &> /dev/null; then
        echo "Installing $1..."
        sudo apt install -y "$1"
    else
        echo "$1 is already installed."
    fi
}

# Update and install necessary packages
echo "Updating system and installing essential packages..."
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
echo "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | bash
    sudo usermod -aG docker "$USER"
    echo "Docker installed and user added to Docker group. Please log out and log back in for the changes to take effect."
else
    echo "Docker is already installed."
fi

# Check Docker version
echo "Checking Docker version..."
docker --version

# Install Docker Compose
echo "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose is already installed."
fi

# Clone the Soneium repository and navigate to the minato directory
echo "Cloning Soneium repository..."
git clone https://github.com/Soneium/soneium-node.git
cd soneium-node/minato || exit

# Generate JWT secret
echo "Generating JWT secret..."
openssl rand -hex 32 > jwt.txt
echo "JWT secret saved to jwt.txt"

# Rename sample.env to .env
echo "Renaming sample.env to .env..."
mv sample.env .env

# Prompt user for RPC details
echo "Please enter the following RPC details:"
read -p "L1_URL: " L1_URL
read -p "L1_BEACON: " L1_BEACON
read -p "P2P_ADVERTISE_IP: " P2P_ADVERTISE_IP

# Update .env file with RPC details
echo "Configuring .env file with RPC details..."
sed -i "s|^L1_URL=.*|L1_URL=$L1_URL|" .env
sed -i "s|^L1_BEACON=.*|L1_BEACON=$L1_BEACON|" .env
sed -i "s|^P2P_ADVERTISE_IP=.*|P2P_ADVERTISE_IP=$P2P_ADVERTISE_IP|" .env

# Automatically retrieve the public IP of the VPS
NODE_PUBLIC_IP=$(curl -s https://api.ipify.org)

echo "Detected public IP: $NODE_PUBLIC_IP"

# Replace <your_node_public_ip> in the docker-compose.yml file with the detected public IP
echo "Configuring docker-compose.yml with node public IP..."

# Replace placeholder with the detected node public IP
sed -i "s|<your_node_public_ip>|$NODE_PUBLIC_IP|" docker-compose.yml

# Start Docker Compose
echo "Starting Docker Compose..."
docker-compose up -d

# Check service status
echo "Checking status of services..."
docker-compose ps

# Tail logs for the main services
echo "Displaying logs for op-node-minato..."
docker-compose logs -f op-node-minato &

echo "Displaying logs for op-geth-minato..."
docker-compose logs -f op-geth-minato &

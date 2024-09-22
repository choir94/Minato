#!/bin/bash

# Script untuk instalasi Docker dan Docker Compose

# Memastikan script dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Update package index dan install dependencies
echo "Updating package index..."
apt-get update -y
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Menambahkan GPG key resmi Docker
echo "Adding Docker GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Menambahkan Docker repository ke APT sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index lagi setelah menambahkan repo Docker
echo "Updating package index again..."
apt-get update -y

# Install Docker Engine
echo "Installing Docker Engine..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Menambahkan user ke grup Docker
echo "Adding user to docker group..."
usermod -aG docker $USER

# Download dan install Docker Compose (jika belum terinstall)
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)

echo "Installing Docker Compose version $DOCKER_COMPOSE_VERSION..."
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Memberikan izin executable untuk Docker Compose
chmod +x /usr/local/bin/docker-compose

# Verifikasi instalasi Docker dan Docker Compose
echo "Verifying Docker and Docker Compose installation..."
docker --version
docker-compose --version

echo "Docker and Docker Compose installation completed successfully."
echo "Please log out and log back in to apply Docker group changes."


curl -s https://raw.githubusercontent.com/choir94/Airdropguide/refs/heads/main/logo.sh | bash

sleep 2
# Generate jwt.txt
openssl rand -hex 32 > jwt.txt
# Create directory
mkdir minato
cd minato
# Download and rename files
declare -A files=(
    ["minato-genesis.json"]="https://docs.soneium.org/assets/files/minato-genesis-5e5db79442a6436778e9c3c80a9fd80d.json"
    ["docker-compose.yml"]="https://docs.soneium.org/assets/files/docker-compose-003749bd470bb0677fb5b8e2a82103ed.yml"
    ["minato-rollup.json"]="https://docs.soneium.org/assets/files/minato-rollup-6d00cc672bf6c8e9c14e3244e36a2790.json"
    ["sample.env"]="https://docs.soneium.org/assets/files/sample-4ab2cad1f36b3166b45ce4d8fed821ab.env"
)

for file in "${!files[@]}"; do
    wget -q "${files[$file]}" -O "${file}"
done

# Rename sample.env
cp sample.env .env
nano .env

# Backup original files
mkdir -p org-file
mv sample.env org-file/sample.env
cp minato-genesis.json org-file/org-minato-genesis.json
cp docker-compose.yml org-file/org-docker-compose.yml
cp minato-rollup.json org-file/org-minato-rollup.json

echo -e "${BOLD_PINK} Join airdrop node t.me/airdrop_node ${RESET_COLOR}"

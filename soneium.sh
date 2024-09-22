#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install required packages
echo "Installing ca-certificates and curl..."
sudo apt-get install -y ca-certificates curl

# Create the keyrings directory
echo "Creating /etc/apt/keyrings directory..."
sudo install -m 0755 -d /etc/apt/keyrings

# Download the Docker GPG key
echo "Downloading Docker GPG key..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Add read permission to the GPG key
echo "Setting permissions for Docker GPG key..."
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources
echo "Adding Docker repository to Apt sources..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list again
echo "Updating package list again..."
sudo apt-get update

# Install Docker packages
echo "Installing Docker packages..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install docker-compose-plugin explicitly (optional if already installed)
echo "Installing docker-compose-plugin..."
sudo apt-get install -y docker-compose-plugin

# Display Docker Compose version
echo "Checking Docker Compose version..."
docker compose version

curl -s https://raw.githubusercontent.com/choir94/Airdropguide/refs/heads/main/logo.sh | bash

sleep 2

# Generate a 32-byte hexadecimal string and save to jwt.txt
echo "Generating a 32-byte hex string and saving to jwt.txt..."
openssl rand -hex 32 > jwt.txt

# Display the generated JWT key
echo "Generated JWT key:"
cat jwt.txt

# Create the minato folder
echo "Creating the minato directory..."
mkdir -p minato

# Download and rename files into minato
echo "Downloading and renaming files..."
declare -A files=(
    ["minato/minato-genesis.json"]="https://docs.soneium.org/assets/files/minato-genesis-5e5db79442a6436778e9c3c80a9fd80d.json"
    ["minato/docker-compose.yml"]="https://docs.soneium.org/assets/files/docker-compose-003749bd470bb0677fb5b8e2a82103ed.yml"
    ["minato/minato-rollup.json"]="https://docs.soneium.org/assets/files/minato-rollup-6d00cc672bf6c8e9c14e3244e36a2790.json"
    ["minato/sample.env"]="https://docs.soneium.org/assets/files/sample-4ab2cad1f36b3166b45ce4d8fed821ab.env"
)

for file in "${!files[@]}"; do
    wget -q "${files[$file]}" -O "${file}"
done

# Rename sample.env to .env in the minato directory
echo "Renaming sample.env to .env in minato directory..."
cp minato/sample.env minato/.env

# Backup original files
echo "Backing up original files..."
mkdir -p org-file
mv minato/sample.env org-file/sample.env
cp minato/minato-genesis.json org-file/org-minato-genesis.json
cp minato/docker-compose.yml org-file/org-docker-compose.yml
cp minato/minato-rollup.json org-file/org-minato-rollup.json

# Navigate to the minato directory
echo "Navigating to the minato directory..."
cd minato

# Script complete
echo "All steps completed successfully!"
# Provide the link to join the Airdrop Node discussion
echo "Join the Airdrop Node discussion: https://t.me/airdrop_node"

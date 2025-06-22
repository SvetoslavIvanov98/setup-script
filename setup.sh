#!/bin/bash
set -euo pipefail

# === User-friendly Setup Script ===
# This script sets up a development environment on Ubuntu 22.04+.
# Run as: bash setup.sh
# Requirements: sudo privileges, internet connection.

# --- OS Check ---
if ! grep -qi ubuntu /etc/os-release; then
    echo "This script is intended for Ubuntu. Exiting."
    exit 1
fi

# --- Confirm with User ---
echo "This script will install many packages and tools (Docker, Brave, Rust, etc)."
read -rp "Continue? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# --- Update and install core packages ---
sudo apt update
sudo apt install -y \
    python3 python3-venv python3-pip \
    curl git make nodejs npm fastfetch flatpak ca-certificates ripgrep neovim
    
if dpkg -l | grep -q '^ii  rustc '; then
    sudo apt remove -y rustc
fi

# --- Ensure pip is available ---
if ! command -v pip3 >/dev/null 2>&1; then
    echo "pip3 not found, attempting to install..."
    sudo apt install -y python3-pip
fi

# --- Install snap packages ---
for snap in alacritty code termius-app; do
    sudo snap install "$snap" --classic || true
done

# --- Add Docker's official GPG key and repo ---
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Add Flathub repository if not present ---
if ! flatpak remote-list | grep -q flathub; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# --- Install Flatpak apps ---
flatpak_apps=(
    com.discordapp.Discord
    be.alexandervanhee.gradia
    com.rustdesk.RustDesk
)
for app in "${flatpak_apps[@]}"; do
    sudo flatpak install -y flathub "$app" || true
done

# --- Install Brave browser ---
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
    sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install -y brave-browser

# --- Install Rust (non-interactive) ---
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Add Cargo to PATH for this script run
source "$HOME/.cargo/env"

# --- Install lazygit ---
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
rm -f lazygit lazygit.tar.gz

# --- Create and activate venv for LunarVim ---
python3 -m venv ~/.local/share/lunarvim-venv
source ~/.local/share/lunarvim-venv/bin/activate
pip install --upgrade pip

# --- Install LunarVim ---
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)

deactivate

# --- Setup custom bash ---
if [ ! -d mybash ]; then
    git clone --depth=1 https://github.com/dacrab/mybash.git
fi
cd mybash
./setup.sh || true
cd ..

# --- Install Ollama and run models (optional, large downloads) ---
read -rp "Do you want to install Ollama and download large models? [y/N]: " OLLAMA_CONFIRM
if [[ "$OLLAMA_CONFIRM" =~ ^[Yy]$ ]]; then
    curl -fsSL https://ollama.com/install.sh | sh
    ollama run deepseek-r1:14b || true
    ollama run gemma3:12b || true
    ollama run codegemma:7b || true
fi

# --- Install NVIDIA Container Toolkit (optional, for NVIDIA GPUs) ---
read -rp "Do you want to install NVIDIA Container Toolkit? [y/N]: " NVIDIA_CONFIRM
if [[ "$NVIDIA_CONFIRM" =~ ^[Yy]$ ]]; then
    sudo curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
        sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
fi

# --- Run Open WebUI container (optional) ---
read -rp "Do you want to run the Open WebUI Docker container? [y/N]: " WEBUI_CONFIRM
if [[ "$WEBUI_CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Which Open WebUI image do you want to use?"
    echo "  1) CUDA (GPU support, for NVIDIA GPUs)"
    echo "  2) Main (CPU only, more compatible)"
    read -rp "Enter 1 or 2 [1]: " WEBUI_IMAGE_CHOICE
    WEBUI_IMAGE_CHOICE=${WEBUI_IMAGE_CHOICE:-1}
    if [[ "$WEBUI_IMAGE_CHOICE" == "2" ]]; then
        WEBUI_IMAGE="ghcr.io/open-webui/open-webui:main"
    else
        WEBUI_IMAGE="ghcr.io/open-webui/open-webui:cuda"
    fi
    sudo docker run -d --network=host \
        -v open-webui:/app/backend/data \
        -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
        --name open-webui \
        --restart always \
        "$WEBUI_IMAGE"
fi

echo "Setup complete!"
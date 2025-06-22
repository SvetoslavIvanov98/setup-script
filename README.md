# Ubuntu Development Environment Setup Script

This repository provides an easy-to-use Bash script to set up a comprehensive development environment on **Ubuntu 22.04+**. It installs essential tools, programming languages, Docker, editors, and optional AI/model tools, making it ideal for developers who want a ready-to-use workstation.

## Features

- **Core Packages:** Python, Rust, Node.js, Git, and more
- **Editors & Terminals:** VS Code, Alacritty, LunarVim, custom Bash setup
- **Docker & NVIDIA Toolkit:** Full Docker support, optional NVIDIA GPU integration
- **Browsers:** Brave browser installation
- **Flatpak & Snap Apps:** Popular apps like Discord, Neovim, and more
- **AI Tools:** Optional installation of Ollama and large language models
- **Open WebUI:** Optional web interface for AI models, with choice of CUDA (GPU) or Main (CPU) image

## Prerequisites

- Ubuntu 22.04 or newer
- Internet connection
- Sudo privileges

## Usage

1. **Run with one command (no clone needed):**
    ```sh
    curl -fsSL https://raw.githubusercontent.com/SvetoslavIvanov98/setup-script/main/setup.sh -o setup.sh
    chmod +x setup.sh
    ./setup.sh
    ```

2. **Or clone this repository and run manually:**
    ```sh
    git clone https://github.com/SvetoslavIvanov98/setup-script.git
    cd setup-script
    bash setup.sh
    ```

3. **Follow the prompts:**  
   The script will ask for confirmation before installing major components and optional tools (Ollama, NVIDIA toolkit, Open WebUI).  
   When running Open WebUI, you can now choose between the CUDA (GPU support) or Main (CPU only)

## What Gets Installed

- **Core Tools:** `python3`, `rustc`, `curl`, `git`, `make`, `nodejs`, `npm`, `fastfetch`, `flatpak`, `ca-certificates`, `ripgrep`
- **Snap Apps:** `alacritty`, `code` (VS Code), `termius-app`
- **Flatpak Apps:** Discord, Gradia, RustDesk, Komikku, Neovim, Kdenlive, RetroArch
- **Brave Browser**
- **Docker Engine & Compose**
- **Lazygit**
- **LunarVim**
- **Custom Bash Environment** ([dacrab/mybash](https://github.com/dacrab/mybash))
- **Optional:**  
  - **Ollama** and large models (DeepSeek, Gemma, CodeGemma)
  - **NVIDIA Container Toolkit** (for NVIDIA GPUs)
  - **Open WebUI** Docker container  
    - **Choice of image:**  
      - `CUDA` (GPU support, for NVIDIA GPUs)  
      - `Main` (CPU only, more compatible)

## Notes

- The script is **idempotent**: you can safely re-run it.
- Some installations (Ollama models, NVIDIA toolkit, Open WebUI) are optional and may require large downloads.
- The script is intended for **personal workstations** and may install software globally.

## Troubleshooting

- If you encounter issues, check the output for errors.
- Ensure you have a stable internet connection.
- For NVIDIA GPU support, ensure your drivers are up to date.

## License

This script is provided as-is, without warranty.  
Feel free to modify and adapt it for your own use.

---
**Happy hacking!**
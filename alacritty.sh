#!/bin/sh

setupAlacrittyConfig() {
    printf "%b\n" "${YELLOW}Copying alacritty config files...${RC}"
    if [ -d "${HOME}/.config/alacritty" ] && [ ! -d "${HOME}/.config/alacritty-bak" ]; then
        cp -r "${HOME}/.config/alacritty" "${HOME}/.config/alacritty-bak"
    fi
    mkdir -p "${HOME}/.config/alacritty/"
    curl -sSLo "${HOME}/.config/alacritty/alacritty.toml" "https://github.com/ChrisTitusTech/dwm-titus/raw/main/config/alacritty/alacritty.toml"
    curl -sSLo "${HOME}/.config/alacritty/keybinds.toml" "https://github.com/ChrisTitusTech/dwm-titus/raw/main/config/alacritty/keybinds.toml" 
    curl -sSLo "${HOME}/.config/alacritty/nordic.toml" "https://github.com/ChrisTitusTech/dwm-titus/raw/main/config/alacritty/nordic.toml"
    printf "%b\n" "${GREEN}Alacritty configuration files copied.${RC}"
}

checkEnv
checkEscalationTool
installAlacritty
setupAlacrittyConfig
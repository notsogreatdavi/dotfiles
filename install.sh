#!/usr/bin/env bash
# Restaura o ambiente criando todos os symlinks necessários.
# Uso: bash install.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

link() {
    local src="$1"
    local dst="$2"

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "${dst}.bak"
        echo -e "${YELLOW}  backup: ${dst}.bak${NC}"
    fi

    ln -sf "$src" "$dst"
    echo -e "${GREEN}  linked: $dst -> $src${NC}"
}

install_template() {
    local template="$1"
    local dst="$2"

    if [ ! -f "$dst" ]; then
        cp "$template" "$dst"
        echo -e "${YELLOW}  ATENÇÃO: preencha as credenciais em $dst${NC}"
    else
        echo -e "${GREEN}  mantido: $dst (já existe)${NC}"
    fi
}

echo "==> Criando symlinks..."

# Arquivos na home
link "$DOTFILES_DIR/zshrc"     "$HOME/.zshrc"
link "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES_DIR/p10k.zsh"  "$HOME/.p10k.zsh"

# Diretórios em ~/.config
link "$DOTFILES_DIR/nvim"        "$CONFIG_DIR/nvim"
link "$DOTFILES_DIR/ghostty"     "$CONFIG_DIR/ghostty"
link "$DOTFILES_DIR/rofi"        "$CONFIG_DIR/rofi"
link "$DOTFILES_DIR/i3"          "$CONFIG_DIR/i3"
link "$DOTFILES_DIR/polybar"     "$CONFIG_DIR/polybar"
link "$DOTFILES_DIR/picom"       "$CONFIG_DIR/picom"
link "$DOTFILES_DIR/ranger"      "$CONFIG_DIR/ranger"
link "$DOTFILES_DIR/btop"        "$CONFIG_DIR/btop"
link "$DOTFILES_DIR/neofetch"    "$CONFIG_DIR/neofetch"
link "$DOTFILES_DIR/zathura"     "$CONFIG_DIR/zathura"
link "$DOTFILES_DIR/spotifyd"    "$CONFIG_DIR/spotifyd"
link "$DOTFILES_DIR/spotify-tui" "$CONFIG_DIR/spotify-tui"

# Arquivo isolado (não o diretório inteiro)
mkdir -p "$CONFIG_DIR/git"
link "$DOTFILES_DIR/git/ignore"  "$CONFIG_DIR/git/ignore"

echo ""
echo "==> Configs com credenciais (templates)..."

install_template "$DOTFILES_DIR/spotifyd/spotifyd.conf.template"    "$CONFIG_DIR/spotifyd/spotifyd.conf"
install_template "$DOTFILES_DIR/spotify-tui/client.yml.template"    "$CONFIG_DIR/spotify-tui/client.yml"

echo ""
echo "==> Concluído."
echo ""
echo "Próximos passos manuais:"
echo "  1. Instalar pacotes: zsh git neovim tmux ghostty ranger btop spotifyd"
echo "  2. Instalar Oh My Zsh: https://ohmyz.sh"
echo "  3. Instalar Powerlevel10k: https://github.com/romkatv/powerlevel10k"
echo "  4. Instalar TPM: https://github.com/tmux-plugins/tpm — depois: prefix + I no tmux"
echo "  5. Abrir Neovim — LazyVim instala os plugins automaticamente"
echo "  6. Preencher credenciais em:"
echo "     ~/.config/spotifyd/spotifyd.conf"
echo "     ~/.config/spotify-tui/client.yml"

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

echo "==> Criando symlinks..."

# Arquivos na home
link "$DOTFILES_DIR/zshrc"    "$HOME/.zshrc"
link "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES_DIR/p10k.zsh" "$HOME/.p10k.zsh"

# Diretórios em ~/.config
link "$DOTFILES_DIR/nvim"     "$CONFIG_DIR/nvim"
link "$DOTFILES_DIR/ghostty"  "$CONFIG_DIR/ghostty"
link "$DOTFILES_DIR/rofi"     "$CONFIG_DIR/rofi"

echo ""
echo "==> Symlinks criados com sucesso."
echo ""
echo "Próximos passos manuais:"
echo "  1. Instalar pacotes: zsh git neovim tmux ghostty"
echo "  2. Instalar Oh My Zsh: https://ohmyz.sh"
echo "  3. Instalar Powerlevel10k: https://github.com/romkatv/powerlevel10k"
echo "  4. Instalar TPM (tmux plugin manager): https://github.com/tmux-plugins/tpm"
echo "     Depois abrir tmux e pressionar prefix + I para instalar os plugins"
echo "  5. Abrir Neovim — o LazyVim instala os plugins automaticamente"

# dotfiles

Dotfiles para Arch Linux com i3wm.

## Stack

| Camada | Ferramenta |
|---|---|
| WM | i3 |
| Terminal | Ghostty |
| Multiplexer | tmux + TPM |
| Shell | Zsh + Oh My Zsh + Powerlevel10k |
| Editor | Neovim + LazyVim |
| Tema | Nord (global) |

## Instalação

```bash
git clone git@github.com:notsogreatdavi/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

O script cria todos os symlinks automaticamente. Arquivos existentes recebem backup com extensão `.bak`.

## Próximos passos após `install.sh`

1. Instalar pacotes base: `zsh git neovim tmux ghostty`
2. [Oh My Zsh](https://ohmyz.sh)
3. [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
4. [TPM](https://github.com/tmux-plugins/tpm) — depois `prefix + I` dentro do tmux para instalar plugins
5. Abrir Neovim — LazyVim instala os plugins automaticamente

## Estrutura

```
dotfiles/
├── install.sh       # Script de instalação (cria symlinks)
├── zshrc            # ~/.zshrc
├── tmux.conf        # ~/.tmux.conf
├── p10k.zsh         # ~/.p10k.zsh
├── nvim/            # ~/.config/nvim/
└── ghostty/         # ~/.config/ghostty/
```

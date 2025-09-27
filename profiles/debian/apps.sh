#!/bin/bash

apps=(
  "vim"
  "neovim"
  "tmux"
  "nethack"
  #"gitui"
)

vim_conf_live_folders=('~/.vim')
vim_conf_snap_folders=('.vim')
vim_conf_repo_folders=('vim')
vim_data_live_folders=('~/.vimdata')
vim_data_snap_folders=('.vimdata')

neovim_conf_live_folders=('~/.config/nvim')
neovim_conf_snap_folders=('.config/nvim')
neovim_conf_repo_folders=('nvim')
neovim_data_live_folders=('~/.local/share/nvim' '~/.local/state/nvim')
neovim_data_snap_folders=('.local/share/nvim' '.local/state/nvim')

tmux_conf_live_files=('~/.tmux.conf')
tmux_conf_snap_files=('.tmux.conf')
tmux_conf_repo_files=('tmux/tmux.conf')
tmux_data_live_folders=('~/.tmux')
tmux_data_snap_folders=('.tmux')

nethack_conf_live_files=('~/.nethackrc')
nethack_conf_snap_files=('.nethackrc')
nethack_conf_repo_files=('nethack/nethackrc')

gitui_conf_live_folders=('~/.config/gitui')
gitui_conf_snap_folders=('.config/gitui')
gitui_conf_repo_folders=('gitui')

bootstrap() {
  # Tmux
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ~/.tmux/plugins/tpm/scripts/install_plugins.sh

  # Vim
  vim +PlugInstall! +qa

  # Neovim
  (nvim --headless +"Lazy! install" +"qa")

  (nvim --headless \
    +"TSInstallSync! c cpp lua vim vimdoc query javascript python html bash markdown markdown_inline" \
    +"qa")

  (nvim --headless +"MasonInstall lua-language-server" +"qa")
}

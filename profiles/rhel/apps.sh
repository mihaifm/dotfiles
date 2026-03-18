#!/bin/bash

apps=("vim" "neovim" "tmux")

vim_conf_live_folders=('~/.vim')
vim_conf_snap_folders=('snap/.vim')
vim_conf_repo_folders=('app/vim')
vim_data_live_folders=('~/.vimdata')
vim_data_snap_folders=('snap/.vimdata')

neovim_conf_live_folders=('~/.config/nvim')
neovim_conf_snap_folders=('snap/.config/nvim')
neovim_conf_repo_folders=('app/nvim')
neovim_data_live_folders=('~/.local/share/nvim' '~/.local/state/nvim')
neovim_data_snap_folders=('snap/.local/share/nvim' 'snap/.local/state/nvim')

tmux_conf_live_files=('~/.tmux.conf')
tmux_conf_snap_files=('snap/.tmux.conf')
tmux_conf_repo_files=('app/tmux/tmux.conf')
tmux_data_live_folders=('~/.tmux')
tmux_data_snap_folders=('snap/.tmux')

bootstrap() {
  build_env="source scl_source enable devtoolset-12"

  # Tmux
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ~/.tmux/plugins/tpm/scripts/install_plugins.sh

  # Vim
  vim +PlugInstall! +qa

  # Neovim
  ($build_env && nvim --headless +"Lazy! install" +"qa")

  ($build_env && nvim --headless \
    +"TSInstallSync! c cpp lua vim vimdoc query javascript python html bash markdown markdown_inline" \
    +"qa")
}

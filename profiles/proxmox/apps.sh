#!/bin/bash

apps=(
  "vim"
  "tmux"
)

vim_conf_live_folders=('~/.vim')
vim_conf_snap_folders=('.vim')
vim_conf_repo_folders=('vim')
vim_data_live_folders=('~/.vimdata')
vim_data_snap_folders=('.vimdata')

tmux_conf_live_files=('~/.tmux.conf')
tmux_conf_snap_files=('.tmux.conf')
tmux_conf_repo_files=('tmux/tmux.conf')
tmux_data_live_folders=('~/.tmux')
tmux_data_snap_folders=('.tmux')

bootstrap() {
  # Tmux
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ~/.tmux/plugins/tpm/scripts/install_plugins.sh

  # Vim
  vim +PlugInstall! +qa
}

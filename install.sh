#!/bin/bash

apps=("vim" "neovim" "tmux" "nethack" "gitui")

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

###################
# Build a snapshot

if [[ $1 == 'snap' ]]; then
  mkdir -p snap

  for type in conf data; do
    for app in "${apps[@]}"; do
      live_folders="${app}_${type}_live_folders"
      snap_folders="${app}_${type}_snap_folders"

      if [ ! -z ${!live_folders} ]; then
        echo "snapping $app $type folders"
        eval "arr_size=\${#$live_folders[@]}"

        for (( i=0; i<$arr_size; i++ )); do
          eval "live_folder=\${$live_folders[i]}"
          eval "snap_folder=\${$snap_folders[i]}"

          # expand ~ variable
          eval "l_folder=$live_folder"
          eval "s_folder=$snap_folder"

          echo "snapping $l_folder to snap/$s_folder"

          mkdir -p "snap/$s_folder"
          cp -r "$l_folder/." "snap/$s_folder"
        done
        echo
      fi
    done

    for app in "${apps[@]}"; do
      live_files="${app}_${type}_live_files"
      snap_files="${app}_${type}_snap_files"

      if [ ! -z ${!live_files} ]; then
        echo "snapping $app $type files"
        eval "arr_size=\${#$live_files[@]}"

        for (( i=0; i<$arr_size; i++ )); do
          eval "live_file=\${$live_files[i]}"
          eval "snap_file=\${$snap_files[i]}"

          # expand ~ variable
          eval "l_file=$live_file"
          eval "s_file=$snap_file"

          echo "snapping $l_file to snap/$s_file"

          #todo - path to file may not exist
          cp "$l_file" "snap/$s_file"
        done
        echo
      fi
    done
  done

  tar -czf ../dotfiles.tar.gz -C .. dotfiles
  rm -rf snap

  echo 'Done snapping'
fi

########################
# Restore from snapshot

if [[ $1 == 'restore' ]]; then
  mkdir -p ~/.config

  for type in conf data; do
    for app in "${apps[@]}"; do
      live_folders="${app}_${type}_live_folders"
      snap_folders="${app}_${type}_snap_folders"

      if [ ! -z ${!live_folders} ]; then
        echo "restoring $app $type folders"
        eval "arr_size=\${#$live_folders[@]}"

        for (( i=0; i<$arr_size; i++ )); do
          eval "live_folder=\${$live_folders[i]}"
          eval "snap_folder=\${$snap_folders[i]}"

          # expand ~ variable
          eval "live_folder=$live_folder"
          eval "snap_folder=$snap_folder"

          echo "restoring snap/$snap_folder to $live_folder"

          echo "removing $live_folder.old"
          rm -rf $live_folder.old

          echo "moving $live_folder to $live_folder.old"
          mv "$live_folder" "$live_folder.old"

          echo "copying snap/$snap_folder to $live_folder"
          cp -r "snap/$snap_folder/." "$live_folder"
        done
        echo
      fi
    done
    for app in "${apps[@]}"; do
      live_files="${app}_${type}_live_files"
      snap_files="${app}_${type}_snap_files"

      if [ ! -z ${!live_files} ]; then
        echo "restoring $app $type files"
        eval "arr_size=\${#$live_files[@]}"

        for (( i=0; i<$arr_size; i++ )); do
          eval "live_file=\${$live_files[i]}"
          eval "snap_file=\${$snap_files[i]}"

          # expand ~ variable
          eval "live_file=$live_file"
          eval "snap_file=$snap_file"

          echo "restoring snap/$snap_file to $live_file"

          echo "removing $live_file.old"
          rm -rf $live_file.old

          echo "moving $live_file to $live_file.old"
          mv "$live_file" "$live_file.old"

          echo "copying snap/$snap_file to $live_file"
          cp -r "snap/$snap_file" "$live_file"
        done
        echo
      fi
    done
  done
  echo 'Done restoring'
fi

####################
# Clean plugin data

if [[ $1 == 'clean' ]]; then
  for type in "data"; do
    for app in "${apps[@]}"; do
      live_folders="${app}_${type}_live_folders"

      if [ ! -z ${!live_folders} ]; then
        echo "cleaning $app $type folders"
        eval "arr_size=\${#$live_folders[@]}"

        for (( i=0; i<$arr_size; i++ )); do
          eval "live_folder=\${$live_folders[i]}"
          # expand ~ variable
          eval "live_folder=$live_folder"

          echo "cleaning $live_folder"

          echo "removing $live_folder.old"
          rm -rf $live_folder.old

          echo "moving $live_folder to $live_folder.old"
          mv "$live_folder" "$live_folder.old"
        done
        echo
      fi
    done
    for app in "${apps[@]}"; do
      live_files="${app}_${type}_live_files"

      if [ ! -z ${!live_files} ]; then
        echo "cleaning $app $type files"
        eval "arr_size=\${#$live_files[@]}"

        for (( i=0; i<$arr_size; i++ )); do
          eval "live_file=\${$live_files[i]}"
          # expand ~ variable
          eval "live_file=$live_file"

          echo "cleaning snap/$snap_file to $live_file"

          echo "removing $live_file.old"
          rm -rf $live_file.old

          echo "moving $live_file to $live_file.old"
          mv "$live_file" "$live_file.old"
        done
        echo
      fi
    done
  done
  echo 'Done cleaning'
fi

#########################
# Install from this repo

if [[ $1 == 'repo' ]]; then
  mkdir -p ~/.config

  for type in "conf"; do
    for app in "${apps[@]}"; do
      live_folders="${app}_${type}_live_folders"
      repo_folders="${app}_${type}_repo_folders"

      if [ ! -z ${!live_folders} ]; then
        echo "installing $app $type folders"
        eval "arr_size=\${#$live_folders[@]}"

        for (( i=0; i<$arr_size; i++ )); do
          eval "live_folder=\${$live_folders[i]}"
          eval "repo_folder=\${$repo_folders[i]}"

          # expand ~ variable
          eval "live_folder=$live_folder"
          eval "repo_folder=$repo_folder"

          echo "installing $repo_folder to $live_folder"

          echo "removing $live_folder.old"
          rm -rf $live_folder.old

          echo "moving $live_folder to $live_folder.old"
          mv "$live_folder" "$live_folder.old"

          echo "copying $repo_folder to $live_folder"
          cp -r "$repo_folder/." "$live_folder"
        done
        echo
      fi
    done
    for app in "${apps[@]}"; do
      live_files="${app}_${type}_live_files"
      repo_files="${app}_${type}_repo_files"

      if [ ! -z ${!live_files} ]; then
        echo "restoring $app $type files"
        eval "arr_size=\${#$live_files[@]}"

        for (( i=0; i<$arr_size; i++ )); do
          eval "live_file=\${$live_files[i]}"
          eval "repo_file=\${$repo_files[i]}"

          # expand ~ variable
          eval "live_file=$live_file"
          eval "repo_file=$repo_file"

          echo "restoring $repo_file to $live_file"

          echo "removing $live_file.old"
          rm -rf $live_file.old

          echo "moving $live_file to $live_file.old"
          mv "$live_file" "$live_file.old"

          echo "copying $repo_file to $live_file"
          cp -r $repo_file $live_file
        done
        echo
      fi
    done
  done
  echo 'Done installing'
fi

#######################
# Bootstrap everything

if [[ $1 == "bootstrap" ]]; then

  # detect OS
  if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  fi

  if [[ "$ID" == "rhel" ]]; then
    build_env="source scl_source enable devtoolset-12"
  else
    build_env="true"
  fi

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

  (nvim --headless +"MasonInstall lua-language-server" +"qa")

  exit
fi

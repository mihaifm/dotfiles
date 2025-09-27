#!/bin/bash

# these functions implement expect the following variables/arrays to be
# defined by the caller (install.sh):
#
#   <app>_conf_live_folders
#   <app>_conf_snap_folders
#   <app>_conf_repo_folders
#
#   <app>_conf_live_files
#   <app>_conf_snap_files
#   <app>_conf_repo_files
#
#   <app>_data_live_folders
#   <app>_data_snap_folders

cmd_snap() {
  mkdir -p snap

  for type in conf data; do
    # folders
    for app in "${apps[@]}"; do
      local live_folders="${app}_${type}_live_folders"
      local snap_folders="${app}_${type}_snap_folders"

      if [ -n "${!live_folders:-}" ]; then
        echo "snapping $app $type folders"
        eval "arr_size=\${#$live_folders[@]}"

        for (( i=0; i< arr_size; i++ )); do
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

    # files
    for app in "${apps[@]}"; do
      local live_files="${app}_${type}_live_files"
      local snap_files="${app}_${type}_snap_files"

      if [ -n "${!live_files:-}" ]; then
        echo "snapping $app $type files"
        eval "arr_size=\${#$live_files[@]}"

        for (( i=0; i< arr_size; i++ )); do
          eval "live_file=\${$live_files[i]}"
          eval "snap_file=\${$snap_files[i]}"

          # expand ~ variable
          eval "l_file=$live_file"
          eval "s_file=$snap_file"

          echo "snapping $l_file to snap/$s_file"
          cp "$l_file" "snap/$s_file"
        done
        echo
      fi
    done
  done

  tar -czf ../dotfiles.tar.gz -C .. dotfiles
  rm -rf snap

  echo 'Done snapping'
}

cmd_restore() {
  mkdir -p ~/.config

  for type in conf data; do
    # folders
    for app in "${apps[@]}"; do
      local live_folders="${app}_${type}_live_folders"
      local snap_folders="${app}_${type}_snap_folders"

      if [ -n "${!live_folders:-}" ]; then
        echo "restoring $app $type folders"
        eval "arr_size=\${#$live_folders[@]}"

        for (( i=0; i< arr_size; i++ )); do
          eval "live_folder=\${$live_folders[i]}"
          eval "snap_folder=\${$snap_folders[i]}"

          # expand ~ variable
          eval "live_folder=$live_folder"
          eval "snap_folder=$snap_folder"

          echo "restoring snap/$snap_folder to $live_folder"

          echo "removing $live_folder.old"
          rm -rf "$live_folder.old"

          echo "moving $live_folder to $live_folder.old"
          mv "$live_folder" "$live_folder.old"

          echo "copying snap/$snap_folder to $live_folder"
          cp -r "snap/$snap_folder/." "$live_folder"
        done
        echo
      fi
    done

    # files
    for app in "${apps[@]}"; do
      local live_files="${app}_${type}_live_files"
      local snap_files="${app}_${type}_snap_files"

      if [ -n "${!live_files:-}" ]; then
        echo "restoring $app $type files"
        eval "arr_size=\${#$live_files[@]}"

        for (( i=0; i< arr_size; i++ )); do
          eval "live_file=\${$live_files[i]}"
          eval "snap_file=\${$snap_files[i]}"

          # expand ~ variable
          eval "live_file=$live_file"
          eval "snap_file=$snap_file"

          echo "restoring snap/$snap_file to $live_file"

          echo "removing $live_file.old"
          rm -rf "$live_file.old"

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
}

cmd_clean() {
  for type in data; do
    # folders
    for app in "${apps[@]}"; do
      local live_folders="${app}_${type}_live_folders"

      if [ -n "${!live_folders:-}" ]; then
        echo "cleaning $app $type folders"
        eval "arr_size=\${#$live_folders[@]}"

        for (( i=0; i< arr_size; i++ )); do
          eval "live_folder=\${$live_folders[i]}"
          # expand ~ variable
          eval "live_folder=$live_folder"

          echo "cleaning $live_folder"

          echo "removing $live_folder.old"
          rm -rf "$live_folder.old"

          echo "moving $live_folder to $live_folder.old"
          mv "$live_folder" "$live_folder.old"
        done
        echo
      fi
    done

    # files
    for app in "${apps[@]}"; do
      local live_files="${app}_${type}_live_files"

      if [ -n "${!live_files:-}" ]; then
        echo "cleaning $app $type files"
        eval "arr_size=\${#$live_files[@]}"

        for (( i=0; i< arr_size; i++ )); do
          eval "live_file=\${$live_files[i]}"
          # expand ~ variable
          eval "live_file=$live_file"

          echo "cleaning $live_file"

          echo "removing $live_file.old"
          rm -rf "$live_file.old"

          echo "moving $live_file to $live_file.old"
          mv "$live_file" "$live_file.old"
        done
        echo
      fi
    done
  done
  echo 'Done cleaning'
}

cmd_repo() {
  mkdir -p ~/.config

  for type in conf; do
    # folders
    for app in "${apps[@]}"; do
      local live_folders="${app}_${type}_live_folders"
      local repo_folders="${app}_${type}_repo_folders"

      if [ -n "${!live_folders:-}" ]; then
        echo "installing $app $type folders"
        eval "arr_size=\${#$live_folders[@]}"

        for (( i=0; i< arr_size; i++ )); do
          eval "live_folder=\${$live_folders[i]}"
          eval "repo_folder=\${$repo_folders[i]}"

          # expand ~ variable
          eval "live_folder=$live_folder"
          eval "repo_folder=$repo_folder"

          echo "installing $repo_folder to $live_folder"

          echo "removing $live_folder.old"
          rm -rf "$live_folder.old"

          echo "moving $live_folder to $live_folder.old"
          mv "$live_folder" "$live_folder.old"

          echo "copying $repo_folder to $live_folder"
          cp -r "$repo_folder/." "$live_folder"
        done
        echo
      fi
    done

    # files
    for app in "${apps[@]}"; do
      local live_files="${app}_${type}_live_files"
      local repo_files="${app}_${type}_repo_files"

      if [ -n "${!live_files:-}" ]; then
        echo "installing $app $type files"
        eval "arr_size=\${#$live_files[@]}"

        for (( i=0; i< arr_size; i++ )); do
          eval "live_file=\${$live_files[i]}"
          eval "repo_file=\${$repo_files[i]}"

          # expand ~ variable
          eval "live_file=$live_file"
          eval "repo_file=$repo_file"

          echo "installing $repo_file to $live_file"

          echo "removing $live_file.old"
          rm -rf "$live_file.old"

          echo "moving $live_file to $live_file.old"
          mv "$live_file" "$live_file.old"

          echo "copying $repo_file to $live_file"
          cp -r "$repo_file" "$live_file"
        done
        echo
      fi
    done
  done
  echo 'Done installing'
}


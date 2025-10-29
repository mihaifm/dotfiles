#!/bin/bash

detect_profile() {
  # respect pre-set env first
  # (DOTFILES_PROFILE or DOTFILES_OS/DOTFILES_DISTRO)
  local pre_profile="${DOTFILES_PROFILE:-}"
  if [ -n "$pre_profile" ]; then
    # accept forms like "linux-debian" or just "macos"
    if printf %s "$pre_profile" | grep -q -- '-'; then
      DOTFILES_OS="${pre_profile%%-*}"
      DOTFILES_DISTRO="${pre_profile#*-}"
    else
      DOTFILES_OS="$pre_profile"
      DOTFILES_DISTRO="${DOTFILES_DISTRO:-}"
    fi
  fi

  if [ -z "$DOTFILES_OS" ]; then
    local uname_s
    uname_s="$(uname -s 2>/dev/null || echo Unknown)"
    case "$uname_s" in
      Linux)   DOTFILES_OS="linux" ;;
      Darwin)  DOTFILES_OS="macos" ;;
      MINGW*|MSYS*|CYGWIN*) DOTFILES_OS="windows" ;;
      *) DOTFILES_OS="$(printf %s "$uname_s" | tr '[:upper:]' '[:lower:]')" ;;
    esac
  fi

  if [ -z "$DOTFILES_DISTRO" ] && [ "$DOTFILES_OS" = "linux" ] && [ -r /etc/os-release ]; then
    . /etc/os-release
    if [ -n "$ID" ]; then
      DOTFILES_DISTRO="$ID"
    elif [ -n "$ID_LIKE" ]; then
      DOTFILES_DISTRO="${ID_LIKE%% *}"
    fi
    if [ -f /etc/pve/.version ]; then
      DOTFILES_DISTRO="proxmox"
    fi
  fi

  # compose profile string
  if [ -n "$DOTFILES_DISTRO" ]; then
    DOTFILES_PROFILE="${DOTFILES_DISTRO}"
  else
    DOTFILES_PROFILE="${DOTFILES_OS}"
  fi

  export DOTFILES_OS DOTFILES_DISTRO DOTFILES_PROFILE
}

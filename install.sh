#!/bin/bash

. "scripts/profile_detector.sh"
detect_profile
echo "Using profile $DOTFILES_PROFILE"

apps=()

if [ -n "$DOTFILES_PROFILE" ] && [ -d "profiles/$DOTFILES_PROFILE" ]; then
  . "profiles/$DOTFILES_PROFILE/apps.sh"
fi

. "scripts/subcommands.sh"

case "$1" in
  snap)
    cmd_snap
    ;;
  restore)
    cmd_restore
    ;;
  clean)
    cmd_clean
    ;;
  repo)
    cmd_repo
    ;;
  bootstrap)
    bootstrap
    ;;
  *)
    echo "usage: $0 {snap|restore|clean|repo|bootstrap}"
    exit 1
    ;;
esac

exit 0

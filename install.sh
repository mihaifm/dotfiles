# Build a snapshot

if [[ $1 == "snap" ]]; then
  mkdir -p snap

  # Vim
  cp -r ~/.vim snap
  cp -r ~/.vimdata snap

  # Neovim
  mkdir -p snap/.config
  cp -r ~/.config/nvim snap/.config

  mkdir -p snap/.local/share
  cp -r ~/.local/share/nvim snap/.local/share

  mkdir -p snap/.local/state
  cp -r ~/.local/state/nvim snap/.local/state

  # Nethack
  cp ~/.nethackrc snap

  # Tmux
  cp ~/.tmux.conf snap

  tar -czf ../dotfiles.tar.gz -C .. dotfiles

  rm -rf snap

  exit
fi

# Restore from snapshot

if [[ $1 == "rest" ]]; then

  # Vim
  rm -rf ~/.oldvim
  mv ~/.vim ~/.oldvim
  cp -r snap/.vim ~/

  rm -rf ~/.oldvimdata
  mv ~/.vimdata ~/.oldvimdata
  cp -r snap/.vimdata ~/

  # Neovim
  rm -rf ~/.config/oldnvim
  mv ~/.config/nvim ~/.config/oldnvim
  cp -r snap/.config/nvim ~/.config/

  rm -rf ~/.local/share/oldnvim
  mv ~/.local/share/nvim ~/.local/share/oldnvim
  cp -r snap/.local/share/nvim ~/.local/share/

  rm -rf ~/.local/state/oldnvim
  mv ~/.local/state/nvim ~/.local/state/oldnvim
  cp -r snap/.local/state/nvim ~/.local/state/

  # Nethack
  mv ~/.nethackrc ~/.oldnethackrc
  cp snap/.nethackrc ~/

  # Tmux
  mv ~/.tmux.conf ~/.oldtmux.conf
  cp snap/.tmux.conf ~/

  exit
fi

# Install from this repo

if [[ $1 == "repo" ]]; then

  # Vim
  rm -rf ~/.oldvim
  mv ~/.vim ~/.oldvim
  mkdir -p ~/.vim
  cp -r vim/* ~/.vim/
  mkdir -p ~/.vimdata

  # Neovim
  rm -rf ~/.config/oldnvim
  mv ~/.config/nvim ~/.config/oldnvim
  mkdir -p ~/.config/nvim
  cp -r nvim/* ~/.config/nvim/

  # NetHack
  mv ~/.nethackrc ~/.oldnethackrc
  cp nethack/.nethackrc ~/.nethackrc

  # Tmux
  mv ~/.tmux.conf ~/.oldtmux.conf
  cp tmux/.tmux.conf ~/.tmux.conf
fi

# Vim

find ../dotfiles -type f | xargs sed -i 's/\r$//'

rm -rf ~/.oldvim
mv ~/.vim ~/.oldvim
mkdir -p ~/.vim
cp -r vim/* ~/.vim/
mkdir -p ~/.vim/pack/mybundle/start

if [[ $DOTFILES_INSTALL == 1 ]]; then
  rm -rf stage
  mkdir stage

  git clone https://github.com/mihaifm/bufstop stage/bufstop
  rm -rf stage/bufstop/.git

  git clone https://github.com/mihaifm/vimpanel stage/vimpanel
  rm -rf stage/vimpanel/.git

  git clone https://github.com/mihaifm/4colors stage/4colors
  rm -rf stage/4colors/.git

  git clone https://github.com/easymotion/vim-easymotion stage/vim-easymotion
  rm -rf stage/vim-easymotion/.git

  git clone https://github.com/itchyny/lightline.vim stage/lightline
  rm -rf stage/lightline/.git
fi

cp -r stage/bufstop ~/.vim/pack/mybundle/start/bufstop
cp -r stage/vimpanel ~/.vim/pack/mybundle/start/vimpanel
cp -r stage/4colors ~/.vim/pack/mybundle/start/4colors
cp -r stage/vim-easymotion ~/.vim/pack/mybundle/start/vim-easymotion
cp -r stage/lightline ~/.vim/pack/mybundle/start/lightline

# NetHack

mv ~/.nethackrc ~/.oldnethackrc
cp nethack/.nethackrc ~/.nethackrc

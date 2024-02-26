# Vim

find ../dotfiles -type f | xargs sed -i 's/\r$//'
rm -rf ~/.oldvim
mv ~/.vim ~/.oldvim
mv ~/.vimrc ~/.oldvimrc
mkdir -p ~/.vim
cp -r vim/* ~/.vim/
mv ~/.vim/_vimrc ~/.vimrc
mv ~/.vim/_gvimrc ~/.gvimrc

mkdir -p ~/.vim/pack/mybundle/start

if [[ -z "${LOCAL_DOTFILES_INSTALL}" ]]; then
  git clone https://github.com/mihaifm/bufstop ~/.vim/pack/mybundle/start/bufstop
  rm -rf ~/.vim/pack/mybundle/start/bufstop/.git

  git clone https://github.com/mihaifm/vimpanel ~/.vim/pack/mybundle/start/vimpanel
  rm -rf ~/.vim/pack/mybundle/start/vimpanel/.git

  git clone https://github.com/mihaifm/4colors ~/.vim/pack/mybundle/start/4colors
  rm -rf ~/.vim/pack/mybundle/start/4colors/.git

  git clone https://github.com/easymotion/vim-easymotion ~/.vim/pack/mybundle/start/vim-easymotion
  rm -rf ~/.vim/pack/mybundle/start/vim-easymotion/.git

  git clone https://github.com/itchyny/lightline.vim ~/.vim/pack/mybundle/start/lightline
  rm -rf ~/.vim/pack/mybundle/start/lightline/.git
else
  cp -r clones/bufstop ~/.vim/pack/mybundle/start/bufstop
  cp -r clones/vimpanel ~/.vim/pack/mybundle/start/vimpanel
  cp -r clones/4colors ~/.vim/pack/mybundle/start/4colors
  cp -r clones/vim-easymotion ~/.vim/pack/mybundle/start/vim-easymotion
  cp -r clones/lightline ~/.vim/pack/mybundle/start/lightline
fi

# NetHack

mv ~/.nethackrc ~/.oldnethackrc
cp nethack/.nethackrc ~/.nethackrc

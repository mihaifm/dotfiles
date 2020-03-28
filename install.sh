# Vim
ln -sf $PWD/vim/_vimrc ~/.vimrc
ln -sf $PWD/vim ~/.vim
rm -rf ~/.vim/pack/mybundle
mkdir -p ~/.vim/pack/mybundle/start

git clone https://github.com/mihaifm/bufstop ~/.vim/pack/mybundle/start/bufstop
rm -rf ~/.vim/pack/mybundle/start/bufstop/.git

git clone https://github.com/mihaifm/vimpanel ~/.vim/pack/mybundle/start/vimpanel
rm -rf ~/.vim/pack/mybundle/start/vimpanel/.git

git clone https://github.com/easymotion/vim-easymotion ~/.vim/pack/mybundle/start/vim-easymotion
rm -rf ~/.vim/pack/mybundle/start/vim-easymotion/.git

# NetHack
ln -sf $PWD/nethack/.nethackrc ~/.nethackrc

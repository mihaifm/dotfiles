@echo off

REM When called with no args, defines app lists in caller env
REM When called with "bootstrap", runs app bootstrap

if /I "%~1"=="bootstrap" goto :do_bootstrap

set apps[0]=vim
set apps[1]=neovim
set apps[2]=neovide

set vim_conf_live_folders[0]=%USERPROFILE%\vimfiles
set vim_conf_snap_folders[0]=vimfiles
set vim_conf_repo_folders[0]=vim
set vim_data_live_folders[0]=%USERPROFILE%\.vimdata
set vim_data_snap_folders[0]=.vimdata

set neovim_conf_live_folders[0]=%USERPROFILE%\AppData\Local\nvim
set neovim_conf_snap_folders[0]=AppData\Local\nvim
set neovim_conf_repo_folders[0]=nvim
set neovim_data_live_folders[0]=%USERPROFILE%\AppData\Local\nvim-data
set neovim_data_snap_folders[0]=AppData\Local\nvim-data

set neovide_conf_live_folders[0]=%USERPROFILE%\AppData\Roaming\neovide
set neovide_conf_snap_folders[0]=AppData\Roaming\neovide
set neovide_conf_repo_folders[0]=neovide

exit /b 0

:do_bootstrap

vim +PlugInstall! +qa
nvim --headless +"Lazy^! install" +"qa"
nvim --headless +"MasonInstall lua-language-server" +"qa"

exit /b 0

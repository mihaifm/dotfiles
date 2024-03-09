@echo off

:: Vim

rd /S /Q %USERPROFILE%\oldvimfiles
robocopy %USERPROFILE%\vimfiles %USERPROFILE%\oldvimfiles /E /MOVE  /NFL /NDL /NJH /NJS /NC /NS /NP 
mkdir %USERPROFILE%\vimfiles
xcopy /Y /S /E /H /Q vim\* %USERPROFILE%\vimfiles\
mkdir %USERPROFILE%\vimfiles\pack\mybundle\start

if [%1]==[web] (
    rd /S /Q stage
    mkdir stage

    git clone https://github.com/mihaifm/bufstop stage\bufstop
    rmdir /S /Q stage\bufstop\.git

    git clone https://github.com/mihaifm/vimpanel stage\vimpanel
    rmdir /S /Q stage\vimpanel\.git

    git clone https://github.com/mihaifm/4colors stage\4colors
    rmdir /S /Q stage\4colors\.git

    git clone https://github.com/easymotion/vim-easymotion stage\vim-easymotion
    rmdir /S /Q stage\vim-easymotion\.git

    git clone https://github.com/itchyny/lightline.vim stage\lightline
    rmdir /S /Q stage\lightline\.git
) else ( 
    if [%1]==[dev] (
        rd /S /Q stage
        mkdir stage

        xcopy /Y /S /E /H /Q D:\Syncbox\Projects\bufstop stage\bufstop\
        rmdir /S /Q stage\bufstop\.git

        xcopy /Y /S /E /H /Q D:\Syncbox\Projects\vimpanel stage\vimpanel\
        rmdir /S /Q stage\vimpanel\.git

        xcopy /Y /S /E /H /Q D:\Syncbox\Projects\4colors stage\4colors\
        rmdir /S /Q stage\4colors\.git

        xcopy /Y /S /E /H /Q D:\Clone\vim-easymotion stage\vim-easymotion\
        rmdir /S /Q stage\vim-easymotion\.git

        xcopy /Y /S /E /H /Q D:\Clone\lightline stage\lightline\
        rmdir /S /Q stage\lightline\.git
    )
)

xcopy /Y /S /E /H /Q stage\bufstop %USERPROFILE%\vimfiles\pack\mybundle\start\bufstop\
xcopy /Y /S /E /H /Q stage\vimpanel %USERPROFILE%\vimfiles\pack\mybundle\start\vimpanel\
xcopy /Y /S /E /H /Q stage\4colors %USERPROFILE%\vimfiles\pack\mybundle\start\4colors\
xcopy /Y /S /E /H /Q stage\vim-easymotion %USERPROFILE%\vimfiles\pack\mybundle\start\vim-easymotion\
xcopy /Y /S /E /H /Q stage\lightline %USERPROFILE%\vimfiles\pack\mybundle\start\lightline\

:: Neovim

rd /S /Q %USERPROFILE%\AppData\Local\oldnvim
robocopy %USERPROFILE%\AppData\Local\nvim %USERPROFILE%\AppData\Local\oldnvim /E /MOVE  /NFL /NDL /NJH /NJS /NC /NS /NP 
mkdir %USERPROFILE%\AppData\Local\nvim
xcopy /Y /S /E /H /Q nvim\* %USERPROFILE%\AppData\Local\nvim\
mkdir %USERPROFILE%\AppData\Local\nvim\pack\mybundle\start

xcopy /Y /S /E /H /Q stage\bufstop %USERPROFILE%\AppData\Local\nvim\pack\mybundle\start\bufstop\
xcopy /Y /S /E /H /Q stage\vimpanel %USERPROFILE%\AppData\Local\nvim\pack\mybundle\start\vimpanel\
xcopy /Y /S /E /H /Q stage\4colors %USERPROFILE%\AppData\Local\nvim\pack\mybundle\start\4colors\
xcopy /Y /S /E /H /Q stage\vim-easymotion %USERPROFILE%\AppData\Local\nvim\pack\mybundle\start\vim-easymotion\
xcopy /Y /S /E /H /Q stage\lightline %USERPROFILE%\AppData\Local\nvim\pack\mybundle\start\lightline\

@echo off

REM -----------------
REM Build a snapshot

if [%1]==[snap] (
  mkdir snap

  REM Vim
  mkdir snap\vimfiles
  xcopy /I /Y /S /E /H /Q "%USERPROFILE%\vimfiles\*" snap\vimfiles
  mkdir snap\.vimdata
  xcopy /I /Y /S /E /H /Q "%USERPROFILE%\.vimdata\*" snap\.vimdata

  REM Neovim
  mkdir snap\AppData\Local\nvim
  xcopy /I /Y /S /E /H /Q "%USERPROFILE%\AppData\Local\nvim\*" snap\AppData\Local\nvim
  mkdir snap\AppData\Local\nvim-data
  xcopy /I /Y /S /E /H /Q "%USERPROFILE%\AppData\Local\nvim-data\*" snap\AppData\Local\nvim-data

  REM Neovide
  mkdir snap\AppData\Roaming\neovide
  xcopy /I /Y /S /E /H /Q "%USERPROFILE%\AppData\Roaming\neovide\*" snap\AppData\Roaming\neovide

  tar -czf ..\dotfiles.tar.gz -C .. dotfiles

  rmdir /S /Q snap
)

REM ----------------------
REM Restore from snapshot

if [%1]==[restore] (
  REM Vim
  rmdir /S /Q "%USERPROFILE%\oldvimfiles"
  move "%USERPROFILE%\vimfiles" "%USERPROFILE%\oldvimfiles"
  mkdir "%USERPROFILE%\vimfiles"
  xcopy /I /Y /S /E /H /Q "snap\vimfiles\*" "%USERPROFILE%\vimfiles"

  rmdir /S /Q "%USERPROFILE%\.oldvimdata"
  move "%USERPROFILE%\.vimdata" "%USERPROFILE%\.oldvimdata"
  mkdir "%USERPROFILE%\.vimdata"
  xcopy /I /Y /S /E /H /Q "snap\.vimdata\*" "%USERPROFILE%\.vimdata"

  REM Neovim
  rmdir /S /Q "%USERPROFILE%\AppData\Local\oldnvim" 
  move "%USERPROFILE%\AppData\Local\nvim" "%USERPROFILE%\AppData\Local\oldnvim" 
  mkdir "%USERPROFILE%\AppData\Local\nvim"
  xcopy /I /Y /S /E /H /Q "snap\AppData\Local\nvim\*" "%USERPROFILE%\AppData\Local\nvim"

  rmdir /S /Q "%USERPROFILE%\AppData\Local\oldnvim-data" 
  move "%USERPROFILE%\AppData\Local\nvim-data" "%USERPROFILE%\AppData\Local\oldnvim-data" 
  mkdir "%USERPROFILE%\AppData\Local\nvim-data"
  xcopy /I /Y /S /E /H /Q "snap\AppData\Local\nvim-data\*" "%USERPROFILE%\AppData\Local\nvim-data"

  REM Neovide
  rmdir /S /Q "%USERPROFILE%\AppData\Roaming\oldneovide" 
  move "%USERPROFILE%\AppData\Roaming\neovide" "%USERPROFILE%\AppData\Roaming\oldneovide"
  mkdir "%USERPROFILE%\AppData\Roaming\neovide"
  xcopy /I /Y /S /E /H /Q "snap\AppData\Roaming\neovide\*" "%USERPROFILE%\AppData\Roaming\neovide"
)

REM ------------------
REM Clean plugin data

if [%1]==[clean] (
  REM Vim
  rmdir /S /Q "%USERPROFILE%\.oldvimdata"
  move "%USERPROFILE%\.vimdata" "%USERPROFILE%\.oldvimdata"

  REM Neovim
  rmdir /S /Q "%USERPROFILE%\AppData\Local\oldnvim-data" 
  move "%USERPROFILE%\AppData\Local\nvim-data" "%USERPROFILE%\AppData\Local\oldnvim-data" 

  REM Neovide
  rmdir /S /Q "%USERPROFILE%\AppData\Roaming\oldneovide" 
  move "%USERPROFILE%\AppData\Local\neovide" "%USERPROFILE%\AppData\Roaming\oldneovide" 
)

REM -----------------------
REM Install from this repo

if [%1]==[repo] (
  REM Vim
  rmdir /S /Q %USERPROFILE%\oldvimfiles
  move "%USERPROFILE%\vimfiles" "%USERPROFILE%\oldvimfiles"
  mkdir "%USERPROFILE%\vimfiles"
  xcopy /I /Y /S /E /H /Q vim\* "%USERPROFILE%\vimfiles"

  REM Neovim
  rmdir /S /Q "%USERPROFILE%\AppData\Local\oldnvim" 
  move "%USERPROFILE%\AppData\Local\nvim" "%USERPROFILE%\AppData\Local\oldnvim" 
  mkdir "%USERPROFILE%\AppData\Local\nvim"
  xcopy /I /Y /S /E /H /Q nvim\* "%USERPROFILE%\AppData\Local\nvim"

  REM Neovide
  rmdir /S /Q "%USERPROFILE%\AppData\Roaming\oldneovide" 
  move "%USERPROFILE%\AppData\Roaming\neovide" "%USERPROFILE%\AppData\Roaming\oldneovide" 
  mkdir "%USERPROFILE%\AppData\Roaming\neovide"
  xcopy /I /Y /S /E /H /Q neovide\* "%USERPROFILE%\AppData\Roaming\neovide"
)


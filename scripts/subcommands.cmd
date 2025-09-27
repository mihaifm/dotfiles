@echo off
setlocal EnableDelayedExpansion

REM Reusable Windows subcommands for install.cmd
REM Expects apps and app arrays defined by caller

REM   <app>_conf_live_folders
REM   <app>_conf_snap_folders
REM   <app>_conf_repo_folders
REM
REM   <app>_conf_live_files
REM   <app>_conf_snap_files
REM   <app>_conf_repo_files
REM
REM   <app>_data_live_folders
REM   <app>_data_snap_folders

if "%~1"=="snap" goto :do_snap
if "%~1"=="restore" goto :do_restore
if "%~1"=="clean" goto :do_clean
if "%~1"=="repo" goto :do_repo
goto :usage

:do_snap
mkdir snap

set types[0]=conf
set types[1]=data

set type_index=0

:snap_type_loop
call set typ=%%types[!type_index!]%%

if not "!typ!"=="" (
  set app_index=0
  :snap_app_folders_loop
  call set app=%%apps[!app_index!]%%

  if not "!app!"=="" (
    set live_folders=!app!_!typ!_live_folders
    set snap_folders=!app!_!typ!_snap_folders

    call set check_live_folders=%%!live_folders![0]%%

    if not "!check_live_folders!"=="" (
      echo snapping !app! !typ! folders

      set live_folders_index=0

      :snap_live_folders_loop
      call set live_folder=%%!live_folders![!live_folders_index!]%%

      if not "!live_folder!"=="" (
        call set snap_folder=%%!snap_folders![!live_folders_index!]%%

        echo snapping !live_folder! to snap\!snap_folder!

        mkdir "snap\!snap_folder!" 
        xcopy /I /Y /S /E /H /Q "!live_folder!" "snap\!snap_folder!"

        set /a live_folders_index+=1
        goto snap_live_folders_loop
      )

      echo:
    )

    set /a app_index+=1
    goto snap_app_folders_loop
  )

  set app_index=0
  :snap_app_files_loop
  call set app=%%apps[!app_index!]%%

  if not "!app!"=="" (
    set live_files=!app!_!typ!_live_files
    set snap_files=!app!_!typ!_snap_files

    call set check_live_files=%%!live_files![0]%%

    if not "!check_live_files!"=="" (
      echo snapping !app! !typ! files

      set live_files_index=0

      :snap_live_files_loop
      call set live_file=%%!live_files![!live_files_index!]%%

      if not "!live_file!"=="" (
        call set snap_file=%%!snap_files![!live_files_index!]%%

        echo snapping !live_file! to snap\!snap_file!

        xcopy /I /Y /S /E /H /Q "!live_file!" "snap\!snap_file!*"

        set /a live_files_index+=1
        goto snap_live_files_loop
      )

      echo:
    )

    set /a app_index+=1
    goto snap_app_files_loop
  )

  set /a type_index+=1
  goto snap_type_loop
)

tar -acf ..\dotfiles.zip -C .. dotfiles
rmdir /S /Q snap
goto :done_ok

:do_restore
set types[0]=conf
set types[1]=data

set type_index=0

:restore_type_loop
call set typ=%%types[!type_index!]%%

if not "!typ!"=="" (
  set app_index=0
  :restore_app_folders_loop
  call set app=%%apps[!app_index!]%%

  if not "!app!"=="" (
    set live_folders=!app!_!typ!_live_folders
    set snap_folders=!app!_!typ!_snap_folders

    call set check_live_folders=%%!live_folders![0]%%

    if not "!check_live_folders!"=="" (
      echo restoring !app! !typ! folders

      set live_folders_index=0

      :restore_live_folders_loop
      call set live_folder=%%!live_folders![!live_folders_index!]%%

      if not "!live_folder!"=="" (
        call set snap_folder=%%!snap_folders![!live_folders_index!]%%

        echo restoring snap\!snap_folder! to !live_folder!

        echo removing !live_folder!.old
        rmdir /S /Q !live_folder!.old

        echo moving !live_folder! to !live_folder!.old
        move !live_folder! !live_folder!.old

        echo copying snap\!snap_folder! to !live_folder!
        xcopy /I /Y /S /E /H /Q "snap\!snap_folder!" "!live_folder!" 

        set /a live_folders_index+=1
        goto restore_live_folders_loop
      )

      echo:
    )

    set /a app_index+=1
    goto restore_app_folders_loop
  )

  set app_index=0
  :restore_app_files_loop
  call set app=%%apps[!app_index!]%%

  if not "!app!"=="" (
    set live_files=!app!_!typ!_live_files
    set snap_files=!app!_!typ!_snap_files

    call set check_live_files=%%!live_files![0]%%

    if not "!check_live_files!"=="" (
      echo restoring !app! !typ! files

      set live_files_index=0

      :restore_live_files_loop
      call set live_file=%%!live_files![!live_files_index!]%%

      if not "!live_file!"=="" (
        call set snap_file=%%!snap_files![!live_files_index!]%%

        echo restoring snap\!snap_file! to !live_file!

        echo removing !live_file!.old
        del !live_file!.old

        echo moving !live_file! to !live_file!.old
        move "!live_file!" "!live_file!.old"

        echo copying snap\!snap_file! to !live_file!
        xcopy /I /Y /S /E /H /Q "snap\!snap_file!" "!live_file!*"

        set /a live_files_index+=1
        goto restore_live_files_loop
      )

      echo: 
    )

    set /a app_index+=1
    goto restore_app_files_loop
  )

  set /a type_index+=1
  goto restore_type_loop
)
goto :done_ok

:do_clean
set types[0]=data

set type_index=0

:clean_type_loop
call set typ=%%types[!type_index!]%%

if not "!typ!"=="" (
  set app_index=0
  :clean_app_folders_loop
  call set app=%%apps[!app_index!]%%

  if not "!app!"=="" (
    set live_folders=!app!_!typ!_live_folders

    call set check_live_folders=%%!live_folders![0]%%

    if not "!check_live_folders!"=="" (
      echo cleaning !app! !typ! folders

      set live_folders_index=0

      :clean_live_folders_loop
      call set live_folder=%%!live_folders![!live_folders_index!]%%

      if not "!live_folder!"=="" (
        echo cleaning !live_folder!

        echo removing !live_folder!.old
        rmdir /S /Q !live_folder!.old

        echo moving !live_folder! to !live_folder!.old
        move !live_folder! !live_folder!.old

        set /a live_folders_index+=1
        goto clean_live_folders_loop
      )

      echo:
    )

    set /a app_index+=1
    goto clean_app_folders_loop
  )

  set app_index=0
  :clean_app_files_loop
  call set app=%%apps[!app_index!]%%

  if not "!app!"=="" (
    set live_files=!app!_!typ!_live_files

    call set check_live_files=%%!live_files![0]%%

    if not "!check_live_files!"=="" (
      echo cleaning !app! !typ! files

      set live_files_index=0

      :clean_live_files_loop
      call set live_file=%%!live_files![!live_files_index!]%%

      if not "!live_file!"=="" (
        echo cleaning !live_file!

        echo removing !live_file!.old
        del !live_file!.old

        echo moving !live_file! to !live_file!.old
        move "!live_file!" "!live_file!.old"

        set /a live_files_index+=1
        goto clean_live_files_loop
      )

      echo: 
    )

    set /a app_index+=1
    goto clean_app_files_loop
  )

  set /a type_index+=1
  goto clean_type_loop
)
goto :done_ok

:do_repo
set types[0]=conf

set type_index=0

:repo_type_loop
call set typ=%%types[!type_index!]%%

if not "!typ!"=="" (
  set app_index=0
  :repo_app_folders_loop
  call set app=%%apps[!app_index!]%%

  if not "!app!"=="" (
    set live_folders=!app!_!typ!_live_folders
    set repo_folders=!app!_!typ!_repo_folders

    call set check_live_folders=%%!live_folders![0]%%

    if not "!check_live_folders!"=="" (
      echo installing !app! !typ! folders

      set live_folders_index=0

      :repo_live_folders_loop
      call set live_folder=%%!live_folders![!live_folders_index!]%%

      if not "!live_folder!"=="" (
        call set repo_folder=%%!repo_folders![!live_folders_index!]%%

        echo installing !repo_folder! to !live_folder!

        echo removing !live_folder!.old
        rmdir /S /Q !live_folder!.old

        echo moving !live_folder! to !live_folder!.old
        move !live_folder! !live_folder!.old

        echo copying !repo_folder! to !live_folder!
        xcopy /I /Y /S /E /H /Q "!repo_folder!" "!live_folder!" 

        set /a live_folders_index+=1
        goto repo_live_folders_loop
      )

      echo:
    )

    set /a app_index+=1
    goto repo_app_folders_loop
  )

  set app_index=0
  :repo_app_files_loop
  call set app=%%apps[!app_index!]%%

  if not "!app!"=="" (
    set live_files=!app!_!typ!_live_files
    set repo_files=!app!_!typ!_repo_files

    call set check_live_files=%%!live_files![0]%%

    if not "!check_live_files!"=="" (
      echo installing !app! !typ! files

      set live_files_index=0

      :repo_live_files_loop
      call set live_file=%%!live_files![!live_files_index!]%%

      if not "!live_file!"=="" (
        call set repo_file=%%!repo_files![!live_files_index!]%%

        echo installing !repo_file! to !live_file!

        echo removing !live_file!.old
        del !live_file!.old

        echo moving !live_file! to !live_file!.old
        move "!live_file!" "!live_file!.old"

        echo copying !repo_file! to !live_file!
        xcopy /I /Y /S /E /H /Q "!repo_file!" "!live_file!*"

        set /a live_files_index+=1
        goto repo_live_files_loop
      )

      echo: 
    )

    set /a app_index+=1
    goto repo_app_files_loop
  )

  set /a type_index+=1
  goto repo_type_loop
)
goto :done_ok

:usage
echo usage: %%~nx0 ^<snap^|restore^|clean^|repo^>
goto :done_err

:done_ok
endlocal & exit /b 0

:done_err
endlocal & exit /b 1

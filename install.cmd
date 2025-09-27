@echo off
setlocal enabledelayedexpansion

call profiles\windows\apps.cmd

if /I [%1]==[bootstrap] (
  call profiles\windows\apps.cmd bootstrap
  goto end
)

call scripts\subcommands.cmd %*

:end

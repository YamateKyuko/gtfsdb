@echo off
REM filepath: run_script.bat
REM PowerShellの現在のディレクトリを取得してWSLパスに変換し、スクリプトを実行

REM シェルスクリプト名を指定
set SCRIPT_NAME=t.sh

REM 現在のディレクトリを取得
for /f "delims=" %%i in ('powershell -NoProfile -Command "((Get-Location).Path)"') do set WIN_CUR_DIR=%%i

REM WindowsパスをWSLパスに変換
set WSL_CUR_DIR=%WIN_CUR_DIR:\=/%
@REM set WSL_CUR_DIR=%WIN_CUR_DIR%
set WSL_CUR_DIR=/mnt/%WSL_CUR_DIR:~0,1%%WSL_CUR_DIR:~2%

echo "%WSL_CUR_DIR%/%SCRIPT_NAME%"

REM WSLでシェルスクリプトを実行
wsl bash "%WSL_CUR_DIR%/%SCRIPT_NAME%"
chcp 65001
@echo off
setlocal enabledelayedexpansion

:: 检查 Python 是否已安装
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python 未检测到！请先安装 Python 并将其添加到 PATH 中。
    pause
    exit /b 1
)

:: 检查 Pillow 和 pillow_heif 是否已安装，若未安装则自动安装
pip show Pillow >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在安装 Pillow...
    pip install Pillow
)
pip show pillow_heif >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在安装 pillow_heif...
    pip install pillow_heif
)

:: 提示用户输入参数
echo HEIC 批量转换工具 - 毛毛版
echo.

:: 设置默认值
set "input_dir=HEIC"
set "output_dir=JPG"
set "quality=85"
set "recursive=--recursive"

:: 提示用户输入参数
echo 一直按回车！
echo.
echo 请输入 HEIC 文件的文件夹路径（默认为当前目录下的 'HEIC' 文件夹）：
set /p "input_dir="
if "%input_dir%"=="" set "input_dir=HEIC"

echo 请指定输出文件夹路径（默认为当前目录下的 'JPG' 文件夹）：
set /p "output_dir="
if "%output_dir%"=="" set "output_dir=JPG"

echo 请设置 JPG 质量（1-100，默认为 100，质量越低JPG文件大小越小越不高清）：
set /p "quality="
if "%quality%"=="" set "quality=100"
set /a quality=quality 2>nul
if %quality% lss 1 set "quality=100"
if %quality% gtr 100 set "quality=100"

echo 是否递归处理子目录？(y/n，默认为 y)：
set /p "recursive_choice="
if /i "%recursive_choice%"=="n" set "recursive="

:: 运行转换脚本
echo.
echo 正在转换啦啦啦啦
python heic2jpg.py "%input_dir%" -o "%output_dir%" -q %quality% %recursive%

:: 检查脚本是否成功运行
if %errorlevel% equ 0 (
    echo 成功啊啊啊啊啊♥！
    pause
    exit /b 0
) else (
    echo 转换过程中发生错误，程序已中断。
    pause
    exit /b 1
)
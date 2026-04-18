@echo off
echo ========================================
echo   使用 CMake+MinGW 构建 AutoQtPacker (增强版)
echo ========================================
echo.

REM 设置路径
set QT_DIR=D:\Qt\6.7.3\mingw_64
set CMAKE_PATH=cmake.exe
set MINGW_MAKE_PATH=mingw32-make.exe

REM 检查工具
echo 检查构建工具...
echo 查找 CMake...

REM 首先尝试在 PATH 中查找
where %CMAKE_PATH% >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo CMake 未在 PATH 中找到，尝试常见安装位置...
    
    REM 尝试常见 CMake 安装位置
    if exist "C:\Program Files\CMake\bin\cmake.exe" (
        set CMAKE_PATH="C:\Program Files\CMake\bin\cmake.exe"
        echo 找到 CMake: %CMAKE_PATH%
    ) else if exist "C:\Program Files (x86)\CMake\bin\cmake.exe" (
        set CMAKE_PATH="C:\Program Files (x86)\CMake\bin\cmake.exe"
        echo 找到 CMake: %CMAKE_PATH%
    ) else if exist "%USERPROFILE%\AppData\Local\Programs\CMake\bin\cmake.exe" (
        set CMAKE_PATH="%USERPROFILE%\AppData\Local\Programs\CMake\bin\cmake.exe"
        echo 找到 CMake: %CMAKE_PATH%
    ) else if exist "D:\Program Files\CMake\bin\cmake.exe" (
        set CMAKE_PATH="D:\Program Files\CMake\bin\cmake.exe"
        echo 找到 CMake: %CMAKE_PATH%
    ) else (
        echo 错误: 未找到 CMake
        echo.
        echo 可能的解决方案:
        echo 1. 安装 CMake 并添加到 PATH
        echo 2. 修改脚本中的 CMAKE_PATH 变量
        echo 3. 手动指定 CMake 路径: set CMAKE_PATH="您的 CMake 路径"
        echo.
        echo 常见安装位置:
        echo - C:\Program Files\CMake\bin\cmake.exe
        echo - C:\Program Files (x86)\CMake\bin\cmake.exe
        echo - %USERPROFILE%\AppData\Local\Programs\CMake\bin\cmake.exe
        pause
        exit /b 1
    )
) else (
    echo 找到 CMake: %CMAKE_PATH%
)

where %MINGW_MAKE_PATH% >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo 警告: mingw32-make 未在 PATH 中找到
    echo 尝试在 Qt Tools 目录中查找...
    if exist "D:\Qt\Tools\mingw1120_64\bin\mingw32-make.exe" (
        set MINGW_MAKE_PATH=D:\Qt\Tools\mingw1120_64\bin\mingw32-make.exe
    ) else if exist "C:\MinGW\bin\mingw32-make.exe" (
        set MINGW_MAKE_PATH=C:\MinGW\bin\mingw32-make.exe
    ) else (
        echo 错误: 未找到 mingw32-make
        echo 请确保 MinGW 已安装
        pause
        exit /b 1
    )
)

REM 检查 Qt 路径
if not exist "%QT_DIR%\bin\qmake.exe" (
    echo 警告: 未在默认路径找到 Qt 6.7.3
    echo 当前路径: %QT_DIR%
    echo 请确保 Qt 6.7.3 已安装在 D:\Qt\6.7.3
    echo 或修改脚本中的 QT_DIR 变量
)

echo 使用工具:
echo - CMake: %CMAKE_PATH%
echo - Make: %MINGW_MAKE_PATH%
echo - QT: %QT_DIR%

REM ========================================
REM 版本管理逻辑
REM ========================================
set BUILD_CONFIG_FILE=build_version.txt

REM 初始化或读取版本配置
if not exist "%BUILD_CONFIG_FILE%" (
    echo 初始化构建版本配置...
    echo major=1> "%BUILD_CONFIG_FILE%"
    echo minor=0>> "%BUILD_CONFIG_FILE%"
    echo patch=0>> "%BUILD_CONFIG_FILE%"
)

REM 读取当前版本
set major=1
set minor=0
set patch=0
for /f "tokens=1,2 delims==" %%a in (%BUILD_CONFIG_FILE%) do (
    if "%%a"=="major" set major=%%b
    if "%%a"=="minor" set minor=%%b
    if "%%a"=="patch" set patch=%%b
)

echo 当前构建版本: v%major%.%minor%.%patch%

REM 计算下一个版本（每次构建增加 patch 版本）
set /a new_patch=%patch% + 1
set new_major=%major%
set new_minor=%minor%

REM 更新版本配置
echo major=%new_major%> "%BUILD_CONFIG_FILE%"
echo minor=%new_minor%>> "%BUILD_CONFIG_FILE%"
echo patch=%new_patch%>> "%BUILD_CONFIG_FILE%"

echo 构建版本: v%new_major%.%new_minor%.%new_patch%

REM 设置构建目录名
set BUILD_DIR=AutoQtPacker_windows_v%major%.%minor%.%patch%
echo 构建目录: %BUILD_DIR%

REM ========================================
REM 清理旧的构建目录
echo 清理旧的构建目录...
if exist "%BUILD_DIR%" (
    rmdir /s /q "%BUILD_DIR%"
    echo 构建目录已删除: %BUILD_DIR%
)

REM 保存当前目录
set CURRENT_DIR=%cd%

REM 创建新的构建目录
echo 创建新的构建目录...
mkdir "%BUILD_DIR%"

REM 配置项目
echo 配置项目...
cd "%BUILD_DIR%"
"%CMAKE_PATH%" -G "MinGW Makefiles" ^
    -DCMAKE_PREFIX_PATH="D:/Qt/6.7.3" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DAUTOQTPACKER_VERSION="v%major%.%minor%.%patch%" ^
    "%CURRENT_DIR%"

if %ERRORLEVEL% neq 0 (
    echo CMake 配置失败
    echo 源目录: %CURRENT_DIR%
    cd ..
    pause
    exit /b 1
)

REM 构建项目
echo 构建项目...
"%MINGW_MAKE_PATH%"
if %ERRORLEVEL% neq 0 (
    echo 构建失败
    cd ..
    pause
    exit /b 1
)

echo.
echo ========================================
echo   构建成功!
echo ========================================
echo 构建版本: v%major%.%minor%.%patch%
echo 构建时间: %date% %time%
echo 可执行文件: %BUILD_DIR%\bin\AutoQtPacker.exe
echo.
echo 运行程序:
echo 1. 双击 %BUILD_DIR%\bin\AutoQtPacker.exe
echo 2. 或使用命令行: .\%BUILD_DIR%\bin\AutoQtPacker.exe
echo 3. 或使用 VSCode 的 "Run AutoQtPacker" 任务
echo.
echo 打包其他 Qt 项目:
echo 1. 运行 AutoQtPacker.exe
echo 2. 选择要打包的 Qt 项目目录
echo 3. 选择构建模式 (Debug/Release)
echo 4. 点击"开始打包"按钮
echo ========================================
echo.

REM 返回上级目录
cd ..

pause

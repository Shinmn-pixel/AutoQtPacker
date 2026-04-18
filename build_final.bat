@echo off
echo ========================================
echo   使用CMake+MinGW构建 AutoQtPacker (最终版)
echo ========================================
echo.

REM 设置路径
set QT_DIR=D:\Qt\6.7.3\mingw_64
set CMAKE_PATH=cmake.exe
set MINGW_MAKE_PATH=mingw32-make.exe

REM 检查工具
echo 检查构建工具...

REM 检查 CMake
where cmake >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo CMake未在PATH中找到，尝试常见位置...
    if exist "C:\Program Files\CMake\bin\cmake.exe" (
        set CMAKE_PATH=C:\Program Files\CMake\bin\cmake.exe
    ) else if exist "C:\Program Files (x86)\CMake\bin\cmake.exe" (
        set CMAKE_PATH=C:\Program Files (x86)\CMake\bin\cmake.exe
    ) else if exist "E:\mingw64\bin\cmake.exe" (
        set CMAKE_PATH=E:\mingw64\bin\cmake.exe
    ) else (
        echo 错误: CMake未找到
        echo 请安装CMake或修改脚本中的路径
        pause
        exit /b 1
    )
) else (
    set CMAKE_PATH=cmake
)

REM 检查 mingw32-make
if not exist "%MINGW_MAKE_PATH%" (
    echo 警告: mingw32-make未在默认路径找到
    echo 尝试在PATH中查找...
    where mingw32-make >nul 2>nul
    if %ERRORLEVEL% neq 0 (
        echo 尝试在Qt Tools目录中查找...
        if exist "D:\Qt\Tools\mingw1120_64\bin\mingw32-make.exe" (
            set MINGW_MAKE_PATH=D:\Qt\Tools\mingw1120_64\bin\mingw32-make.exe
        ) else if exist "C:\MinGW\bin\mingw32-make.exe" (
            set MINGW_MAKE_PATH=C:\MinGW\bin\mingw32-make.exe
        ) else (
            echo 错误: 未找到mingw32-make
            echo 请确保MinGW已安装
            pause
            exit /b 1
        )
    ) else (
        set MINGW_MAKE_PATH=mingw32-make
    )
)

echo 使用工具:
echo - CMake: %CMAKE_PATH%
echo - Make: %MINGW_MAKE_PATH%
echo - QT: %QT_DIR%

REM 备份原始的CMakeLists.txt
echo 备份原始CMakeLists.txt...
if exist CMakeLists.txt.bak del CMakeLists.txt.bak
if exist CMakeLists.txt copy CMakeLists.txt CMakeLists.txt.bak >nul

REM 修改CMakeLists.txt使用MinGW路径
echo 修改CMakeLists.txt使用MinGW路径...
(
echo cmake_minimum_required(VERSION 3.18)
echo project(AutoQtPacker LANGUAGES CXX)
echo.
echo set(CMAKE_CXX_STANDARD 17)
echo set(CMAKE_CXX_STANDARD_REQUIRED ON)
echo set(CMAKE_AUTOMOC ON)
echo set(CMAKE_AUTORCC ON)
echo set(CMAKE_AUTOUIC ON)
echo.
echo # 使用MinGW版本的QT
echo set(QT6_PATH "%QT_DIR:\=/%")
echo set(CMAKE_PREFIX_PATH ^${QT6_PATH}^)
echo.
echo find_package(Qt6 COMPONENTS Widgets Core Concurrent REQUIRED)
echo.
echo include_directories(^${CMAKE_CURRENT_SOURCE_DIR}^)
echo.
echo set(SOURCES
echo     main.cpp
echo     MainWindow.cpp
echo     PackerTask.cpp
echo )
echo.
echo set(HEADERS
echo     MainWindow.h
echo     PackerTask.h
echo )
echo.
echo set(FORMS
echo     MainWindow.ui
echo )
echo.
echo set(RESOURCES
echo     resources.qrc
echo )
echo.
echo add_executable(AutoQtPacker WIN32 ^${SOURCES}^ ^${HEADERS}^ ^${FORMS}^ ^${RESOURCES}^)
echo.
echo target_link_libraries(AutoQtPacker 
echo     Qt6::Widgets 
echo     Qt6::Core 
echo     Qt6::Concurrent
echo )
echo.
echo # 设置输出目录
echo set_target_properties(AutoQtPacker PROPERTIES
echo     RUNTIME_OUTPUT_DIRECTORY ^${CMAKE_BINARY_DIR}^/bin
echo     ARCHIVE_OUTPUT_DIRECTORY ^${CMAKE_BINARY_DIR}^/lib
echo     LIBRARY_OUTPUT_DIRECTORY ^${CMAKE_BINARY_DIR}^/lib
echo )
) > CMakeLists.txt

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

REM 计算下一个版本
set /a new_patch=%patch% + 1
set new_major=%major%
set new_minor=%minor%

if %new_patch% gtr 9 (
    set /a new_minor=%minor% + 1
    set new_patch=0
)

if %new_minor% gtr 9 (
    set /a new_major=%major% + 1
    set new_minor=0
)

REM 更新版本配置
echo major=%new_major%> "%BUILD_CONFIG_FILE%"
echo minor=%new_minor%>> "%BUILD_CONFIG_FILE%"
echo patch=%new_patch%>> "%BUILD_CONFIG_FILE%"

echo 下一个构建版本: v%new_major%.%new_minor%.%new_patch%

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

REM 创建新的构建目录
echo 创建新的构建目录...
mkdir "%BUILD_DIR%"

REM 保存当前目录
set CURRENT_DIR=%cd%

REM 配置项目
echo 配置项目...
cd "%BUILD_DIR%"

REM 检查 CMAKE_PATH 是否包含空格，如果是则添加引号
echo %CMAKE_PATH% | findstr /C:" " >nul
if %ERRORLEVEL% equ 0 (
    set QUOTED_CMAKE_PATH="%CMAKE_PATH%"
) else (
    set QUOTED_CMAKE_PATH=%CMAKE_PATH%
)

call %QUOTED_CMAKE_PATH% -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release "%CURRENT_DIR%"
if %ERRORLEVEL% neq 0 (
    echo CMake配置失败
    cd ..
    goto :restore_cmake
)

REM 构建项目
echo 构建项目...
"%MINGW_MAKE_PATH%"
if %ERRORLEVEL% neq 0 (
    echo 构建失败
    cd ..
    goto :restore_cmake
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
echo.
echo 打包其他Qt项目:
echo 1. 运行AutoQtPacker.exe
echo 2. 选择要打包的Qt项目目录
echo 3. 选择构建模式(Debug/Release)
echo 4. 点击"开始打包"按钮
echo ========================================

:restore_cmake
REM 恢复原始的CMakeLists.txt
cd ..
if exist CMakeLists.txt.bak (
    echo 恢复原始CMakeLists.txt...
    copy CMakeLists.txt.bak CMakeLists.txt >nul
    del CMakeLists.txt.bak
)

pause

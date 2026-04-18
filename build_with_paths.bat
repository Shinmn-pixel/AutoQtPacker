@echo off
echo ========================================
echo   AutoQtPacker 带路径构建脚本
echo ========================================
echo.

REM 设置硬编码路径（根据用户系统修改）
set QT_DIR=D:\Qt\6.7.3\mingw_64
set CMAKE_PATH=C:\Program Files\CMake\bin\cmake.exe
set MINGW_MAKE_PATH=D:\Qt\Tools\mingw1120_64\bin\mingw32-make.exe

echo 使用以下路径:
echo - Qt: %QT_DIR%
echo - CMake: %CMAKE_PATH%
echo - Make: %MINGW_MAKE_PATH%
echo.

REM 检查工具是否存在
echo 检查工具...
if not exist "%CMAKE_PATH%" (
    echo 错误: CMake未找到: %CMAKE_PATH%
    echo 请修改脚本中的 CMAKE_PATH 变量
    echo 或安装 CMake 到该路径
    pause
    exit /b 1
)

if not exist "%MINGW_MAKE_PATH%" (
    echo 警告: mingw32-make未在默认路径找到
    echo 尝试在PATH中查找...
    where mingw32-make >nul 2>nul
    if %ERRORLEVEL% neq 0 (
        echo 错误: 未找到mingw32-make
        echo 请确保MinGW已安装
        echo 或修改脚本中的 MINGW_MAKE_PATH 变量
        pause
        exit /b 1
    )
    set MINGW_MAKE_PATH=mingw32-make
)

if not exist "%QT_DIR%\bin\qmake.exe" (
    echo 警告: Qt未在默认路径找到
    echo 当前路径: %QT_DIR%
    echo 请确保Qt 6.7.3已安装
    echo 或修改脚本中的 QT_DIR 变量
)

echo 工具检查通过!
echo.

REM 备份原始的CMakeLists.txt
echo 备份原始CMakeLists.txt...
if exist CMakeLists.txt.bak del CMakeLists.txt.bak
if exist CMakeLists.txt copy CMakeLists.txt CMakeLists.txt.bak >nul

REM 创建简单的CMakeLists.txt
echo 创建CMakeLists.txt...
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
echo set(CMAKE_PREFIX_PATH "D:/Qt/6.7.3")
echo.
echo find_package(Qt6 COMPONENTS Widgets Core Concurrent REQUIRED)
echo.
echo include_directories(.)
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
echo     MainWindow_fixed.ui
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

REM 创建构建目录
echo 创建构建目录...
if exist build_with_paths rmdir /s /q build_with_paths
mkdir build_with_paths
cd build_with_paths

REM 配置项目
echo 配置项目...
"%CMAKE_PATH%" -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release ..
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
echo 可执行文件: build_with_paths\bin\AutoQtPacker.exe
echo.
echo 运行程序:
echo 1. 双击 build_with_paths\bin\AutoQtPacker.exe
echo 2. 或使用命令行: build_with_paths\bin\AutoQtPacker.exe
echo.
echo 注意: 如果程序无法启动，可能需要:
echo 1. 将 %QT_DIR%\bin 添加到 PATH
echo 2. 或将必要的 Qt DLL 复制到 bin 目录
echo ========================================

:restore_cmake
REM 恢复原始的CMakeLists.txt
cd ..
if exist CMakeLists.txt.bak (
    echo 恢复原始CMakeLists.txt...
    copy CMakeLists.txt.bak CMakeLists.txt >nul
    del CMakeLists.txt.bak
)

echo.
pause

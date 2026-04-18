@echo off
echo ========================================
echo   AutoQtPacker 简单构建脚本
echo ========================================
echo.

REM 这个脚本假设所有工具都在 PATH 中
REM 如果没有，请先安装并配置：
REM 1. CMake: https://cmake.org/download/
REM 2. MinGW: https://www.mingw-w64.org/
REM 3. Qt 6.7.3: https://www.qt.io/download

echo 检查必要工具...
where cmake >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: 未找到 CMake
    echo 请从 https://cmake.org/download/ 下载并安装 CMake
    echo 安装时选择 "Add CMake to the system PATH"
    pause
    exit /b 1
)

where mingw32-make >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: 未找到 MinGW make
    echo 请从 https://www.mingw-w64.org/ 下载并安装 MinGW-w64
    echo 或将 MinGW\bin 目录添加到 PATH
    pause
    exit /b 1
)

echo 检查 Qt 路径...
if not exist "D:\Qt\6.7.3\mingw_64\bin\qmake.exe" (
    echo 警告: 未在默认路径找到 Qt 6.7.3
    echo 请确保 Qt 6.7.3 已安装在 D:\Qt\6.7.3
    echo 或修改下面的 QT_PATH 变量
)

echo.
echo 工具检查通过!
echo - CMake: 已找到
echo - MinGW make: 已找到
echo - Qt: 使用 D:\Qt\6.7.3
echo.

REM 保存当前目录
set CURRENT_DIR=%cd%

REM 创建构建目录
if exist "build" (
    echo 清理旧的构建目录...
    rmdir /s /q build
)

echo 创建构建目录...
mkdir build

echo.
echo ========================================
echo 配置 CMake 项目...
echo ========================================
echo.

REM 配置项目（使用完整路径）
cmake -G "MinGW Makefiles" ^
    -DCMAKE_PREFIX_PATH="D:/Qt/6.7.3" ^
    -DCMAKE_BUILD_TYPE=Release ^
    "%CURRENT_DIR%"

if %errorlevel% neq 0 (
    echo.
    echo 错误: CMake 配置失败
    echo 可能的原因:
    echo 1. Qt 路径不正确
    echo 2. MinGW 编译器未正确安装
    echo 3. CMake 版本太旧
    echo 4. 当前目录: %CURRENT_DIR%
    pause
    exit /b 1
)

REM 进入构建目录进行构建
cd build

echo.
echo ========================================
echo 构建项目...
echo ========================================
echo.

REM 构建项目
cmake --build . --config Release

if %errorlevel% neq 0 (
    echo.
    echo 错误: 构建失败
    echo 请检查上面的错误信息
    pause
    exit /b 1
)

echo.
echo ========================================
echo 构建成功！
echo ========================================
echo.
echo 可执行文件位置: build\bin\AutoQtPacker.exe
echo.
echo 运行程序:
echo   1. 直接运行 build\bin\AutoQtPacker.exe
echo   2. 或使用 VSCode 的 "Run AutoQtPacker" 任务
echo.
echo 如果程序无法启动，可能需要:
echo   1. 将 D:\Qt\6.7.3\mingw_64\bin 添加到 PATH
echo   2. 或将必要的 Qt DLL 复制到 build\bin 目录
echo.
pause

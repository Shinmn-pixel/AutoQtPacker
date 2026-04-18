@echo off
echo ========================================
echo   AutoQtPacker 调试构建脚本
echo ========================================
echo.

echo 当前目录: %cd%
echo.

echo 步骤1: 检查基本工具...
echo.

REM 检查 cmake
where cmake >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] CMake 已找到
    set CMAKE_PATH=cmake
) else (
    echo [错误] CMake 未找到
    echo 请安装 CMake 并添加到 PATH
    echo 或手动指定 CMake 路径
    pause
    exit /b 1
)

REM 检查 mingw32-make
where mingw32-make >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] mingw32-make 已找到
    set MAKE_PATH=mingw32-make
) else (
    echo [警告] mingw32-make 未找到
    echo 尝试查找 make...
    where make >nul 2>nul
    if %errorlevel% equ 0 (
        echo [OK] make 已找到
        set MAKE_PATH=make
    ) else (
        echo [错误] 未找到 make 或 mingw32-make
        echo 请安装 MinGW 并添加到 PATH
        pause
        exit /b 1
    )
)

echo.
echo 步骤2: 检查 Qt 路径...
echo.

set QT_PATH=D:\Qt\6.7.3
if exist "%QT_PATH%\mingw_64\bin\qmake.exe" (
    echo [OK] Qt 6.7.3 已找到: %QT_PATH%
) else (
    echo [警告] Qt 6.7.3 未在默认路径找到
    echo 请确保 Qt 已安装在 D:\Qt\6.7.3
    echo 或修改脚本中的 QT_PATH 变量
)

echo.
echo 步骤3: 创建构建目录...
echo.

if exist "build_debug" (
    echo 删除旧的构建目录...
    rmdir /s /q build_debug
)

mkdir build_debug
if %errorlevel% neq 0 (
    echo [错误] 无法创建构建目录
    pause
    exit /b 1
)

echo [OK] 构建目录已创建: build_debug

echo.
echo 步骤4: 配置 CMake 项目...
echo.

cd build_debug
echo 当前目录: %cd%

echo 执行命令: %CMAKE_PATH% -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="D:/Qt/6.7.3" -DCMAKE_BUILD_TYPE=Release ..
%CMAKE_PATH% -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="D:/Qt/6.7.3" -DCMAKE_BUILD_TYPE=Release ..

if %errorlevel% neq 0 (
    echo.
    echo [错误] CMake 配置失败
    echo 可能的原因:
    echo 1. Qt 路径不正确
    echo 2. CMake 版本不兼容
    echo 3. 缺少必要的工具
    cd ..
    pause
    exit /b 1
)

echo.
echo [OK] CMake 配置成功

echo.
echo 步骤5: 构建项目...
echo.

echo 执行命令: %MAKE_PATH%
%MAKE_PATH%

if %errorlevel% neq 0 (
    echo.
    echo [错误] 构建失败
    echo 请检查上面的错误信息
    cd ..
    pause
    exit /b 1
)

echo.
echo [OK] 构建成功

echo.
echo 步骤6: 检查生成的可执行文件...
echo.

if exist "bin\AutoQtPacker.exe" (
    echo [OK] 可执行文件已生成: bin\AutoQtPacker.exe
    echo.
    echo ========================================
    echo   构建完成！
    echo ========================================
    echo.
    echo 可执行文件位置: build_debug\bin\AutoQtPacker.exe
    echo.
    echo 运行程序:
    echo   1. 双击 build_debug\bin\AutoQtPacker.exe
    echo   2. 或使用命令行: build_debug\bin\AutoQtPacker.exe
    echo.
    echo 文件大小: 
    for %%F in ("bin\AutoQtPacker.exe") do echo   %%~zF 字节
) else (
    echo [警告] 未找到可执行文件
    echo 检查构建输出目录...
    dir /s /b *.exe
)

echo.
echo ========================================
echo   脚本执行完成
echo ========================================
echo.
cd ..
pause

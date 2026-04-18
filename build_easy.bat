@echo off
echo AutoQtPacker 简单构建脚本
echo.
echo 按任意键开始构建，或按 Ctrl+C 取消...
pause >nul

echo.
echo 1. 检查工具...
where cmake >nul 2>nul
if errorlevel 1 (
    echo 错误: 未找到 CMake
    echo 请先安装 CMake 并添加到 PATH
    pause
    exit /b 1
)

where mingw32-make >nul 2>nul
if errorlevel 1 (
    echo 警告: 未找到 mingw32-make，尝试查找 make...
    where make >nul 2>nul
    if errorlevel 1 (
        echo 错误: 未找到 make
        echo 请安装 MinGW 并添加到 PATH
        pause
        exit /b 1
    )
)

echo 工具检查通过!
echo.

echo 2. 创建构建目录...
if exist build_easy rmdir /s /q build_easy
mkdir build_easy
cd build_easy

echo.
echo 3. 配置项目...
cmake -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="D:/Qt/6.7.3" -DCMAKE_BUILD_TYPE=Release ..
if errorlevel 1 (
    echo CMake 配置失败
    cd ..
    pause
    exit /b 1
)

echo.
echo 4. 构建项目...
mingw32-make
if errorlevel 1 (
    echo 构建失败，尝试使用 make...
    make
    if errorlevel 1 (
        echo 构建失败
        cd ..
        pause
        exit /b 1
    )
)

echo.
echo 5. 检查结果...
if exist bin\AutoQtPacker.exe (
    echo 构建成功!
    echo.
    echo 可执行文件: %cd%\bin\AutoQtPacker.exe
    echo.
    echo 要运行程序，请执行:
    echo   bin\AutoQtPacker.exe
) else (
    echo 警告: 未找到可执行文件
    echo 检查目录内容:
    dir /b
)

echo.
cd ..
pause

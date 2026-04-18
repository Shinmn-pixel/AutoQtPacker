@echo off
echo ========================================
echo   AutoQtPacker 环境诊断脚本
echo ========================================
echo.

echo 1. 检查当前目录和系统信息
echo 当前目录: %cd%
echo 系统路径: %PATH%
echo.

echo 2. 检查 CMake...
where cmake
if %errorlevel% equ 0 (
    echo [OK] CMake 在 PATH 中找到
) else (
    echo [错误] CMake 未在 PATH 中找到
    echo.
    echo 检查常见 CMake 安装位置:
    if exist "C:\Program Files\CMake\bin\cmake.exe" (
        echo [找到] C:\Program Files\CMake\bin\cmake.exe
    ) else (
        echo [未找到] C:\Program Files\CMake\bin\cmake.exe
    )
    
    if exist "C:\Program Files (x86)\CMake\bin\cmake.exe" (
        echo [找到] C:\Program Files (x86)\CMake\bin\cmake.exe
    ) else (
        echo [未找到] C:\Program Files (x86)\CMake\bin\cmake.exe
    )
    
    if exist "%USERPROFILE%\AppData\Local\Programs\CMake\bin\cmake.exe" (
        echo [找到] %USERPROFILE%\AppData\Local\Programs\CMake\bin\cmake.exe
    ) else (
        echo [未找到] %USERPROFILE%\AppData\Local\Programs\CMake\bin\cmake.exe
    )
    
    if exist "E:\mingw64\bin\cmake.exe" (
        echo [找到] E:\mingw64\bin\cmake.exe
    ) else (
        echo [未找到] E:\mingw64\bin\cmake.exe
    )
)
echo.

echo 3. 检查 MinGW/make...
where mingw32-make
if %errorlevel% equ 0 (
    echo [OK] mingw32-make 在 PATH 中找到
) else (
    echo [警告] mingw32-make 未在 PATH 中找到
    where make
    if %errorlevel% equ 0 (
        echo [OK] make 在 PATH 中找到
    ) else (
        echo [错误] make 也未在 PATH 中找到
    )
)
echo.

echo 4. 检查 Qt...
set QT_PATH=D:\Qt\6.7.3
if exist "%QT_PATH%\mingw_64\bin\qmake.exe" (
    echo [OK] Qt 6.7.3 已安装: %QT_PATH%
    echo qmake 路径: %QT_PATH%\mingw_64\bin\qmake.exe
) else (
    echo [错误] Qt 6.7.3 未在默认路径找到
    echo 请检查 Qt 是否安装在 D:\Qt\6.7.3
)
echo.

echo 5. 检查构建目录...
if exist "build" (
    echo [找到] 构建目录存在: build
    dir build /b
) else (
    echo [未找到] 构建目录不存在
)
echo.

echo 6. 检查 CMakeLists.txt...
if exist "CMakeLists.txt" (
    echo [OK] CMakeLists.txt 存在
    echo 文件大小: 
    for %%F in ("CMakeLists.txt") do echo   %%~zF 字节
) else (
    echo [错误] CMakeLists.txt 不存在
)
echo.

echo 7. 建议解决方案:
echo.
echo 如果 CMake 未找到:
echo 1. 下载并安装 CMake: https://cmake.org/download/
echo 2. 安装时选择 "Add CMake to the system PATH for all users"
echo 3. 或手动将 CMake 的 bin 目录添加到 PATH 环境变量
echo.
echo 如果 MinGW 未找到:
echo 1. 下载 MinGW-w64: https://www.mingw-w64.org/
echo 2. 或将 Qt 自带的 MinGW 添加到 PATH: D:\Qt\Tools\mingw1120_64\bin
echo.
echo 如果 Qt 未找到:
echo 1. 下载并安装 Qt 6.7.3: https://www.qt.io/download
echo 2. 安装时选择 MinGW 组件
echo 3. 或修改脚本中的 QT_PATH 变量
echo.

echo ========================================
echo   诊断完成
echo ========================================
echo.
pause

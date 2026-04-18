@echo off
echo ========================================
echo   AutoQtPacker 简单验证脚本
echo ========================================
echo.

echo 这个脚本使用最基本的命令检查文件状态。
echo.

echo 1. 检查修复的文件...
echo.

if exist "MainWindow_fixed.ui" (
    echo [OK] MainWindow_fixed.ui 存在
) else (
    echo [错误] MainWindow_fixed.ui 不存在
    echo 请确保修复文件已创建
)

if exist "resources_fixed.qrc" (
    echo [OK] resources_fixed.qrc 存在
) else (
    echo [错误] resources_fixed.qrc 不存在
    echo 请确保修复文件已创建
)

echo.
echo 2. 检查关键源代码文件...
echo.

set ERROR_COUNT=0

if exist "main.cpp" (
    echo [OK] main.cpp 存在
) else (
    echo [错误] main.cpp 不存在
    set /a ERROR_COUNT+=1
)

if exist "MainWindow.cpp" (
    echo [OK] MainWindow.cpp 存在
) else (
    echo [错误] MainWindow.cpp 不存在
    set /a ERROR_COUNT+=1
)

if exist "MainWindow.h" (
    echo [OK] MainWindow.h 存在
) else (
    echo [错误] MainWindow.h 不存在
    set /a ERROR_COUNT+=1
)

if exist "PackerTask.cpp" (
    echo [OK] PackerTask.cpp 存在
) else (
    echo [错误] PackerTask.cpp 不存在
    set /a ERROR_COUNT+=1
)

if exist "PackerTask.h" (
    echo [OK] PackerTask.h 存在
) else (
    echo [错误] PackerTask.h 不存在
    set /a ERROR_COUNT+=1
)

if exist "CMakeLists.txt" (
    echo [OK] CMakeLists.txt 存在
) else (
    echo [错误] CMakeLists.txt 不存在
    set /a ERROR_COUNT+=1
)

echo.
echo 3. 检查结果...
echo.

if %ERROR_COUNT% equ 0 (
    echo [OK] 所有关键文件都存在
    echo.
    echo 建议使用以下命令构建:
    echo   build_with_paths.bat
    echo.
    echo 这个脚本会自动创建正确的 CMakeLists.txt
) else (
    echo [警告] 有 %ERROR_COUNT% 个文件缺失
    echo.
    echo 请确保所有源代码文件都存在。
    echo 如果文件缺失，可以从项目备份中恢复。
)

echo.
echo 4. 关于 CMakeLists.txt 的说明...
echo.
echo build_with_paths.bat 会自动创建正确的 CMakeLists.txt
echo 它会引用 MainWindow_fixed.ui 和 resources_fixed.qrc
echo.
echo 如果你使用其他构建脚本，可能需要:
echo 1. 手动更新 CMakeLists.txt
echo 2. 或运行 build_with_paths.bat 一次
echo 3. 然后使用其他构建脚本

echo.
echo ========================================
echo   验证完成
echo ========================================
echo.
pause

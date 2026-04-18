@echo off
echo ========================================
echo   AutoQtPacker 修复验证脚本
echo ========================================
echo.

echo 1. 检查修复的文件是否存在...
echo.

if exist "MainWindow_fixed.ui" (
    echo [OK] MainWindow_fixed.ui 存在
) else (
    echo [错误] MainWindow_fixed.ui 不存在
)

if exist "resources_fixed.qrc" (
    echo [OK] resources_fixed.qrc 存在
) else (
    echo [错误] resources_fixed.qrc 不存在
)

echo.
echo 2. 检查原始文件是否可能有问题...
echo.

if exist "MainWindow.ui" (
    echo [找到] MainWindow.ui 存在（原始文件）
    echo 注意: 构建脚本现在使用 MainWindow_fixed.ui
)

if exist "resources.qrc" (
    echo [找到] resources.qrc 存在（原始文件）
    echo 注意: 构建脚本现在使用 resources_fixed.qrc
)

echo.
echo 3. 检查源代码文件...
echo.

set FILE_COUNT=0
set MISSING_FILES=0

for %%f in (
    main.cpp
    MainWindow.cpp
    MainWindow.h
    PackerTask.cpp
    PackerTask.h
    MainWindow_fixed.ui
    resources_fixed.qrc
    CMakeLists.txt
) do (
    if exist "%%f" (
        echo [OK] %%f 存在
        set /a FILE_COUNT+=1
    ) else (
        echo [错误] %%f 不存在
        set /a MISSING_FILES+=1
    )
)

echo.
echo 4. 文件统计...
echo 总检查文件数: 8
echo 找到文件数: %FILE_COUNT%
echo 缺失文件数: %MISSING_FILES%

if %MISSING_FILES% gtr 0 (
    echo.
    echo [警告] 有文件缺失，构建可能失败
) else (
    echo.
    echo [OK] 所有必需文件都存在
)

echo.
echo 5. 检查 CMakeLists.txt 内容...
echo.

REM 使用更兼容的方法检查文件内容
type CMakeLists.txt | find "MainWindow_fixed.ui" >nul
if %errorlevel% equ 0 (
    echo [OK] CMakeLists.txt 引用 MainWindow_fixed.ui
) else (
    echo [警告] CMakeLists.txt 可能未引用 MainWindow_fixed.ui
    echo   注意: 如果使用 build_with_paths.bat，它会自动创建正确的 CMakeLists.txt
)

type CMakeLists.txt | find "resources_fixed.qrc" >nul
if %errorlevel% equ 0 (
    echo [OK] CMakeLists.txt 引用 resources_fixed.qrc
) else (
    echo [警告] CMakeLists.txt 可能未引用 resources_fixed.qrc
    echo   注意: 如果使用 build_with_paths.bat，它会自动创建正确的 CMakeLists.txt
)

echo.
echo 6. 建议...
echo.
echo 如果使用 build_with_paths.bat:
echo   脚本会自动创建正确的 CMakeLists.txt
echo.
echo 如果使用其他构建脚本:
echo   可能需要手动更新 CMakeLists.txt 中的文件引用
echo.
echo 修复总结:
echo 1. 创建了 MainWindow_fixed.ui - 移除了图标依赖
echo 2. 创建了 resources_fixed.qrc - 空资源文件
echo 3. 更新了 build_with_paths.bat - 使用修复后的文件
echo.
echo ========================================
echo   验证完成
echo ========================================
echo.
pause

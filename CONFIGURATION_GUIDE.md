# AutoQtPacker 配置指南

## 问题诊断

如果构建脚本报告 "无法找到 CMake"，请按照以下步骤解决：

## 1. 运行诊断脚本

首先运行诊断脚本来检查系统环境：
```
双击运行: AutoQtPacker\diagnose.bat
```

诊断脚本会检查：
- CMake 是否在 PATH 中
- MinGW/make 是否可用
- Qt 6.7.3 是否安装在正确位置
- 构建目录和 CMakeLists.txt 是否存在

## 2. 解决方案

### 方案 A: 安装缺失的工具

#### 安装 CMake
1. 下载 CMake: https://cmake.org/download/
2. 运行安装程序
3. **重要**: 安装时选择 "Add CMake to the system PATH for all users"
4. 完成安装后，重启命令提示符或 PowerShell

#### 安装 MinGW
1. 下载 MinGW-w64: https://www.mingw-w64.org/
2. 或使用 Qt 自带的 MinGW: `D:\Qt\Tools\mingw1120_64\bin`
3. 将 MinGW 的 bin 目录添加到系统 PATH

#### 安装 Qt 6.7.3
1. 下载 Qt Online Installer: https://www.qt.io/download
2. 运行安装程序
3. 选择 Qt 6.7.3 和 MinGW 组件
4. 安装到默认路径: `D:\Qt\6.7.3`

### 方案 B: 修改构建脚本路径

如果工具已安装但不在默认路径，修改构建脚本中的路径变量：

#### 修改 `build_with_paths.bat`
```batch
REM 设置硬编码路径（根据你的系统修改）
set QT_DIR=D:\Qt\6.7.3\mingw_64
set CMAKE_PATH=C:\Program Files\CMake\bin\cmake.exe
set MINGW_MAKE_PATH=D:\Qt\Tools\mingw1120_64\bin\mingw32-make.exe
```

根据你的实际安装位置修改：
- `QT_DIR`: Qt 安装目录
- `CMAKE_PATH`: CMake 可执行文件完整路径
- `MINGW_MAKE_PATH`: mingw32-make 可执行文件完整路径

### 方案 C: 手动添加到 PATH

如果不想修改脚本，可以将工具目录添加到系统 PATH：

1. 右键点击 "此电脑" → "属性" → "高级系统设置"
2. 点击 "环境变量"
3. 在 "系统变量" 中找到 "Path"，点击 "编辑"
4. 添加以下路径（根据实际安装位置）：
   ```
   C:\Program Files\CMake\bin
   D:\Qt\Tools\mingw1120_64\bin
   D:\Qt\6.7.3\mingw_64\bin
   ```
5. 点击 "确定" 保存
6. 重启所有命令提示符窗口

## 3. 构建脚本选择

根据你的情况选择合适的构建脚本：

### 脚本 1: `build_easy.bat` (推荐)
- **适用情况**: CMake 和 MinGW 已在 PATH 中
- **特点**: 最简单的脚本，有用户确认步骤
- **使用**: 双击运行，按任意键开始

### 脚本 2: `build_with_paths.bat`
- **适用情况**: 工具不在 PATH 中，但有固定安装位置
- **特点**: 使用硬编码路径，不需要 PATH
- **使用**: 可能需要修改脚本中的路径

### 脚本 3: `build_debug.bat`
- **适用情况**: 需要调试构建过程
- **特点**: 详细的步骤输出和错误信息
- **使用**: 适合诊断问题

### 脚本 4: `diagnose.bat`
- **适用情况**: 诊断环境问题
- **特点**: 检查所有工具和路径
- **使用**: 运行后查看诊断结果

## 4. 验证安装

安装完成后，验证工具是否可用：

### 在命令提示符中检查
```cmd
cmake --version
mingw32-make --version
qmake --version
```

应该显示类似以下信息：
```
cmake version 3.28.3
GNU Make 4.3
QMake version 6.7.3
```

### 检查 Qt 路径
```cmd
where qmake
```
应该显示：`D:\Qt\6.7.3\mingw_64\bin\qmake.exe`

## 5. 常见问题

### Q1: 脚本闪退
**原因**: 脚本遇到错误立即退出
**解决**: 
1. 在命令提示符中运行脚本：打开 cmd，cd 到 AutoQtPacker 目录，运行脚本
2. 使用 `build_easy.bat`，它有暂停步骤
3. 检查错误信息并按照提示解决

### Q2: CMake 配置失败
**可能原因**:
1. Qt 路径不正确
2. CMake 版本太旧
3. 缺少必要的组件

**解决**:
1. 运行 `diagnose.bat` 检查 Qt 路径
2. 更新 CMake 到最新版本
3. 确保安装了 Qt 的 MinGW 组件

### Q3: 构建失败
**可能原因**:
1. 缺少头文件或库
2. 编译器错误
3. 链接错误

**解决**:
1. 检查错误信息中的具体错误
2. 确保所有源代码文件存在
3. 检查 Qt 安装是否完整

### Q4: 程序无法启动
**可能原因**: 缺少 Qt DLL
**解决**:
1. 将 `D:\Qt\6.7.3\mingw_64\bin` 添加到 PATH
2. 或将必要的 DLL 复制到可执行文件目录：
   ```
   copy D:\Qt\6.7.3\mingw_64\bin\Qt6Core.dll build\bin\
   copy D:\Qt\6.7.3\mingw_64\bin\Qt6Widgets.dll build\bin\
   copy D:\Qt\6.7.3\mingw_64\bin\Qt6Gui.dll build\bin\
   ```

## 6. 快速开始

1. **安装必要工具**:
   - CMake (添加到 PATH)
   - Qt 6.7.3 (安装到 D:\Qt\6.7.3)
   - MinGW (或使用 Qt 自带的)

2. **验证安装**:
   ```cmd
   cmake --version
   qmake --version
   ```

3. **构建项目**:
   ```cmd
   cd AutoQtPacker
   build_easy.bat
   ```

4. **运行程序**:
   ```cmd
   build\bin\AutoQtPacker.exe
   ```

## 7. 获取帮助

如果问题仍然存在：
1. 运行 `diagnose.bat` 并将完整输出保存
2. 检查错误信息的具体内容
3. 确保所有工具版本兼容
4. 参考 Qt 和 CMake 官方文档

## 工具下载链接

- **CMake**: https://cmake.org/download/
- **Qt**: https://www.qt.io/download
- **MinGW-w64**: https://www.mingw-w64.org/

记住：关键是确保 CMake、MinGW 和 Qt 都正确安装并配置在 PATH 中，或者使用正确的硬编码路径。

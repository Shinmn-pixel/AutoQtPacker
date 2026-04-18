# AutoQtPacker 集成指南

本文档提供 AutoQtPacker 项目的完整集成说明，包括环境配置、构建步骤、使用方法和开发指南。

## 目录

1. [系统要求](#系统要求)
2. [环境配置](#环境配置)
3. [项目构建](#项目构建)
4. [使用说明](#使用说明)
5. [VSCode 开发配置](#vscode-开发配置)
6. [故障排除](#故障排除)
7. [扩展开发](#扩展开发)

## 系统要求

### 必需组件
- **操作系统**: Windows 10/11 (64位)
- **Qt 框架**: 6.7.3 (安装在 `D:\Qt\6.7.3`)
- **CMake**: 3.20 或更高版本
- **MinGW 编译器**: GCC 11.2.0 或更高版本
- **Visual Studio Code**: 最新版本 (可选，用于开发)

### 推荐组件
- **Git**: 用于版本控制
- **PowerShell**: 5.1 或更高版本 (用于 ZIP 打包)
- **7-Zip**: 替代压缩工具 (可选)

## 环境配置

### 1. 安装 Qt 6.7.3
1. 从 Qt 官网下载 Qt 6.7.3 安装程序
2. 安装时选择以下组件：
   - Qt 6.7.3 → MinGW 64-bit
   - Developer and Designer Tools → MinGW 11.2.0 64-bit
   - Developer and Designer Tools → CMake 3.20+
3. 确保安装路径为 `D:\Qt\6.7.3`

### 2. 安装 MinGW 编译器
1. 下载 MinGW-w64 安装程序
2. 安装到 `C:\MinGW`
3. 将 `C:\MinGW\bin` 添加到系统 PATH 环境变量

### 3. 安装 CMake
1. 从 CMake 官网下载最新版本
2. 安装时选择 "Add CMake to the system PATH"
3. 验证安装：`cmake --version`

### 4. 配置环境变量
将以下路径添加到系统 PATH 环境变量：
```
D:\Qt\6.7.3\mingw_64\bin
C:\MinGW\bin
```

## 项目构建

### 方法一：使用 CMake 命令行
```bash
# 1. 创建构建目录
mkdir build
cd build

# 2. 配置项目
cmake -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="D:/Qt/6.7.3" ..

# 3. 构建项目
cmake --build . --config Release

# 4. 运行程序
cd bin
AutoQtPacker.exe
```

### 方法二：使用 VSCode 任务
1. 在 VSCode 中打开 AutoQtPacker 项目
2. 按 `Ctrl+Shift+P` 打开命令面板
3. 输入 "Tasks: Run Task"
4. 选择 "CMake: Build"
5. 构建完成后，选择 "Run AutoQtPacker" 任务运行程序

### 方法三：使用批处理脚本
创建 `build.bat` 文件：
```batch
@echo off
echo Building AutoQtPacker...
mkdir build 2>nul
cd build
cmake -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="D:/Qt/6.7.3" ..
cmake --build . --config Release
cd bin
echo Build completed!
pause
```

## 使用说明

### 1. 启动应用程序
运行 `build/bin/AutoQtPacker.exe`

### 2. 打包 Qt 项目
1. **选择项目目录**: 点击"浏览..."按钮，选择包含 `CMakeLists.txt` 的 Qt 项目目录
2. **选择构建模式**: 从下拉框选择 Debug 或 Release 模式
3. **开始打包**: 点击"开始打包"按钮
4. **监控进度**: 查看进度条和日志窗口中的实时输出
5. **获取结果**: 打包完成后，ZIP 文件将保存在项目根目录

### 3. 打包流程详解
AutoQtPacker 执行以下步骤：
1. **验证项目**: 检查项目目录和 CMakeLists.txt 文件
2. **CMake 配置**: 使用 MinGW 生成器配置项目
3. **CMake 构建**: 构建项目到指定模式 (Debug/Release)
4. **文件收集**: 收集构建输出目录中的所有文件
5. **ZIP 打包**: 使用 PowerShell 的 Compress-Archive 创建 ZIP 文件
6. **清理**: 可选清理临时文件

### 4. 日志功能
- **实时日志**: 显示所有命令输出和进度信息
- **错误高亮**: 错误信息以红色高亮显示
- **时间戳**: 每条日志都包含时间戳
- **日志清空**: 支持清空日志窗口

## VSCode 开发配置

### 1. 扩展安装
安装以下 VSCode 扩展：
- **C/C++**: Microsoft 官方扩展
- **CMake Tools**: CMake 集成支持
- **Qt Tools**: Qt 开发工具
- **GitLens**: Git 集成

### 2. 配置说明
项目已包含完整的 VSCode 配置：

#### `.vscode/c_cpp_properties.json`
- 包含路径配置：Qt 头文件、MinGW 头文件
- 编译器路径：MinGW GCC
- 预处理器定义：Qt 相关宏

#### `.vscode/tasks.json`
- **CMake: Configure**: 配置 CMake 项目
- **CMake: Build**: 构建项目 (默认任务)
- **CMake: Clean**: 清理构建文件
- **Run AutoQtPacker**: 运行应用程序
- **Debug AutoQtPacker**: 调试应用程序

#### `.vscode/launch.json`
- **Debug AutoQtPacker**: 带外部控制台的调试配置
- **Run AutoQtPacker**: 不带控制台的运行配置
- **CMake Debug**: 基本调试配置

### 3. 开发工作流
1. **打开项目**: 在 VSCode 中打开 AutoQtPacker 目录
2. **配置项目**: 运行 "CMake: Configure" 任务
3. **构建项目**: 按 `Ctrl+Shift+B` 构建项目
4. **调试代码**: 按 `F5` 启动调试
5. **运行测试**: 使用 "Run AutoQtPacker" 任务

## 故障排除

### 常见问题

#### 1. "无法找到 Qt 库"
**症状**: CMake 配置失败，提示找不到 Qt6
**解决方案**:
- 检查 Qt 安装路径是否正确 (`D:\Qt\6.7.3`)
- 验证 `CMAKE_PREFIX_PATH` 设置
- 确保安装了 Qt6 Core、Widgets、Concurrent 组件

#### 2. "无法启动 CMake 进程"
**症状**: 打包时提示无法启动 CMake
**解决方案**:
- 检查 CMake 是否已安装并添加到 PATH
- 验证 MinGW 编译器是否可用
- 检查项目目录权限

#### 3. "创建 ZIP 包失败"
**症状**: 构建成功但打包失败
**解决方案**:
- 确保 PowerShell 可用 (Windows 系统)
- 检查输出目录是否存在文件
- 验证磁盘空间是否充足

#### 4. "界面显示异常"
**症状**: 应用程序界面显示不正常
**解决方案**:
- 检查 Qt 插件路径配置
- 验证环境变量 `QT_QPA_PLATFORM_PLUGIN_PATH`
- 重新构建项目

### 调试技巧
1. **查看详细日志**: 启用应用程序的详细日志输出
2. **检查进程输出**: 查看 CMake 和构建命令的完整输出
3. **验证文件路径**: 确保所有路径都正确且可访问
4. **测试单独命令**: 在命令行中手动执行失败的命令

## 扩展开发

### 1. 添加新功能
#### 修改主窗口
- 编辑 `MainWindow.ui` 文件添加新 UI 组件
- 更新 `MainWindow.h/cpp` 实现新功能
- 重新运行 CMake 以更新 UI 头文件

#### 扩展打包任务
- 修改 `PackerTask.h/cpp` 添加新的打包步骤
- 实现新的信号槽连接
- 更新进度报告逻辑

### 2. 支持其他构建系统
除了 CMake，可以扩展支持：
- **qmake**: Qt 的传统构建系统
- **QBS**: Qt Build Suite
- **Meson**: 现代构建系统

### 3. 添加插件系统
实现插件架构以支持：
- **自定义打包步骤**: 用户可添加预处理/后处理步骤
- **输出格式**: 支持多种压缩格式 (7z, tar.gz 等)
- **云存储集成**: 自动上传到云存储服务

### 4. 国际化支持
添加多语言支持：
- 使用 Qt 的翻译系统 (lupdate, lrelease)
- 创建 `.ts` 翻译文件
- 实现动态语言切换

## 许可证

AutoQtPacker 使用 MIT 许可证。详细信息请查看 LICENSE 文件。

## 技术支持

- **问题报告**: 在项目仓库中创建 Issue
- **功能请求**: 提交 Feature Request
- **贡献代码**: 提交 Pull Request
- **文档改进**: 修改相关文档文件

## 更新日志

### v1.0.0 (初始版本)
- 基本 Qt 项目打包功能
- 图形用户界面
- CMake 集成
- VSCode 开发配置
- 详细日志和进度显示
- Windows PowerShell 打包支持

---

*最后更新: 2026年4月17日*

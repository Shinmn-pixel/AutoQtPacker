# 输出目录功能测试指南

## 新增功能
AutoQtPacker 现在支持选择输出目录功能。用户可以选择将打包后的 ZIP 文件保存到指定目录，而不是默认的项目目录。

## 功能说明

### 1. 用户界面变化
- 新增"输出目录"标签和文本框
- 新增"浏览..."按钮用于选择输出目录
- 输出目录为可选字段，如果留空则使用项目目录

### 2. 代码修改
- **PackerTask.h/cpp**: 添加了 `outputPath` 参数到构造函数，修改了 `createZipPackage()` 方法以支持自定义输出目录
- **MainWindow.h/cpp**: 添加了输出目录相关的 UI 控件和事件处理
- **UI 文件**: 更新了 `MainWindow_fixed_with_output.ui` 以包含新的 UI 控件

### 3. 使用流程
1. 选择要打包的 Qt 项目目录（必须包含 CMakeLists.txt）
2. （可选）选择输出目录，如果不选择则 ZIP 文件将保存在项目目录中
3. 选择构建模式（Debug/Release）
4. 点击"开始打包"按钮
5. 打包完成后，ZIP 文件将保存在指定的输出目录（或项目目录）

## 测试步骤

### 测试 1: 使用默认输出目录（项目目录）
1. 启动 AutoQtPacker
2. 选择项目目录（例如：`E:\AIProgram\AutoQtPacker\test_project`）
3. 将输出目录留空
4. 点击"开始打包"
5. 验证 ZIP 文件是否创建在项目目录中

### 测试 2: 使用自定义输出目录
1. 启动 AutoQtPacker
2. 选择项目目录
3. 点击输出目录的"浏览..."按钮，选择一个不同的目录（例如：桌面或文档文件夹）
4. 点击"开始打包"
5. 验证 ZIP 文件是否创建在指定的输出目录中

### 测试 3: 输出目录不存在
1. 启动 AutoQtPacker
2. 选择项目目录
3. 在输出目录文本框中输入一个不存在的路径（例如：`C:\NonExistent\Folder`）
4. 点击"开始打包"
5. 验证程序是否自动创建该目录并保存 ZIP 文件

## 预期行为
- 当输出目录为空时：ZIP 文件保存在项目目录
- 当输出目录存在时：ZIP 文件保存在指定目录
- 当输出目录不存在时：程序自动创建目录并保存文件
- 日志窗口应显示输出目录信息

## 技术实现细节

### PackerTask 修改
```cpp
// 构造函数添加 outputPath 参数
PackerTask(const QString &projectPath, 
           const QString &buildMode = "Release",
           const QString &outputPath = "",
           QObject *parent = nullptr);

// createZipPackage() 方法逻辑
if (outputPath.isEmpty()) {
    zipFilePath = projectPath + "/" + zipFileName;
} else {
    // 确保输出目录存在
    QDir outputDirPath(outputPath);
    if (!outputDirPath.exists()) {
        if (!outputDirPath.mkpath(".")) {
            error("无法创建输出目录: " + outputPath);
            return "";
        }
        log("已创建输出目录: " + outputPath);
    }
    zipFilePath = outputPath + "/" + zipFileName;
}
```

### MainWindow 修改
- 添加了 `onOutputBrowseButtonClicked()` 方法
- 更新了 `onStartPackingButtonClicked()` 以传递输出目录参数
- 更新了 UI 状态管理以包含输出目录控件

## 注意事项
1. 输出目录路径中不应包含文件名，只需目录路径
2. 程序需要写入权限到输出目录
3. 如果输出目录在受保护的系统目录中，可能需要管理员权限
4. 日志窗口会显示选择的输出目录信息

## 故障排除
1. **无法创建输出目录**: 检查权限和路径有效性
2. **ZIP 文件未创建**: 检查磁盘空间和防病毒软件设置
3. **程序崩溃**: 检查路径是否包含特殊字符或过长

## 版本信息
- 功能版本: 1.1.0
- 添加时间: 2026-04-17
- 兼容性: 与原有功能完全兼容

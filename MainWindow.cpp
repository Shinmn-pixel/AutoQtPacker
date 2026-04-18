#include "MainWindow.h"
#include "PackerTask.h"
#include "ui_MainWindow_fixed_with_output.h"

#include <QFileDialog>
#include <QMessageBox>
#include <QDateTime>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

/**
 * @brief 构造函数
 * @param parent 父窗口指针
 */
MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , packerThread(nullptr)
    , packerTask(nullptr)
    , futureWatcher(nullptr)
    , currentBuildMode("Release")
{
    // 初始化 UI
    ui->setupUi(this);
    
    // 设置窗口标题
    setWindowTitle("AutoQtPacker - Qt 项目打包工具");
    
    // 初始化界面
    setupUi();
    
    // 初始化信号槽连接
    setupConnections();
    
    // 初始化日志
    appendLogWithTimestamp("AutoQtPacker 已启动");
    appendLogWithTimestamp("请选择要打包的 Qt 项目目录");
}

/**
 * @brief 析构函数
 */
MainWindow::~MainWindow()
{
    // 停止打包任务
    if (packerTask && packerTask->isRunning()) {
        packerTask->stop();
        packerTask->wait();
    }
    
    // 清理资源
    if (packerThread) {
        packerThread->quit();
        packerThread->wait();
        delete packerThread;
    }
    
    delete ui;
}

/**
 * @brief 初始化用户界面
 */
void MainWindow::setupUi()
{
    // 设置进度条范围
    ui->progressBar->setRange(0, 100);
    ui->progressBar->setValue(0);
    
    // 设置日志窗口为只读
    ui->logTextEdit->setReadOnly(true);
    
    // 设置构建模式下拉框
    ui->buildModeComboBox->addItem("Debug");
    ui->buildModeComboBox->addItem("Release");
    ui->buildModeComboBox->setCurrentText("Release");
    
    // 设置初始界面状态
    updateUiState(false);
}

/**
 * @brief 初始化信号槽连接
 */
void MainWindow::setupConnections()
{
    // 连接按钮点击信号
    connect(ui->browseButton, &QPushButton::clicked,
            this, &MainWindow::onBrowseButtonClicked);
    connect(ui->outputBrowseButton, &QPushButton::clicked,
            this, &MainWindow::onOutputBrowseButtonClicked);
    connect(ui->startButton, &QPushButton::clicked,
            this, &MainWindow::onStartPackingButtonClicked);
    connect(ui->clearLogButton, &QPushButton::clicked,
            this, &MainWindow::clearLog);
    
    // 连接下拉框变化信号
    connect(ui->buildModeComboBox, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::onBuildModeChanged);
}

/**
 * @brief 处理"浏览..."按钮点击事件（项目路径）
 */
void MainWindow::onBrowseButtonClicked()
{
    // 打开文件夹选择对话框
    QString dir = QFileDialog::getExistingDirectory(
        this,
        "选择 Qt 项目目录",
        QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation),
        QFileDialog::ShowDirsOnly | QFileDialog::DontResolveSymlinks
    );
    
    if (!dir.isEmpty()) {
        // 检查目录是否包含 CMakeLists.txt
        QFileInfo cmakeFile(dir + "/CMakeLists.txt");
        if (cmakeFile.exists()) {
            currentProjectPath = dir;
            ui->projectPathLineEdit->setText(dir);
            appendLogWithTimestamp("已选择项目目录: " + dir);
            appendLogWithTimestamp("检测到 CMakeLists.txt 文件");
        } else {
            showErrorMessage("错误", "选择的目录不包含 CMakeLists.txt 文件\n请选择有效的 Qt 项目目录");
            ui->projectPathLineEdit->clear();
            currentProjectPath.clear();
        }
    }
}

/**
 * @brief 处理"浏览..."按钮点击事件（输出目录）
 */
void MainWindow::onOutputBrowseButtonClicked()
{
    // 打开文件夹选择对话框
    QString dir = QFileDialog::getExistingDirectory(
        this,
        "选择输出目录",
        QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation),
        QFileDialog::ShowDirsOnly | QFileDialog::DontResolveSymlinks
    );
    
    if (!dir.isEmpty()) {
        currentOutputPath = dir;
        ui->outputPathLineEdit->setText(dir);
        appendLogWithTimestamp("已选择输出目录: " + dir);
    }
}

/**
 * @brief 处理"开始打包"按钮点击事件
 */
void MainWindow::onStartPackingButtonClicked()
{
    // 验证输入
    if (!validateInputs()) {
        return;
    }
    
    // 更新界面状态
    updateUiState(true);
    
    // 清空进度条
    ui->progressBar->setValue(0);
    
    // 获取输出目录（如果用户没有指定，则使用空字符串）
    QString outputPath = ui->outputPathLineEdit->text().trimmed();
    
    // 创建打包任务
    packerTask = new PackerTask(currentProjectPath, currentBuildMode, outputPath);
    
    // 创建线程
    packerThread = new QThread();
    packerTask->moveToThread(packerThread);
    
    // 连接信号槽
    connect(packerThread, &QThread::started, packerTask, &PackerTask::start);
    connect(packerTask, &PackerTask::progressUpdated, this, &MainWindow::onPackingProgress);
    connect(packerTask, &PackerTask::logMessage, this, &MainWindow::onLogMessage);
    connect(packerTask, &PackerTask::finished, this, &MainWindow::onPackingFinished);
    
    // 连接线程完成信号
    connect(packerTask, &PackerTask::finished, packerThread, &QThread::quit);
    connect(packerTask, &PackerTask::finished, packerTask, &QObject::deleteLater);
    connect(packerThread, &QThread::finished, packerThread, &QObject::deleteLater);
    
    // 启动线程
    packerThread->start();
    
    appendLogWithTimestamp("开始打包任务...");
    appendLogWithTimestamp("项目路径: " + currentProjectPath);
    if (!outputPath.isEmpty()) {
        appendLogWithTimestamp("输出目录: " + outputPath);
    } else {
        appendLogWithTimestamp("输出目录: 使用项目目录");
    }
    appendLogWithTimestamp("构建模式: " + currentBuildMode);
}

/**
 * @brief 处理打包进度更新
 * @param progress 进度值（0-100）
 */
void MainWindow::onPackingProgress(int progress)
{
    ui->progressBar->setValue(progress);
}

/**
 * @brief 处理日志消息
 * @param message 日志消息
 */
void MainWindow::onLogMessage(const QString &message)
{
    appendLogWithTimestamp(message);
}

/**
 * @brief 处理打包完成
 * @param success 是否成功
 * @param outputPath 输出文件路径
 */
void MainWindow::onPackingFinished(bool success, const QString &outputPath)
{
    // 更新界面状态
    updateUiState(false);
    
    // 重置进度条
    ui->progressBar->setValue(100);
    
    if (success) {
        appendLogWithTimestamp("打包任务完成！");
        appendLogWithTimestamp("输出文件: " + outputPath);
        showSuccessMessage("成功", "打包任务已完成\n输出文件: " + outputPath);
    } else {
        appendLogWithTimestamp("打包任务失败！");
        showErrorMessage("错误", "打包任务失败，请查看日志了解详细信息");
    }
    
    // 清理任务对象
    packerTask = nullptr;
    packerThread = nullptr;
}

/**
 * @brief 处理构建模式选择变化
 * @param index 选择的索引
 */
void MainWindow::onBuildModeChanged(int index)
{
    currentBuildMode = ui->buildModeComboBox->itemText(index);
    appendLogWithTimestamp("构建模式已更改为: " + currentBuildMode);
}

/**
 * @brief 更新界面状态
 * @param isRunning 打包任务是否正在运行
 */
void MainWindow::updateUiState(bool isRunning)
{
    ui->browseButton->setEnabled(!isRunning);
    ui->projectPathLineEdit->setEnabled(!isRunning);
    ui->outputBrowseButton->setEnabled(!isRunning);
    ui->outputPathLineEdit->setEnabled(!isRunning);
    ui->buildModeComboBox->setEnabled(!isRunning);
    ui->startButton->setEnabled(!isRunning);
    ui->startButton->setText(isRunning ? "打包中..." : "开始打包");
    ui->clearLogButton->setEnabled(!isRunning);
}

/**
 * @brief 验证输入参数
 * @return 验证是否通过
 */
bool MainWindow::validateInputs()
{
    if (currentProjectPath.isEmpty()) {
        showErrorMessage("错误", "请先选择 Qt 项目目录");
        return false;
    }
    
    QDir projectDir(currentProjectPath);
    if (!projectDir.exists()) {
        showErrorMessage("错误", "项目目录不存在");
        return false;
    }
    
    QFileInfo cmakeFile(currentProjectPath + "/CMakeLists.txt");
    if (!cmakeFile.exists()) {
        showErrorMessage("错误", "项目目录中未找到 CMakeLists.txt 文件");
        return false;
    }
    
    return true;
}

/**
 * @brief 清空日志窗口
 */
void MainWindow::clearLog()
{
    ui->logTextEdit->clear();
    appendLogWithTimestamp("日志已清空");
}

/**
 * @brief 添加带时间戳的日志
 * @param message 日志消息
 */
void MainWindow::appendLogWithTimestamp(const QString &message)
{
    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
    ui->logTextEdit->appendPlainText("[" + timestamp + "] " + message);
    
    // 自动滚动到底部
    QTextCursor cursor = ui->logTextEdit->textCursor();
    cursor.movePosition(QTextCursor::End);
    ui->logTextEdit->setTextCursor(cursor);
}

/**
 * @brief 显示错误消息
 * @param title 错误标题
 * @param message 错误消息
 */
void MainWindow::showErrorMessage(const QString &title, const QString &message)
{
    QMessageBox::critical(this, title, message);
    appendLogWithTimestamp("[错误] " + message);
}

/**
 * @brief 显示成功消息
 * @param title 成功标题
 * @param message 成功消息
 */
void MainWindow::showSuccessMessage(const QString &title, const QString &message)
{
    QMessageBox::information(this, title, message);
    appendLogWithTimestamp("[成功] " + message);
}

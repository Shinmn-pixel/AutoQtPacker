#include "PackerTask.h"
#include <QCoreApplication>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QDirIterator>
#include <QProcessEnvironment>
#include <QStandardPaths>
#include <QElapsedTimer>

// Windows 特定的头文件
#ifdef Q_OS_WIN
#include <windows.h>
#endif

/**
 * @brief 构造函数
 * @param projectPath Qt 项目路径
 * @param buildMode 构建模式（Debug/Release）
 * @param outputPath 输出目录路径（可选，如果为空则使用项目目录）
 * @param parent 父对象指针
 */
PackerTask::PackerTask(const QString &projectPath, 
                       const QString &buildMode,
                       const QString &outputPath,
                       QObject *parent)
    : QObject(parent)
    , projectPath(projectPath)
    , buildMode(buildMode)
    , outputPath(outputPath)
    , process(nullptr)
    , running(false)
    , stopped(false)
    , currentStep(0)
{
    // 构建目录路径
    buildDir = projectPath + "/build";
    
    // 构建输出目录路径
    outputDir = buildDir;
    
    // 如果用户没有指定输出目录，使用项目目录
    if (this->outputPath.isEmpty()) {
        this->outputPath = projectPath;
    }
    
    log("打包任务已创建");
    log("项目路径: " + projectPath);
    log("构建模式: " + buildMode);
    log("输出目录: " + this->outputPath);
    log("构建目录: " + buildDir);
    log("构建输出目录: " + outputDir);
}

/**
 * @brief 析构函数
 */
PackerTask::~PackerTask()
{
    stop();
    cleanup();
    
    if (process) {
        process->deleteLater();
    }
    
    log("打包任务已销毁");
}

/**
 * @brief 检查任务是否正在运行
 * @return 是否正在运行
 */
bool PackerTask::isRunning() const
{
    return running;
}

/**
 * @brief 停止任务
 */
void PackerTask::stop()
{
    if (running && process && process->state() == QProcess::Running) {
        stopped = true;
        process->kill();
        log("任务已停止");
    }
}

/**
 * @brief 等待任务完成
 */
void PackerTask::wait()
{
    if (process && process->state() == QProcess::Running) {
        process->waitForFinished();
    }
}

/**
 * @brief 开始执行打包任务
 */
void PackerTask::start()
{
    if (running) {
        error("任务已在运行中");
        return;
    }
    
    running = true;
    stopped = false;
    currentStep = 0;
    
    log("开始执行打包任务");
    updateProgress(0);
    
    // 检查项目路径
    QDir projectDir(projectPath);
    if (!projectDir.exists()) {
        error("项目目录不存在: " + projectPath);
        emit finished(false, "");
        running = false;
        return;
    }
    
    // 检查 CMakeLists.txt 文件
    QFileInfo cmakeFile(projectPath + "/CMakeLists.txt");
    if (!cmakeFile.exists()) {
        error("未找到 CMakeLists.txt 文件");
        emit finished(false, "");
        running = false;
        return;
    }
    
    log("检测到 CMakeLists.txt 文件");
    updateProgress(1);
    
    // 执行 CMake 配置
    if (!runCmakeConfigure()) {
        error("CMake 配置失败");
        emit finished(false, "");
        running = false;
        return;
    }
    
    updateProgress(2);
    
    // 执行 CMake 构建
    if (!runCmakeBuild()) {
        error("CMake 构建失败");
        emit finished(false, "");
        running = false;
        return;
    }
    
    updateProgress(3);
    
    // 创建 ZIP 包
    QString zipPath = createZipPackage();
    if (zipPath.isEmpty()) {
        error("创建 ZIP 包失败");
        emit finished(false, "");
        running = false;
        return;
    }
    
    updateProgress(4);
    
    // 清理临时文件
    cleanup();
    
    updateProgress(5);
    
    // 任务完成
    log("打包任务完成");
    log("输出文件: " + zipPath);
    
    running = false;
    emit finished(true, zipPath);
}

/**
 * @brief 执行 CMake 配置步骤
 * @return 是否成功
 */
bool PackerTask::runCmakeConfigure()
{
    log("开始 CMake 配置...");
    
    // 创建构建目录
    QDir buildDirectory(buildDir);
    if (!buildDirectory.exists()) {
        if (!buildDirectory.mkpath(".")) {
            error("无法创建构建目录: " + buildDir);
            return false;
        }
        log("已创建构建目录: " + buildDir);
    }
    
    // 准备 CMake 命令
    QStringList arguments;
    arguments << "-G" << "MinGW Makefiles";
    arguments << "-DCMAKE_PREFIX_PATH=D:/Qt/6.7.3";
    arguments << "-DCMAKE_BUILD_TYPE=" + buildMode;
    arguments << projectPath;
    
    log("执行命令: cmake " + arguments.join(" "));
    
    // 执行 CMake 命令
    process = new QProcess(this);
    process->setWorkingDirectory(buildDir);
    process->setProcessChannelMode(QProcess::MergedChannels);
    
    connect(process, &QProcess::readyReadStandardOutput,
            this, &PackerTask::onProcessOutput);
    connect(process, &QProcess::readyReadStandardError,
            this, &PackerTask::onProcessError);
    connect(process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &PackerTask::onProcessFinished);
    
    QElapsedTimer timer;
    timer.start();
    
    process->start("cmake", arguments);
    
    if (!process->waitForStarted()) {
        error("无法启动 CMake 进程");
        return false;
    }
    
    // 等待进程完成（最多10分钟）
    if (!process->waitForFinished(600000)) {
        error("CMake 配置超时");
        return false;
    }
    
    qint64 elapsed = timer.elapsed();
    log(QString("CMake 配置完成，耗时: %1 毫秒").arg(elapsed));
    
    return (process->exitCode() == 0);
}

/**
 * @brief 执行 CMake 构建步骤
 * @return 是否成功
 */
bool PackerTask::runCmakeBuild()
{
    log("开始 CMake 构建...");
    
    // 准备构建命令
    QStringList arguments;
    arguments << "--build" << ".";
    arguments << "--config" << buildMode;
    
    log("执行命令: cmake " + arguments.join(" "));
    
    // 执行构建命令
    process = new QProcess(this);
    process->setWorkingDirectory(buildDir);
    process->setProcessChannelMode(QProcess::MergedChannels);
    
    connect(process, &QProcess::readyReadStandardOutput,
            this, &PackerTask::onProcessOutput);
    connect(process, &QProcess::readyReadStandardError,
            this, &PackerTask::onProcessError);
    connect(process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &PackerTask::onProcessFinished);
    
    QElapsedTimer timer;
    timer.start();
    
    process->start("cmake", arguments);
    
    if (!process->waitForStarted()) {
        error("无法启动 CMake 构建进程");
        return false;
    }
    
    // 等待进程完成（最多30分钟）
    if (!process->waitForFinished(1800000)) {
        error("CMake 构建超时");
        return false;
    }
    
    qint64 elapsed = timer.elapsed();
    log(QString("CMake 构建完成，耗时: %1 毫秒").arg(elapsed));
    
    return (process->exitCode() == 0);
}

/**
 * @brief 收集输出文件并创建 ZIP 包
 * @return ZIP 文件路径，如果失败则返回空字符串
 */
QString PackerTask::createZipPackage()
{
    log("开始创建 ZIP 包...");
    
    // 检查输出目录
    QDir outputDirectory(outputDir);
    if (!outputDirectory.exists()) {
        error("输出目录不存在: " + outputDir);
        return "";
    }
    
    // 获取项目名称（从项目路径）
    QFileInfo projectInfo(projectPath);
    QString projectName = projectInfo.fileName();
    if (projectName.isEmpty()) {
        projectName = "QtProject";
    }
    
    // 生成 ZIP 文件名
    QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss");
    QString zipFileName = QString("%1_%2_%3.zip").arg(projectName).arg(buildMode).arg(timestamp);
    
    // 使用用户指定的输出目录，如果为空则使用项目目录
    QString zipFilePath;
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
    
    log("ZIP 文件路径: " + zipFilePath);
    
    // 使用系统命令创建 ZIP 文件
    // 在 Windows 上使用 PowerShell 的 Compress-Archive 命令
    #ifdef Q_OS_WIN
    QStringList psArgs;
    psArgs << "-Command";
    psArgs << QString("Compress-Archive -Path '%1/*' -DestinationPath '%2' -Force")
              .arg(outputDir).arg(zipFilePath);
    
    QProcess zipProcess;
    zipProcess.start("powershell", psArgs);
    
    if (!zipProcess.waitForStarted()) {
        error("无法启动 PowerShell 进程");
        return "";
    }
    
    if (!zipProcess.waitForFinished(300000)) { // 5分钟超时
        error("创建 ZIP 包超时");
        return "";
    }
    
    if (zipProcess.exitCode() != 0) {
        QString errorOutput = QString::fromLocal8Bit(zipProcess.readAllStandardError());
        error("创建 ZIP 包失败: " + errorOutput);
        return "";
    }
    
    log("ZIP 包创建成功");
    return zipFilePath;
    #else
    // 非 Windows 系统使用 tar 命令
    QStringList tarArgs;
    tarArgs << "-czf";
    tarArgs << zipFilePath;
    tarArgs << "-C";
    tarArgs << outputDir;
    tarArgs << ".";
    
    QProcess zipProcess;
    zipProcess.start("tar", tarArgs);
    
    if (!zipProcess.waitForStarted()) {
        error("无法启动 tar 进程");
        return "";
    }
    
    if (!zipProcess.waitForFinished(300000)) {
        error("创建 tar 包超时");
        return "";
    }
    
    if (zipProcess.exitCode() != 0) {
        QString errorOutput = QString::fromLocal8Bit(zipProcess.readAllStandardError());
        error("创建 tar 包失败: " + errorOutput);
        return "";
    }
    
    log("tar 包创建成功");
    return zipFilePath;
    #endif
}

/**
 * @brief 更新进度
 * @param step 当前步骤
 * @param totalSteps 总步骤数
 */
void PackerTask::updateProgress(int step, int totalSteps)
{
    currentStep = step;
    int progress = (step * 100) / totalSteps;
    emit progressUpdated(progress);
}

/**
 * @brief 记录日志
 * @param message 日志消息
 */
void PackerTask::log(const QString &message)
{
    emit logMessage("[信息] " + message);
}

/**
 * @brief 记录错误
 * @param message 错误消息
 */
void PackerTask::error(const QString &message)
{
    emit logMessage("[错误] " + message);
}

/**
 * @brief 清理临时文件
 */
void PackerTask::cleanup()
{
    // 这里可以添加清理逻辑，例如删除临时文件
    // 注意：不要删除构建目录，因为用户可能想要保留构建结果
    log("清理完成");
}

/**
 * @brief 处理进程输出
 */
void PackerTask::onProcessOutput()
{
    if (process) {
        QByteArray output = process->readAllStandardOutput();
        QString outputStr = QString::fromLocal8Bit(output).trimmed();
        
        if (!outputStr.isEmpty()) {
            // 将输出拆分为行并发送
            QStringList lines = outputStr.split('\n');
            for (const QString &line : lines) {
                if (!line.trimmed().isEmpty()) {
                    emit logMessage(line);
                }
            }
        }
    }
}

/**
 * @brief 处理进程错误输出
 */
void PackerTask::onProcessError()
{
    if (process) {
        QByteArray errorOutput = process->readAllStandardError();
        QString errorStr = QString::fromLocal8Bit(errorOutput).trimmed();
        
        if (!errorStr.isEmpty()) {
            // 将错误输出拆分为行并发送
            QStringList lines = errorStr.split('\n');
            for (const QString &line : lines) {
                if (!line.trimmed().isEmpty()) {
                    emit logMessage("[错误] " + line);
                }
            }
        }
    }
}

/**
 * @brief 处理进程完成
 * @param exitCode 退出代码
 * @param exitStatus 退出状态
 */
void PackerTask::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    Q_UNUSED(exitStatus);
    
    if (exitCode != 0) {
        error(QString("进程退出代码: %1").arg(exitCode));
    } else {
        log("进程成功完成");
    }
}

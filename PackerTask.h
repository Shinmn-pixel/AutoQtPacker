#ifndef PACKERTASK_H
#define PACKERTASK_H

#include <QObject>
#include <QProcess>
#include <QThread>
#include <QDir>
#include <QFileInfo>
#include <QDateTime>

/**
 * @brief 打包任务类，负责执行 Qt 项目的自动打包流程
 * 
 * 该类在单独的线程中运行，执行以下步骤：
 * 1. 检测项目中的 CMakeLists.txt 文件
 * 2. 调用 CMake 配置项目
 * 3. 使用 CMake 构建项目
 * 4. 收集输出文件并压缩为 ZIP 包
 * 5. 实时报告进度和日志
 */
class PackerTask : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief 构造函数
     * @param projectPath Qt 项目路径
     * @param buildMode 构建模式（Debug/Release）
     * @param outputPath 输出目录路径（可选，如果为空则使用项目目录）
     * @param parent 父对象指针
     */
    explicit PackerTask(const QString &projectPath, 
                       const QString &buildMode = "Release",
                       const QString &outputPath = "",
                       QObject *parent = nullptr);
    
    /**
     * @brief 析构函数
     */
    ~PackerTask();
    
    /**
     * @brief 检查任务是否正在运行
     * @return 是否正在运行
     */
    bool isRunning() const;
    
    /**
     * @brief 停止任务
     */
    void stop();
    
    /**
     * @brief 等待任务完成
     */
    void wait();

public slots:
    /**
     * @brief 开始执行打包任务
     */
    void start();

signals:
    /**
     * @brief 进度更新信号
     * @param progress 进度值（0-100）
     */
    void progressUpdated(int progress);
    
    /**
     * @brief 日志消息信号
     * @param message 日志消息
     */
    void logMessage(const QString &message);
    
    /**
     * @brief 任务完成信号
     * @param success 是否成功
     * @param outputPath 输出文件路径
     */
    void finished(bool success, const QString &outputPath);

private slots:
    /**
     * @brief 处理进程输出
     */
    void onProcessOutput();
    
    /**
     * @brief 处理进程错误输出
     */
    void onProcessError();
    
    /**
     * @brief 处理进程完成
     * @param exitCode 退出代码
     * @param exitStatus 退出状态
     */
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    /**
     * @brief 执行 CMake 配置步骤
     * @return 是否成功
     */
    bool runCmakeConfigure();
    
    /**
     * @brief 执行 CMake 构建步骤
     * @return 是否成功
     */
    bool runCmakeBuild();
    
    /**
     * @brief 收集输出文件并创建 ZIP 包
     * @return ZIP 文件路径，如果失败则返回空字符串
     */
    QString createZipPackage();
    
    /**
     * @brief 更新进度
     * @param step 当前步骤
     * @param totalSteps 总步骤数
     */
    void updateProgress(int step, int totalSteps = 5);
    
    /**
     * @brief 记录日志
     * @param message 日志消息
     */
    void log(const QString &message);
    
    /**
     * @brief 记录错误
     * @param message 错误消息
     */
    void error(const QString &message);
    
    /**
     * @brief 清理临时文件
     */
    void cleanup();

private:
    QString projectPath;          ///< Qt 项目路径
    QString buildMode;            ///< 构建模式
    QString outputPath;           ///< 输出目录路径（用户选择）
    QString buildDir;             ///< 构建目录路径
    QString outputDir;            ///< 构建输出目录路径
    QProcess *process;            ///< 外部进程对象
    bool running;                 ///< 任务是否正在运行
    bool stopped;                 ///< 任务是否被停止
    int currentStep;              ///< 当前步骤
};

#endif // PACKERTASK_H

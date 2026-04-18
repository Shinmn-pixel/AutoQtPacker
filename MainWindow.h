#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QThread>
#include <QProcess>
#include <QFutureWatcher>
#include <QtConcurrent/QtConcurrent>

// 前向声明
class PackerTask;

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

/**
 * @brief 主窗口类，提供 Qt 项目打包工具的图形界面
 * 
 * 该类负责：
 * 1. 提供用户界面组件（文件夹选择、构建配置、进度显示、日志窗口）
 * 2. 管理打包任务的启动和停止
 * 3. 处理用户交互事件
 * 4. 显示实时日志和进度信息
 */
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    /**
     * @brief 构造函数
     * @param parent 父窗口指针
     */
    explicit MainWindow(QWidget *parent = nullptr);
    
    /**
     * @brief 析构函数
     */
    ~MainWindow();

private slots:
    /**
     * @brief 处理"浏览..."按钮点击事件（项目路径）
     */
    void onBrowseButtonClicked();
    
    /**
     * @brief 处理"浏览..."按钮点击事件（输出目录）
     */
    void onOutputBrowseButtonClicked();
    
    /**
     * @brief 处理"开始打包"按钮点击事件
     */
    void onStartPackingButtonClicked();
    
    /**
     * @brief 处理打包进度更新
     * @param progress 进度值（0-100）
     */
    void onPackingProgress(int progress);
    
    /**
     * @brief 处理日志消息
     * @param message 日志消息
     */
    void onLogMessage(const QString &message);
    
    /**
     * @brief 处理打包完成
     * @param success 是否成功
     * @param outputPath 输出文件路径
     */
    void onPackingFinished(bool success, const QString &outputPath);
    
    /**
     * @brief 处理构建模式选择变化
     * @param index 选择的索引
     */
    void onBuildModeChanged(int index);

private:
    /**
     * @brief 初始化用户界面
     */
    void setupUi();
    
    /**
     * @brief 初始化信号槽连接
     */
    void setupConnections();
    
    /**
     * @brief 更新界面状态
     * @param isRunning 打包任务是否正在运行
     */
    void updateUiState(bool isRunning);
    
    /**
     * @brief 验证输入参数
     * @return 验证是否通过
     */
    bool validateInputs();
    
    /**
     * @brief 清空日志窗口
     */
    void clearLog();
    
    /**
     * @brief 添加带时间戳的日志
     * @param message 日志消息
     */
    void appendLogWithTimestamp(const QString &message);
    
    /**
     * @brief 显示错误消息
     * @param title 错误标题
     * @param message 错误消息
     */
    void showErrorMessage(const QString &title, const QString &message);
    
    /**
     * @brief 显示成功消息
     * @param title 成功标题
     * @param message 成功消息
     */
    void showSuccessMessage(const QString &title, const QString &message);

private:
    Ui::MainWindow *ui;                  ///< UI 指针
    QThread *packerThread;               ///< 打包任务线程
    PackerTask *packerTask;              ///< 打包任务对象
    QFutureWatcher<void> *futureWatcher; ///< 异步任务监视器
    QString currentProjectPath;          ///< 当前选择的项目路径
    QString currentOutputPath;           ///< 当前选择的输出目录
    QString currentBuildMode;            ///< 当前构建模式
};

#endif // MAINWINDOW_H

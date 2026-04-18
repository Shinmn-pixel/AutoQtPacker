#include "MainWindow.h"
#include <QApplication>
#include <QStyleFactory>
#include <QFile>
#include <QTextStream>

/**
 * @brief 加载应用程序样式表
 * @param app QApplication 对象
 */
void loadApplicationStyle(QApplication &app)
{
    // 设置 Fusion 样式，提供跨平台一致的外观
    app.setStyle(QStyleFactory::create("Fusion"));
    
    // 创建深色主题样式表
    QString styleSheet = R"(
        QMainWindow {
            background-color: #2b2b2b;
        }
        
        QWidget {
            color: #ffffff;
            font-family: "Segoe UI", "Microsoft YaHei", sans-serif;
            font-size: 10pt;
        }
        
        QGroupBox {
            border: 1px solid #555555;
            border-radius: 5px;
            margin-top: 10px;
            padding-top: 10px;
            font-weight: bold;
        }
        
        QGroupBox::title {
            subcontrol-origin: margin;
            left: 10px;
            padding: 0 5px 0 5px;
        }
        
        QLabel {
            color: #cccccc;
        }
        
        QLineEdit, QComboBox {
            background-color: #3c3c3c;
            border: 1px solid #555555;
            border-radius: 3px;
            padding: 5px;
            selection-background-color: #0078d7;
        }
        
        QLineEdit:focus, QComboBox:focus {
            border: 1px solid #0078d7;
        }
        
        QPushButton {
            background-color: #0078d7;
            color: white;
            border: none;
            border-radius: 3px;
            padding: 8px 16px;
            font-weight: bold;
        }
        
        QPushButton:hover {
            background-color: #106ebe;
        }
        
        QPushButton:pressed {
            background-color: #005a9e;
        }
        
        QPushButton:disabled {
            background-color: #555555;
            color: #888888;
        }
        
        QProgressBar {
            border: 1px solid #555555;
            border-radius: 3px;
            text-align: center;
            background-color: #3c3c3c;
        }
        
        QProgressBar::chunk {
            background-color: #0078d7;
            border-radius: 2px;
        }
        
        QPlainTextEdit {
            background-color: #1e1e1e;
            border: 1px solid #555555;
            border-radius: 3px;
            font-family: "Consolas", "Courier New", monospace;
            font-size: 9pt;
            color: #d4d4d4;
        }
        
        QScrollBar:vertical {
            background-color: #2b2b2b;
            width: 12px;
            margin: 0px;
        }
        
        QScrollBar::handle:vertical {
            background-color: #555555;
            border-radius: 6px;
            min-height: 20px;
        }
        
        QScrollBar::handle:vertical:hover {
            background-color: #666666;
        }
        
        QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
            height: 0px;
        }
    )";
    
    app.setStyleSheet(styleSheet);
}

// 版本信息（如果 CMake 没有生成 version.h，使用默认值）
#ifndef AUTOQTPACKER_VERSION_STRING
#define AUTOQTPACKER_VERSION_STRING "1.0.0"
#endif

/**
 * @brief 应用程序主函数
 * @param argc 命令行参数数量
 * @param argv 命令行参数数组
 * @return 应用程序退出代码
 */
int main(int argc, char *argv[])
{
    // 创建 QApplication 实例
    QApplication app(argc, argv);
    
    // 设置应用程序信息
    app.setApplicationName("AutoQtPacker");
    app.setApplicationVersion(AUTOQTPACKER_VERSION_STRING);
    app.setOrganizationName("QtTools");
    app.setOrganizationDomain("qttools.example.com");
    
    // 加载应用程序样式
    loadApplicationStyle(app);
    
    // 设置高 DPI 支持
    app.setAttribute(Qt::AA_EnableHighDpiScaling);
    app.setAttribute(Qt::AA_UseHighDpiPixmaps);
    
    // 创建并显示主窗口
    MainWindow window;
    
    // 设置窗口标题包含版本信息
    window.setWindowTitle(QString("AutoQtPacker v%1 - Qt 项目打包工具").arg(AUTOQTPACKER_VERSION_STRING));
    window.show();
    
    // 记录应用程序启动信息
    qDebug() << "========================================";
    qDebug() << "AutoQtPacker 应用程序已启动";
    qDebug() << "应用程序名称:" << app.applicationName();
    qDebug() << "应用程序版本:" << AUTOQTPACKER_VERSION_STRING;
    qDebug() << "Qt 版本:" << qVersion();
    qDebug() << "构建时间:" << __DATE__ << __TIME__;
    qDebug() << "========================================";
    
    // 进入应用程序主事件循环
    return app.exec();
}

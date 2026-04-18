cmake_minimum_required(VERSION 3.20)

# 项目版本（可以通过命令行覆盖）
if(NOT DEFINED AUTOQTPACKER_VERSION)
    set(AUTOQTPACKER_VERSION "1.0.0")
endif()

# 解析版本号
string(REPLACE "." ";" VERSION_LIST ${AUTOQTPACKER_VERSION})
list(GET VERSION_LIST 0 VERSION_MAJOR)
list(GET VERSION_LIST 1 VERSION_MINOR)
list(GET VERSION_LIST 2 VERSION_PATCH)

project(AutoQtPacker VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH} LANGUAGES CXX)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 设置 Qt 路径（根据用户指定的路径）
set(QT_PATH "D:/Qt/6.7.3")
set(CMAKE_PREFIX_PATH ${QT_PATH})

# 查找 Qt 组件
find_package(Qt6 REQUIRED COMPONENTS Core Widgets Concurrent)

# 设置可执行文件输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/bin)

# 设置库文件输出目录
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/lib)

# 设置归档文件输出目录
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/lib)

# 设置 UI 文件 - 使用修复后的版本，添加了输出目录选择
set(UI_FILES
    MainWindow_fixed_with_output.ui
)

# 设置资源文件 - 使用修复后的版本，空资源文件
set(RESOURCE_FILES
    resources_fixed.qrc
)

# 添加可执行文件
add_executable(${PROJECT_NAME}
    main.cpp
    MainWindow.cpp
    PackerTask.cpp
    ${UI_FILES}
    ${RESOURCE_FILES}
)

# 启用自动 MOC
set_target_properties(${PROJECT_NAME} PROPERTIES
    AUTOMOC ON
)

# 自动处理 UI 文件
qt_wrap_ui(${PROJECT_NAME}_UI_HEADERS ${UI_FILES})

# 自动处理资源文件
qt_add_resources(${PROJECT_NAME}_RESOURCES ${RESOURCE_FILES})

# 链接 Qt 库
target_link_libraries(${PROJECT_NAME}
    Qt6::Core
    Qt6::Widgets
    Qt6::Concurrent
)

# 设置目标属性
target_include_directories(${PROJECT_NAME} PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

# 添加版本定义
target_compile_definitions(${PROJECT_NAME} PRIVATE 
    AUTOQTPACKER_VERSION_MAJOR=${VERSION_MAJOR}
    AUTOQTPACKER_VERSION_MINOR=${VERSION_MINOR}
    AUTOQTPACKER_VERSION_PATCH=${VERSION_PATCH}
    AUTOQTPACKER_VERSION_STRING="${AUTOQTPACKER_VERSION}"
)

# 创建版本头文件
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/version.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/version.h
)

# 在 Windows 上设置子系统
if(WIN32)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
endif()

# 安装目标
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION .
)

# 复制 Qt DLL 文件（构建后步骤）
if(WIN32)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "Note: For deployment, copy required Qt DLLs to output directory"
    )
endif()

# 打包目标（可选）
add_custom_target(package
    COMMAND ${CMAKE_COMMAND} -E echo "Packaging ${PROJECT_NAME}..."
    COMMAND ${CMAKE_COMMAND} -E tar cvf "${PROJECT_NAME}-${PROJECT_VERSION}.tar" "$<TARGET_FILE:${PROJECT_NAME}>"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    COMMENT "Creating package for ${PROJECT_NAME}"
)

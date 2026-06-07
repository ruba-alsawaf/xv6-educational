cmake_minimum_required(VERSION 3.16)

project(xv6ui VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

# 1. جلب كل المكتبات المطلوبة بما فيها مكتبة الواجهات والـ Sql والـ التأثيرات الرسومية
find_package(Qt6 REQUIRED COMPONENTS Quick Core5Compat Sql)

# 2. إعداد مشروع Qt القياسي بالإصدار المطلوب
qt_standard_project_setup(REQUIRES 6.8)

# 3. إنشاء ملف التنفيذ وربط كل ملفات الـ C++ وملف الموارد qrc فيه دفعة واحدة
qt_add_executable(appxv6ui
    main.cpp
    dbmanager.cpp
    dbmanager.h
    resources.qrc
)

# 4. إعداد موديل الـ QML وتنظيم الملفات البرمجية والصور بشكل نظيف بدون تكرار
qt_add_qml_module(appxv6ui
    URI xv6ui
    VERSION 1.0
    QML_FILES
        Main.qml
        CpuSchedulingPage.qml
        MemoryManagementPage.qml
        KernelGuardPage.qml
        ProcessForkPage.qml
        FileSystemLessonPage.qml
        OsArchitecturePage.qml
        CpuPrivilegeModesPage.qml
        TrapsOverviewPage.qml
        MemoryTranslationPage.qml
        KernelSpacePage.qml
        UserAddressSpacePage.qml
        ContextSwitchPage.qml
        FileSystem.qml
        NavigationLogic.js
        LoginPage.qml
        CpuQuizPage.qml
    RESOURCES
        test.png
)

# الإعدادات الخاصة بأنظمة التشغيل (Windows / macOS)
set_target_properties(appxv6ui PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# 5. ربط المكتبات برمجياً بملف التنفيذ النهائي
target_link_libraries(appxv6ui
    PRIVATE
        Qt6::Quick
        Qt6::Core5Compat
        Qt6::Sql
)

# إعدادات التثبيت (Installation)
include(GNUInstallDirs)
install(TARGETS appxv6ui
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
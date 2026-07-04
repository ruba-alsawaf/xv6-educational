cmake_minimum_required(VERSION 3.16)

project(xv6ui VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

# 1. جلب كل المكتبات المطلوبة بما فيها الـ Sql والـ Network الحيوية للشات بوت
find_package(Qt6 REQUIRED COMPONENTS Quick Core5Compat Sql Network)

# 2. إعداد مشروع Qt القياسي بالإصدار المطلوب
qt_standard_project_setup(REQUIRES 6.7)

# 3. إنشاء ملف التنفيذ وربط كل ملفات الـ C++ الأساسية وموارد الـ qrc
qt_add_executable(appxv6ui
    main.cpp
    dbmanager.cpp
    dbmanager.h
    chatbotclient.cpp
    chatbotclient.h
    resources.qrc
)

# 4. إعداد موديل الـ QML وتنظيم كافة الملفات البرمجية والدروس التفاعلية مع الشات بوت
qt_add_qml_module(appxv6ui
    URI xv6ui
    VERSION 1.0
    QML_FILES
        Main.qml
        LoginPage.qml
        ChatbotPanel.qml
        CpuSchedulingPage.qml
        RoundRobinPage.qml
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
        CpuQuizPage.qml
        LocksPage.qml
        PipesPage.qml
        FsOverviewPage.qml
        BufferCachePage.qml
        LoggingPage.qml
        InodesPage.qml
        QuizPage.qml
        KernelGuardQuizPage.qml
        ProcessForkQuizPage.qml
        OsArchitectureQuizPage.qml
        CpuPrivilegeQuizPage.qml
        TrapsOverviewQuizPage.qml
        MemoryTranslationQuizPage.qml
        KernelSpaceQuizPage.qml
        UserSpaceQuizPage.qml
        ContextSwitchQuizPage.qml
        RoundRobinQuizPage.qml
        LocksQuizPage.qml
        PipesQuizPage.qml
        FsOverviewQuizPage.qml
        BufferCacheQuizPage.qml
        LoggingQuizPage.qml
        InodesQuizPage.qml
        NavigationLogic.js
    RESOURCES
        test.png
    SOURCES
        chatbotclient.h
        chatbotclient.cpp
        SOURCES CoreEngineBackend.h
        SOURCES CoreEngineBackend.cpp
)

# الإعدادات الخاصة بأنظمة التشغيل (Windows / macOS)
set_target_properties(appxv6ui PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# 5. ربط جميع مكتبات Qt برمجياً بملف التنفيذ النهائي (بما فيها الـ Network)
target_link_libraries(appxv6ui
    PRIVATE
        Qt6::Quick
        Qt6::Core5Compat
        Qt6::Sql
        Qt6::Network
)

# إعدادات التثبيت (Installation)
include(GNUInstallDirs)
install(TARGETS appxv6ui
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

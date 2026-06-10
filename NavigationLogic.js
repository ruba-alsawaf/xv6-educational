.pragma library

// الألوان الموحدة للمشروع (Theme)
const Colors = {
    primaryOrange: "#FF8C00",
    textInactive: "#97969d",
    textActive: "#2c3e50",
    sidebarBg: "#f8f9fa",
    contentBg: "#ffffff"
}

function handleTabChange(index) {
    switch(index) {
        case 0:
            return "CpuSchedulingPage.qml"       // CPU SCHEDULING
        case 1:
            return "MemoryManagementPage.qml"    // MEMORY MANAGEMENT
        case 2:
            return "FileSystem.qml"              // FILE SYSTEM DASHBOARD
        case 3:
            return "KernelGuardPage.qml"         // LESSON 1: SYSTEM CALLS
        case 4:
            return "ProcessForkPage.qml"         // LESSON 2: PROCESSES & FORK
        case 5:
            return "FileSystemLessonPage.qml"    // LESSON 3: FILE SYSTEM LESSON
        case 6:
            return "OsArchitecturePage.qml"      // OS ARCHITECTURE
        case 7:
            return "CpuPrivilegeModesPage.qml"   // PRIVILEGE MODES
        case 8:
            return "TrapsOverviewPage.qml"       // TRAPS OVERVIEW
        case 9:
            return "MemoryTranslationPage.qml"   // MEMORY TRANSLATION
        case 10:
            return "KernelSpacePage.qml"         // KERNEL ADDRESS SPACE
        case 11:
            return "UserAddressSpacePage.qml"    // USER ADDRESS SPACE
        case 12:
            return "ContextSwitchPage.qml"       // CONTEXT SWITCH
        case 13:
            return "CpuQuizPage.qml"             // 💡 الحفاظ على كويز المعالج الخاص بكِ

        default:
            return "CpuSchedulingPage.qml"
    }
}

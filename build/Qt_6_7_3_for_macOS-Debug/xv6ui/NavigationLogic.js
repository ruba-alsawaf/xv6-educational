// NavigationLogic.js
.pragma library

// الألوان الموحدة للمشروع (Theme)
const Colors = {
    primaryOrange: "#FF8C00",
    textInactive: "#97969d",
    textActive: "#2c3e50",
    sidebarBg: "#f8f9fa",
    contentBg: "#ffffff"
}


// NavigationLogic.js
function handleTabChange(index) {

    // In your main.qml, you'd switch the StackView
    // But since you're returning the title, you might want to directly switch pages

    switch(index) {
            case 0:
                return "CpuSchedulingPage.qml"       // CPU SCHEDULING
            case 1:
                return "MemoryManagementPage.qml"          // MEMORY MANAGEMENT (مؤقتة)
            case 2:
                return "FileSystem.qml"
            case 3:
                return "KernelGuardPage.qml"         // LESSON 1: SYSTEM CALLS
            case 4:
                return "ProcessForkPage.qml"         // LESSON 2: PROCESSES & FORK
            case 5:
                return "FileSystemLessonPage.qml"    // LESSON 3: FILE SYSTEM
            case 6:
                return "OsArchitecturePage.qml"
            case 7:
                return "CpuPrivilegeModesPage.qml"
            case 8:
                return "TrapsOverviewPage.qml"
            case 9:
                return "MemoryTranslationPage.qml"
            case 10:
                return "KernelSpacePage.qml"
            case 11:
                return "UserAddressSpacePage.qml"
            case 12:
                return "ContextSwitchPage.qml";

            default:
                return "CpuSchedulingPage.qml"
        }
}

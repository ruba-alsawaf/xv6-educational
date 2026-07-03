.pragma library

const Colors = {
    primaryOrange: "#FF8C00",
    textInactive: "#97969d",
    textActive: "#2c3e50",
    sidebarBg: "#f8f9fa",
    contentBg: "#ffffff"
}

function handleTabChange(index) {
    switch(index) {
        case 0:  return "CpuSchedulingPage.qml"       // CPU SCHEDULING (Live Dashboard)
        case 1:  return "MemoryManagementPage.qml"    // MEMORY MANAGEMENT
        case 2:  return "FileSystem.qml"              // FILE SYSTEM DASHBOARD
        case 3:  return "KernelGuardPage.qml"         // LESSON 1: SYSTEM CALLS
        case 4:  return "ProcessForkPage.qml"         // LESSON 2: PROCESSES & FORK
        case 5:  return "OsArchitecturePage.qml"      // LESSON 3: OS ARCHITECTURE
        case 6:  return "CpuPrivilegeModesPage.qml"   // LESSON 4: PRIVILEGE MODES
        case 7:  return "TrapsOverviewPage.qml"       // LESSON 5: TRAPS OVERVIEW
        case 8:  return "MemoryTranslationPage.qml"   // LESSON 6: MEMORY TRANSLATION
        case 9:  return "KernelSpacePage.qml"         // LESSON 7: KERNEL ADDRESS SPACE
        case 10: return "UserAddressSpacePage.qml"    // LESSON 8: USER SPACE
        case 11: return "ContextSwitchPage.qml"       // LESSON 9: CONTEXT SWITCH
        case 12: return "RoundRobinPage.qml"          // LESSON 10: ROUND-ROBIN SCHEDULING
        case 13: return "LocksPage.qml"               // LESSON 11: LOCKS
        case 14: return "PipesPage.qml"               // LESSON 12: PIPES & FILE DESCRIPTORS
        case 15: return "FsOverviewPage.qml"          // LESSON 13: FS OVERVIEW
        case 16: return "BufferCachePage.qml"         // LESSON 14: BUFFER CACHE
        case 17: return "LoggingPage.qml"             // LESSON 15: LOGGING & CRASH RECOVERY
        case 18: return "InodesPage.qml"              // LESSON 16: INODES, DIRS & PATHS
        default: return "CpuSchedulingPage.qml"
    }
}

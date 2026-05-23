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
            return "CpuSchedulingPage.qml"
        case 1:
            return "MemoryManagementPage.qml"
        case 2:
            return "FileSystemPage"
    }
}

cmake_minimum_required(VERSION 3.16)
project(xv6_events_viewer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets Sql)

qt_standard_project_setup()

qt_add_executable(xv6_events_viewer
    main.cpp
)

target_link_libraries(xv6_events_viewer PRIVATE Qt6::Widgets Qt6::Sql)

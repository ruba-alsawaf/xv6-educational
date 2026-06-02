# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appxv6ui_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appxv6ui_autogen.dir\\ParseCache.txt"
  "appxv6ui_autogen"
  )
endif()

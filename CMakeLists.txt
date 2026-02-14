cmake_minimum_required(VERSION 3.15)
project(MacOSNativeApp LANGUAGES CXX OBJCXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required frameworks
find_library(COCOA_framework Cocoa)
find_library(APPKIT_framework AppKit)
find_library(FOUNDATION_framework Foundation)

# Create the executable
# Only main.mm is needed because it includes Windowing.mm directly.
add_executable(${PROJECT_NAME} src/main.mm)

# Compile options
target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra)

# Link libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    ${COCOA_framework}
    ${APPKIT_framework}
    ${FOUNDATION_framework}
)

# Set properties for macOS application bundle
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_BUNDLE_NAME "${PROJECT_NAME}"
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.hylmi.${PROJECT_NAME}"
    MACOSX_BUNDLE_BUNDLE_VERSION "1.0.0"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0"
)

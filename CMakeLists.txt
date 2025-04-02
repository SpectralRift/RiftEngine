cmake_minimum_required(VERSION 3.13.0)
project(RiftEngine VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

function(rift_bundle_folder SOURCE_FOLDER)
    if(NOT EXISTS ${SOURCE_FOLDER})
        message(FATAL_ERROR "Source folder ${SOURCE_FOLDER} does not exist.")
    endif()

    if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
        set(TARGET_NAME ${CMAKE_PROJECT_NAME})
    else()
        get_directory_property(TARGETS BUILDSYSTEM_TARGETS)
        if(TARGETS)
            list(GET TARGETS 0 TARGET_NAME)
        else()
            message(FATAL_ERROR "No target found in ${CMAKE_CURRENT_SOURCE_DIR}. Ensure the module defines a target.")
        endif()
    endif()

    set(DEST_FOLDER ${EXECUTABLE_OUTPUT_PATH}/DataRaw)

    message(STATUS "Bundling folder '${SOURCE_FOLDER}' into '${DEST_FOLDER}' for target '${TARGET_NAME}'...")

    add_custom_command(
            TARGET ${TARGET_NAME}
            POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${SOURCE_FOLDER}
            ${DEST_FOLDER}
            COMMENT "Bundled folder '${SOURCE_FOLDER}' to '${DEST_FOLDER}'"
    )
endfunction()

add_subdirectory(modules/RiftEngine.Core.Runtime)
if (NINTENDO_SWITCH)
    add_subdirectory(modules/RiftEngine.Platform.Console.DKPNX)
else()
    add_subdirectory(modules/RiftEngine.Platform.Desktop.Windows)
    add_subdirectory(modules/Rift.Backend.D3D9)
    add_subdirectory(modules/Rift.OnlineSubsystem.Steamworks)
endif()
add_subdirectory(modules/RiftEngine.Backend.OpenGL)

add_subdirectory(modules/Rift.Renderer.SimpleRenderer)
add_subdirectory(modules/RiftEngine.UI.ImGui)
add_subdirectory(modules/Rift.Runtime.Console)
add_subdirectory(modules/Rift.Runtime.Logging)
add_subdirectory(modules/Rift.Input)
add_subdirectory(modules/Rift.OnlineSubsystem)

add_library(RiftEngine STATIC main.cpp)

target_link_libraries(RiftEngine RiftEngine_Core_Runtime Rift_Renderer_SimpleRenderer Rift_UI_ImGui)
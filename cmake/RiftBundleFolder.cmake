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

    set(DEST_FOLDER ${CMAKE_BINARY_DIR}/DataRaw)

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
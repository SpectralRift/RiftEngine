function(rift_identify_modules MODULE_ROOT_DIRS OUTPUT_VAR)
    set(VALID_MODULES "")
    set(DEPENDENCY_MODULES "")
    set(HAS_RESOLVED_DEPS FALSE)

    while (NOT HAS_RESOLVED_DEPS)
        set(HAS_RESOLVED_DEPS TRUE)

        foreach (MODULE_ROOT_DIR ${MODULE_ROOT_DIRS})
            file(GLOB MODULE_DIRS LIST_DIRECTORIES true "${MODULE_ROOT_DIR}/*")

            foreach (MODULE_DIR ${MODULE_DIRS})
                # if this module has already been identified in the past we ignore it.
                if ("${MODULE_DIR}" IN_LIST VALID_MODULES)
                    continue()
                endif ()

                if (EXISTS "${MODULE_DIR}/CMakeLists.txt" AND EXISTS "${MODULE_DIR}/module.json")
                    file(READ "${MODULE_DIR}/module.json" MODULE_JSON)

                    string(JSON MODULE_NAME GET "${MODULE_JSON}" "module" "name")
                    string(JSON MODULE_VERSION GET "${MODULE_JSON}" "module" "version")
                    string(JSON MODULE_AUTHOR GET "${MODULE_JSON}" "module" "author")
                    string(JSON MODULE_DEPENDENCIES GET "${MODULE_JSON}" "dependencies")
                    string(JSON MODULE_TYPE GET "${MODULE_JSON}" "module" "type")

                    rift_json_to_list("${MODULE_DEPENDENCIES}" MODULE_DEPENDENCIES)

                    if (MODULE_TYPE STREQUAL "platformTarget")
                        # this module will provide platform support for a target.
                        # firstly, we check if we are forcing a platform target (if a specific platform target is active)
                        # and we error out if that's the case
                        if ("${MODULE_NAME}" IN_LIST RIFT_ACTIVE_MODULES)
                            message(FATAL_ERROR "The module '${MODULE_NAME}' was specified as an active module, but it represents a platform target which is automatically discovered by the build system. Please check the SpectralRift documentation for more information.")
                        else()
                            # if everything is alright, we check if the target is supported by this platform support module
                            string(JSON MODULE_PROVIDED_TARGETS GET "${MODULE_JSON}" "providedTargets")
                            rift_json_to_list("${MODULE_PROVIDED_TARGETS}" MODULE_PROVIDED_TARGETS)

                            # if the target is supported, we add it to the active list, thus allowing proper linkage with the engine
                            if("${RIFT_TARGET}" IN_LIST MODULE_PROVIDED_TARGETS)
                                message(STATUS "Rift Platform Module: ${MODULE_NAME} (v${MODULE_VERSION}) by ${MODULE_AUTHOR}")
                                list(APPEND RIFT_ACTIVE_MODULES ${MODULE_NAME})
                            endif()
                        endif ()
                    else ()
                        if ("${MODULE_NAME}" IN_LIST RIFT_ACTIVE_MODULES OR "${MODULE_NAME}" IN_LIST DEPENDENCY_MODULES)
                            # default case: standard module; here, we check if the module is supported on the current platform
                            string(JSON MODULE_SUPPORTED_TARGETS GET "${MODULE_JSON}" "supportedTargets")

                            # platform target check
                            if (NOT MODULE_SUPPORTED_TARGETS MATCHES "all" AND NOT MODULE_SUPPORTED_TARGETS MATCHES "${RIFT_TARGET}")
                                message(WARNING "Module '${MODULE_NAME}' is not supported on platform target '${RIFT_TARGET}'")
                                continue()
                            endif ()

                            message(STATUS "Rift Module: ${MODULE_NAME} (v${MODULE_VERSION}) by ${MODULE_AUTHOR}")
                        endif ()
                    endif ()

                    # check if this module is active or if it's in the dependency list
                    if ("${MODULE_NAME}" IN_LIST RIFT_ACTIVE_MODULES OR "${MODULE_NAME}" IN_LIST DEPENDENCY_MODULES)
                        # get dependencies of this module
                        foreach (DEPENDENCY ${MODULE_DEPENDENCIES})
                            if (NOT "${DEPENDENCY}" IN_LIST RIFT_ACTIVE_MODULES)
                                list(APPEND DEPENDENCY_MODULES "${DEPENDENCY}")
                                set(HAS_RESOLVED_DEPS FALSE)
                            endif ()
                        endforeach ()

                        # remove this module from the dependency list and add it to the active list
                        list(REMOVE_ITEM DEPENDENCY_MODULES ${MODULE_NAME})
                        list(APPEND RIFT_ACTIVE_MODULES "${MODULE_NAME}")
                        list(APPEND VALID_MODULES "${MODULE_DIR}")
                    endif ()
                else ()
                    message(WARNING "Skipping invalid module: ${MODULE_DIR} (missing CMakeLists.txt and/or module.json)")
                endif ()
            endforeach ()
        endforeach ()
    endwhile ()

    if (UNRESOLVED_DEPENDENCIES)
        message(FATAL_ERROR "Unresolved dependencies: ${UNRESOLVED_DEPENDENCIES}")
    endif ()

    list(REMOVE_DUPLICATES VALID_MODULES)
    list(REMOVE_DUPLICATES RIFT_ACTIVE_MODULES)

    set(${OUTPUT_VAR} ${VALID_MODULES} PARENT_SCOPE)
    set(RIFT_ACTIVE_MODULES ${RIFT_ACTIVE_MODULES} PARENT_SCOPE)
endfunction()
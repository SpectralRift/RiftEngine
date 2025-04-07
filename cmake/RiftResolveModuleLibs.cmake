function(rift_resolve_module_libs MODULE_NAMES OUTPUT_LIBS)
    set(OUTPUT_LIBS_TMP "")

    foreach (MODULE_ROOT_DIR ${RIFT_MODULE_PATHS})
        file(GLOB MODULE_DIRS LIST_DIRECTORIES true "${MODULE_ROOT_DIR}/*")

        foreach (MODULE_DIR ${MODULE_DIRS})
            if (EXISTS "${MODULE_DIR}/CMakeLists.txt" AND EXISTS "${MODULE_DIR}/module.json")
                file(READ "${MODULE_DIR}/module.json" MODULE_JSON)

                string(JSON MODULE_CMAKE_PROJECT GET "${MODULE_JSON}" "module" "cmakeProject")
                string(JSON MODULE_NAME GET "${MODULE_JSON}" "module" "name")

                if ("${MODULE_NAME}" IN_LIST MODULE_NAMES)
                    if(NOT "${MODULE_NAME}" IN_LIST RIFT_ACTIVE_MODULES)
                        message(WARNING "A request was made to get the libs for the '${MODULE_NAME}' module but it's not active.")
                        continue()
                    endif ()

                    list(APPEND OUTPUT_LIBS_TMP ${MODULE_CMAKE_PROJECT})
                endif ()
            endif ()
        endforeach ()
    endforeach ()

    set(${OUTPUT_LIBS} ${OUTPUT_LIBS_TMP} PARENT_SCOPE)
endfunction()
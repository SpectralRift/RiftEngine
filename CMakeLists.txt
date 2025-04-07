cmake_minimum_required(VERSION 3.13.0)
project(RiftEngine VERSION 1.0.0)

if (NOT RIFT_TARGET)
    message(FATAL_ERROR "Please define RIFT_TARGET in order to build for a specific target.")
endif ()

message(STATUS "SpectralRift Engine v${PROJECT_VERSION} for '${RIFT_TARGET}'")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

include(cmake/RiftBundleFolder.cmake)
include(cmake/RiftJsonToList.cmake)
include(cmake/RiftResolveModuleLibs.cmake)
include(cmake/RiftIdentifyModules.cmake)

# internal variables begin
# RIFT_ACTIVE_MODULES contains a list of all active modules that will be linked with this build of the engine
# provide a list of modules in the RIFT_ACTIVE_MODULES variable in order to add them to this list
set(RIFT_ACTIVE_MODULES ${RIFT_ACTIVE_MODULES} Rift.Core.Runtime Rift.Input Rift.Runtime.Logging Rift.Renderer.SimpleRenderer)

# RIFT_MODULE_PATHS contains a list of all the directories in which we will look for the modules
set(RIFT_MODULE_PATHS "${CMAKE_CURRENT_SOURCE_DIR}/modules")
# internal variables end

# remove duplicate modules
list(REMOVE_DUPLICATES RIFT_ACTIVE_MODULES)

rift_identify_modules("${RIFT_MODULE_PATHS}" RIFT_MODULE_DIRS)

# add module subdirs
foreach (MODULE_DIR ${RIFT_MODULE_DIRS})
    if (EXISTS "${MODULE_DIR}/CMakeLists.txt" AND EXISTS "${MODULE_DIR}/module.json")
        file(READ "${MODULE_DIR}/module.json" MODULE_JSON)

        string(JSON MODULE_CMAKE_PROJECT GET "${MODULE_JSON}" "module" "cmakeProject")
        string(JSON MODULE_NAME GET "${MODULE_JSON}" "module" "name")
        string(REPLACE "." "_" SANITIZED_MODULE_NAME "${MODULE_NAME}")

        add_subdirectory("${MODULE_DIR}" "${CMAKE_BINARY_DIR}/ModuleBuild/${SANITIZED_MODULE_NAME}")
    endif ()
endforeach ()

rift_resolve_module_libs("${RIFT_ACTIVE_MODULES}" RIFT_MODULE_LIBS)

add_library(RiftEngine STATIC src/EngineMain.cpp)

target_link_libraries(RiftEngine ${RIFT_MODULE_LIBS})
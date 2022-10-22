#########################
# Project Configuration #
#########################
cmake_minimum_required(VERSION 3.20.0)
project(pyproject-cookiecutter-example)
set(CMAKE_CXX_STANDARD 17)

######################
# CMake Dependencies #
######################
include(CheckCCompilerFlag)

##################
# CMake Policies #
##################

# option() should use new make behavior wrt variable clobbering
cmake_policy (SET CMP0077 NEW)

# Allow dep roots from env vars
cmake_policy (SET CMP0074 NEW)

# Set CMP0094 to NEW - find the first version that matches constraints,
# instead of the latest version installed
cmake_policy(SET CMP0094 NEW)

###############
# ENVIRONMENT #
###############
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    set(WIN32 ON)
    set(MACOS OFF)
    set(LINUX OFF)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(WIN32 OFF)
    set(MACOS ON)
    set(LINUX OFF)
else()
    set(WIN32 OFF)
    set(MACOS OFF)
    set(LINUX ON)
endif()


#########
# Paths #
#########
# Custom CMake modules
set (CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_SOURCE_DIR}/cpp/cmake/modules")
include_directories ("${CMAKE_SOURCE_DIR}/cpp/include")


#######################
# BUILD CONFIGURATION #
#######################
find_package (Color)

# Set build type
if (DEFINED ENV{DEBUG})
    set (CMAKE_BUILD_TYPE DEBUG)
else()
    if (NOT DEFINED CMAKE_BUILD_TYPE)
        set (CMAKE_BUILD_TYPE RELEASE)
    endif()
endif()

string(TOLOWER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_LOWER)

if(CMAKE_BUILD_TYPE_LOWER STREQUAL debug)
    message("${Red}Building DEBUG${ColorReset}")
    add_definitions(-DDEBUG)
else()
    message("${Cyan}Building RELEASE${ColorReset}")
endif()

# CCache setup
if(DEFINED ENV{USE_CCACHE})
    set(CMAKE_C_COMPILE_LAUNCHER ccache)
    set(CMAKE_CXX_COMPILER_LAUNCHER ccache)
endif()


if(MACOS)
    # fix for threads on osx
    # assume built-in pthreads on MacOS
    set(CMAKE_THREAD_LIBS_INIT "-lpthread")
    set(CMAKE_HAVE_THREADS_LIBRARY 1)
    set(CMAKE_USE_WIN32_THREADS_INIT 0)
    set(CMAKE_USE_PTHREADS_INIT 1)
    set(THREADS_PREFER_PTHREAD_FLAG ON)

    # don't link against build python
    # https://blog.tim-smith.us/2015/09/python-extension-modules-os-x/
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -undefined dynamic_lookup")

    # Support cross build
    check_c_compiler_flag("-arch x86_64" x86_64Supported)
    check_c_compiler_flag("-arch arm64" arm64Supported)

    if(x86_64Supported AND arm64Supported)
        set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "Build universal architecture for OSX" FORCE)
    elseif(x86_64Supported)
        set(CMAKE_REQUIRED_LINK_OPTIONS "-arch;x86_64")
        set(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE STRING "Build universal architecture for OSX" FORCE)
    elseif(arm64Supported)
        set(CMAKE_REQUIRED_LINK_OPTIONS "-arch;arm64")
        set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "Build universal architecture for OSX" FORCE)
    endif()
endif()

#########
# RPATH #
#########
if(NOT WIN32)
    set(CMAKE_SHARED_LIBRARY_SUFFIX .so)

    # Look for the binary using @loader_path (relative to binary location)
    set(CMAKE_MACOSX_RPATH TRUE)
    set(CMAKE_SKIP_BUILD_RPATH FALSE)
    set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    # set(CMAKE_INSTALL_NAME_DIR "@rpath")

    # module_origin_path is the location of the binary
    if(MACOS)
        set(module_origin_path "@loader_path")
    else()
        set(module_origin_path "\$ORIGIN")
    endif()
else()
    set(CMAKE_SHARED_LIBRARY_PREFIX lib)
endif()

#########
# FLAGS #
#########
# Compiler version flags
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c++1y")
endif()


# Optimization Flags
if(WIN32)
    if(CMAKE_BUILD_TYPE_LOWER STREQUAL debug)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
            /DEBUG \
            /Z7 \
            /Zi \
            ")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
            /NDEBUG \
            /O2 \
            ")
    endif()
else()
    if(CMAKE_BUILD_TYPE_LOWER STREQUAL debug)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
            -O0 \
            -g3 \
            ")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
            -O3 \
            -g0 \
            ")
    endif()
endif()

# Other Flags
if(WIN32)
    set(CMAKE_CXX_FLAGS " /EHsc /MP /bigobj")
    foreach(warning 4244 4251 4267 4275 4290 4786 4305 4996)
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd${warning}")
    endforeach(warning)
    add_compile_definitions(WIN32 _WIN32)
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
endif()

###############################################################################################################
# Install headers inside package
install(DIRECTORY "${PROJECT_SOURCE_DIR}/cpp/include/" DESTINATION include)

#########################
# Standalone C++ Binary #
#########################
add_library(standalone SHARED "${PROJECT_SOURCE_DIR}/cpp/src/standalone.cpp")

# export symbols
if (WIN32)
    target_compile_definitions(standalone PRIVATE LIB_EXPORTS)
endif()

add_executable(executable "${PROJECT_SOURCE_DIR}/cpp/src/executable.cpp")
target_link_libraries(executable PUBLIC standalone)

# install standalone library and executable inside package
install(TARGETS standalone LIBRARY DESTINATION lib)
install(TARGETS executable LIBRARY DESTINATION bin)
set_property(TARGET executable PROPERTY INSTALL_RPATH "${module_origin_path}/../lib")

####################
# Pybind Extension #
####################
# Find Numpy
find_package(NumPy REQUIRED)

# Find PyBind11
find_package(pybind11 REQUIRED)

# Extension
pybind11_add_module(_extension MODULE "${PROJECT_SOURCE_DIR}/cpp/src/extension.cpp")

# Link to standalone library
target_link_libraries(_extension PUBLIC standalone)
set_property(TARGET _extension PROPERTY INSTALL_RPATH "${module_origin_path}/lib")

# install in python module
install(TARGETS _extension LIBRARY DESTINATION .)

####################
# Cython Extension #
####################
add_subdirectory("${PROJECT_SOURCE_DIR}/pyproject_cookiecutter_example/")

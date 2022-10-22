# ##################################################
# Helper to grab dependencies from remote sources #
# ##################################################
function(install_dependency name cmake_file)
    if(EXISTS ${CMAKE_BINARY_DIR}/${name}-build)
        message("${Cyan}Dependency found - not rebuilding - ${CMAKE_BINARY_DIR}/${name}-build${ColorReset}")
    else()
        configure_file(${cmake_file} ${name}-download/CMakeLists.txt)

        execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
            RESULT_VARIABLE result
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/${name}-download)

        if(result)
            message(FATAL_ERROR "CMake step for ${name} failed: ${result}")
        endif()

        execute_process(COMMAND ${CMAKE_COMMAND} --build .
            RESULT_VARIABLE result
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/${name}-download)

        if(result)
            message(FATAL_ERROR "Build step for ${name} failed: ${result}")
        endif()
    endif()

    add_subdirectory(${CMAKE_BINARY_DIR}/${name}-src ${CMAKE_BINARY_DIR}/${name}-build)
    include_directories(${CMAKE_BINARY_DIR}/${name}-src)
    include_directories(${CMAKE_BINARY_DIR}/${name}-src/extras/${name}/include)
    include_directories(${CMAKE_BINARY_DIR}/${name}-src/include)
endfunction()

# #############################
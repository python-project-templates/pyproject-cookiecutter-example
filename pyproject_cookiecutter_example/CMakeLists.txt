####################
# Cython Extension #
####################

# Find Cython
find_package(PythonExtensions REQUIRED)
find_package(Cython REQUIRED)

add_cython_target(_cyextension CXX)
add_library(_cyextension MODULE ${_cyextension})
python_extension_module(_cyextension)

install(TARGETS _cyextension LIBRARY DESTINATION .)

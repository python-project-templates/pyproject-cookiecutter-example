#pragma once
#include <iostream>
#include <pybind11/pybind11.h>

#include "example-python/standalone.hpp"

namespace py = pybind11;

PYBIND11_MODULE(_extension, m) {
    m.doc() = "_extension";
    m.def("hello", &hello, "Prints \"Hello, World!\"");
    m.def("return_two", &return_two, "Returns 2");
}


import os
import os.path

from ._version import __version__
def _jupyter_server_extension_paths():
    return [{"module": "example_python.extension"}]
def include_path():
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "include"))


def bin_path():
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "bin"))


def lib_path():
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "lib"))
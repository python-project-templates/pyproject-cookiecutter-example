from ._version import __version__


def _jupyter_server_extension_paths():
    return [{"module": "pyproject_cookiecutter_example.extension"}]

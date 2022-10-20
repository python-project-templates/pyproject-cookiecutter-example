from skbuild import setup
from codecs import open
from os import path

from jupyter_packaging import (
    create_cmdclass,
    install_npm,
    ensure_targets,
    combine_commands,
)

pjoin = path.join

name = "example-python"
here = path.abspath(path.dirname(__file__))
jshere = path.abspath(path.join(here, "js"))

with open(path.join(here, "README.md"), encoding="utf-8") as f:
    long_description = f.read().replace("\r\n", "\n")

requires = ["jupyterlab>=3.0.0", "notebook>=6.0.3"]

requires_dev = requires + [
    "black>=20.",
    "bump2version>=1.0.0",
    "flake8>=3.7.8",
    "flake8-black>=0.2.1",
    "jupyter_packaging",
    "mock",
    "pytest>=4.3.0",
    "pytest-cov>=2.6.1",
    "Sphinx>=1.8.4",
    "sphinx-markdown-builder>=0.5.2",
]


data_spec = [
    # Lab extension installed by default:
    (
        "share/jupyter/labextensions/jupyterlab_commands",
        "jupyterlab_commands/labextension",
        "**",
    ),
    # Config to enable server extension by default:
    ("etc/jupyter/jupyter_server_config.d", "jupyter-config", "*.json"),
]


cmdclass = create_cmdclass("js", data_files_spec=data_spec)
cmdclass["js"] = combine_commands(
    install_npm(jshere, build_cmd="build:all"),
    ensure_targets(
        [
            pjoin(jshere, "lib", "index.js"),
            pjoin(jshere, "style", "index.css"),
            pjoin(here, "jupyterlab_commands", "labextension", "package.json"),
        ]
    ),
)


setup(
    name=name,
    version="0.1.0",
    description="An example instance of [timkpaine/pyproject-cookiecutter](https://github.com/timkpaine/pyproject-cookiecutter), for testing",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/timkpaine/pyproject-cookiecutter",
    author="Tim Paine",
    author_email="t.paine154@gmail.com",
    license="Apache 2.0",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Framework :: Jupyter",
        "Framework :: Jupyter :: JupyterLab",
    ],
    cmdclass=cmdclass,
    keywords="jupyter jupyterlab",
    packages=["example_python"],
    cmake_install_dir="example_python",
    cmake_with_sdist=True,
    zip_safe=False,
    extras_require={
        "dev": requires_dev,
        "develop": requires_dev,
    },
    python_requires=">=3.7",
)

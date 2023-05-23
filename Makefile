#########
# BUILD #
#########
.PHONY: develop build-py build-js build install serverextension labextension

develop:  ## install dependencies and build library
	python -m pip install -U cython ninja pip pybind11[global] scikit-build twine wheel
	python -m pip install -e .[develop]

build-py:  ## build the python library
	python setup.py build build_ext --inplace

build: build-py  ## build the library

install:  ## install library
	python -m pip install .

#########
# LINTS #
#########
.PHONY: lint-py lint-js lint-cpp lint  lints fix-py fix-js fix-cpp fix format

lint-py:  ## run python linter with flake8 and black
	python -m ruff pyproject_cookiecutter_example setup.py
	python -m black --check pyproject_cookiecutter_example setup.py

lint-cpp:  ## run C++ linter with clang-format
	clang-format --dry-run -Werror -i -style=file `find ./cpp/{src,include} -name "*.*pp"`

# lint: lint-py lint-cpp  ## run all lints
lint: lint-py  ## run all lints

# Alias
lints: lint

fix-py:  ## fix python formatting with black
	python -m black pyproject_cookiecutter_example/ setup.py
	python -m ruff pyproject_cookiecutter_example/ setup.py --fix

fix-cpp:  ## fix C++ formatting with clang-format
	clang-format -i -style=file `find ./cpp/{src,include} -name "*.*pp"`

fix: fix-py fix-cpp  ## run all autofixers

# alias
format: fix

################
# Other Checks #
################
.PHONY: check-manifest semgrep checks check annotate
check-manifest:  ## check python sdist manifest with check-manifest
	check-manifest -v

semgrep:  ## check for possible errors with semgrep
	semgrep ci --config auto

checks: check-manifest semgrep

# Alias
check: checks

annotate:  ## run python type annotation checks with mypy
	python -m mypy ./pyproject_cookiecutter_example

#########
# TESTS #
#########
.PHONY: test-py test-js coverage-py test coverage tests

test-py:  ## run python tests
	python -m pytest -v pyproject_cookiecutter_example/tests --junitxml=junit.xml

coverage-py:  ## run tests and collect test coverage
	python -m pytest -v pyproject_cookiecutter_example/tests --junitxml=junit.xml --cov=pyproject_cookiecutter_example --cov-branch --cov-fail-under=80 --cov-report term-missing --cov-report xml

test: test-py  ## run all tests

coverage: coverage-py  ## run all tests with coverage collection

# Alias
tests: test

########
# DOCS #
########
.PHONY: docs show-docs

docs:  ## build html documentation
	make -C ./docs html

show-docs:  ## show docs with running webserver
	cd ./docs/_build/html/ && PYTHONBUFFERED=1 python -m http.server | sec -u "s/0\.0\.0\.0/$$(hostname)/g"

###########
# VERSION #
###########
.PHONY: show-version patch minor major

show-version:  ## show current library version
	bump2version --dry-run --allow-dirty setup.py --list | grep current | awk -F= '{print $2}'

patch:  ## bump a patch version
	bump2version patch

minor:  ## bump a minor version
	bump2version minor

major:  ## bump a major version
	bump2version major

########
# DIST #
########
.PHONY: dist-py dist-py-sdist dist-py-local-wheel publish-py publish-js publish

dist-py: dist-py-sdist  # build python dist

dist-py-sdist:  ## build python sdist
	python setup.py sdist

dist-py-local-wheel:  ## build python wheel
	python setup.py bdist_wheel

dist-check:  ## run python dist checker with twine
	python -m twine check dist/*

dist: clean build dist-py dist-check  ## build all dists

publish-py:  # publish python assets
	python -m twine upload dist/* --skip-existing

publish: dist publish-py  ## publish all dists

#########
# CLEAN #
#########
.PHONY: deep-clean clean

deep-clean: ## clean everything from the repository
	git clean -fdx

clean: ## clean the repository
	rm -rf .coverage coverage cover htmlcov logs build dist *.egg-info
	rm -rf pyproject_cookiecutter_example/lib pyproject_cookiecutter_example/bin pyproject_cookiecutter_example/include pyproject_cookiecutter_example/*.so pyproject_cookiecutter_example/*.dll pyproject_cookiecutter_example/*.dylib _skbuild

############################################################################################

.PHONY: help

# Thanks to Francoise at marmelab.com for this
.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

print-%:
	@echo '$*=$($*)'

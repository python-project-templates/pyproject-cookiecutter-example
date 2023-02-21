#########
# BUILD #
#########
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
lint-py:
	python -m flake8 pyproject_cookiecutter_example setup.py
lint-cpp:
	clang-format --dry-run -Werror -i -style=file `find ./cpp/{src,include} -name "*.*pp"`
# lint: lint-py lint-cpp  ## run lints
lint: lint-py  ## run lints

# Alias
lints: lint

fix-py:
	python -m black pyproject_cookiecutter_example/ setup.py
fix-cpp:
	clang-format -i -style=file `find ./cpp/{src,include} -name "*.*pp"`
fix: fix-py fix-cpp  ## run autofixers

# alias
format: fix

check:
	check-manifest -v

# Alias
checks: check

annotate:
	python -m mypy ./pyproject_cookiecutter_example

#########
# TESTS #
#########
test-py: ## Clean and Make unit tests
	python -m pytest -v pyproject_cookiecutter_example/tests --junitxml=python_junit.xml

coverage-py:
	python -m pytest -v pyproject_cookiecutter_example/tests --junitxml=python_junit.xml --cov=pyproject_cookiecutter_example --cov-report=xml:.coverage/coverage.xml --cov-report=html:.coverage/coverage.html --cov-branch --cov-fail-under=80 --cov-report term-missing

show-coverage: coverage-py
	cd .coverage && PYTHONBUFFERED=1 python -m http.server | sec -u "s/0\.0\.0\.0/$$(hostname)/g"
test: test-py  ## run the tests

# Alias
tests: test

########
# DOCS #
########
docs:  ## make documentation
	make -C ./docs html

show-docs:
	cd ./docs/_build/html/ && PYTHONBUFFERED=1 python -m http.server | sec -u "s/0\.0\.0\.0/$$(hostname)/g"

###########
# VERSION #
###########
show-version:
	bump2version --dry-run --allow-dirty setup.py --list | grep current | awk -F= '{print $2}'

patch:
	bump2version patch

minor:
	bump2version minor

major:
	bump2version major

########
# DIST #
########
dist-py: dist-py-sdist  # Build python dist
dist-py-sdist:
	python setup.py sdist

dist-py-local-wheel:
	python setup.py bdist_wheel

dist-check:
	python -m twine check dist/*
dist: clean build dist-py dist-check  ## Build dists

publish-py:  # Upload python assets
	python -m twine upload dist/* --skip-existing
publish: dist publish-py  ## Publish dists

#########
# CLEAN #
#########
deep-clean: ## clean everything from the repository
	git clean -fdx

clean: ## clean the repository
	rm -rf .coverage coverage cover htmlcov logs build dist *.egg-info
	rm -rf pyproject_cookiecutter_example/lib pyproject_cookiecutter_example/bin pyproject_cookiecutter_example/include pyproject_cookiecutter_example/*.so pyproject_cookiecutter_example/*.dll pyproject_cookiecutter_example/*.dylib _skbuild

############################################################################################

# Thanks to Francoise at marmelab.com for this
.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

print-%:
	@echo '$*=$($*)'

.PHONY: clean install serverextension labextension test tests help docs dist js

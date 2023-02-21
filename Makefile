#########
# BUILD #
#########
develop:  ## install dependencies and build library
	python -m pip install -e .[develop]
	cd js; yarn

build-py:  ## build the python library
	python -m build .
build-js:  ## build javascript
	cd js; yarn build
build: build-py build-js  ## build the library

install:  ## install library
	python -m pip install .
serverextension: install ## enable the jupyter server extension
	python -m jupyter server extension enable --py pyproject_cookiecutter_example

labextension: js ## build and install the labextension
	cd js; python -m jupyter labextension install .

#########
# LINTS #
#########
lint-py:  ## run python linter with flake8 and black
	python -m ruff pyproject_cookiecutter_example setup.py
	python -m black --check pyproject_cookiecutter_example setup.py
lint-js:  ## run javascript linter with eslint
	cd js; yarn lint
lint: lint-py lint-js  ## run all lints

# Alias
lints: lint

fix-py:  ## fix python formatting with black
	python -m ruff pyproject_cookiecutter_example/ setup.py --fix
	python -m black pyproject_cookiecutter_example/ setup.py
fix-js:  ## fix javascript formatting with eslint
	cd js; yarn fix
fix: fix-py fix-js  ## run all autofixers

# alias
format: fix

################
# Other Checks #
################
check-manifest:  ## check python sdist manifest with check-manifest
	check-manifest -v

semgrep:  ## check for possible errors with semgrep
	semgrep ci --config auto

checks: check-manifest semgrep

# Alias
check: checks

annotate:  ## run python type annotation checks with mypy
	python -m mypy ./pyproject_cookiecutter_example

semgrep: 

#########
# TESTS #
#########
test-py:  ## run python tests
	python -m pytest -v pyproject_cookiecutter_example/tests --junitxml=python_junit.xml
test-js: ## run javascript tests
	cd js; yarn test

coverage-py:  ## run tests and collect test coverage
	python -m pytest -v pyproject_cookiecutter_example/tests --junitxml=python_junit.xml --cov=pyproject_cookiecutter_example --cov-report=xml:.coverage/coverage.xml --cov-report=html:.coverage/coverage.html --cov-branch --cov-fail-under=80 --cov-report term-missing

show-coverage: coverage-py  ## show interactive python coverage viewer
	cd .coverage && PYTHONBUFFERED=1 python -m http.server | sec -u "s/0\.0\.0\.0/$$(hostname)/g"
test: test-py test-js ## run all tests

# Alias
tests: test

########
# DOCS #
########
docs:  ## build html documentation
	make -C ./docs html

show-docs:  ## show docs with running webserver
	cd ./docs/_build/html/ && PYTHONBUFFERED=1 python -m http.server | sec -u "s/0\.0\.0\.0/$$(hostname)/g"

###########
# VERSION #
###########
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
dist-py:  # build python dists
	python setup.py sdist bdist_wheel

dist-check:  ## run python dist checker with twine
	python -m twine check dist/*
dist: clean build dist-py dist-check  ## build all dists

publish-py:  # publish python assets
	python -m twine upload dist/* --skip-existing
publish-js:  ## pulbish javascript assets
	cd js; npm publish || echo "can't publish - might already exist"
publish: dist publish-py publish-js  ## publish dists

#########
# CLEAN #
#########
deep-clean: ## clean everything from the repository
	git clean -fdx

clean: ## clean the repository
	rm -rf .coverage coverage cover htmlcov logs build dist *.egg-info
	rm -rf js/lib js/dist pyproject_cookiecutter_example/labextension pyproject_cookiecutter_example/nbextension

############################################################################################

# Thanks to Francoise at marmelab.com for this
.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

print-%:
	@echo '$*=$($*)'

.PHONY: develop build-py build-js build build install serverextension labextension lint-py lint-js lint-cpp lint lints fix-py fix-js fix-cpp fix format check-manifest checks check annotate semgrep test-py test-js coverage-py show-coverage test tests docs show-docs show-version patch minor major dist-py dist-py-sdist dist-py-local-wheel dist-check dist publish-py publish-js publish deep-clean clean help 
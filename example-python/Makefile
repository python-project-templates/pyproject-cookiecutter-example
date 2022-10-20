#########
# BUILD #
#########
develop:  ## install dependencies and build library
	python -m pip install -e .[develop]

build-py:  ## build the python library
	python setup.py build build_ext --inplace

build: build-py  ## build the library

install:  ## install library
	python -m pip install .

serverextension: install ## enable serverextension
	python -m jupyter serverextension enable --py example_python

js:  ## build javascript
	cd js; yarn
	cd js; yarn build:all

labextension: js ## enable labextension
	cd js; python -m jupyter labextension install .

#########
# LINTS #
#########
lint-py:
	python -m flake8 example_python setup.py

lint-js:
	cd js; yarn lint

lint-cpp:
	clang-format --dry-run -Werror -i -style=file `find ./cpp/{src,include} -name "*.*pp"`

lint: lint-py lint-js  ## run lints

# Alias
lints: lint

fix-py:
	python -m black example_python/ setup.py

fix-js:
	cd js; yarn fix

fix-cpp:
	clang-format -i -style=file `find ./cpp/{src,include} -name "*.*pp"`

fix: fix-py fix-js  ## run autofixers

# alias
format: fix

check:
	check-manifest -v

# Alias
checks: check

annotate:
	python -m mypy ./example_python

#########
# TESTS #
#########
test-js: ## Clean and Make js tests
	cd js; yarn test

test-py: ## Clean and Make unit tests
	python -m pytest -v example_python/tests --junitxml=python_junit.xml

coverage-py:
	python -m pytest -v example_python/tests --junitxml=python_junit.xml --cov=example_python --cov-report=xml:.coverage/coverage.xml --cov-report=html:.coverage/coverage.html --cov-branch --cov-fail-under=80 --cov-report term-missing

show-coverage: coverage-py
	cd .coverage && PYTHONBUFFERED=1 python -m http.server | sec -u "s/0\.0\.0\.0/$$(hostname)/g"

test: test-py test-js ## run the tests

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
dist-py:
	python setup.py sdist bdist_wheel

dist-check:
	python -m twine check dist/*

dist: clean build js dist-py dist-check  ## create dists

publish-py:
	python -m twine upload dist/* --skip-existing

publish-js:
	cd js; npm publish || echo "can't publish - might already exist"

publish: dist publish-py publish-js  ## dist to pypi and npm

#########
# CLEAN #
#########
deep-clean: ## clean everything from the repository
	git clean -fdx

clean: ## clean the repository
	rm -rf .coverage coverage cover htmlcov logs build dist *.egg-info js/lib


############################################################################################

# Thanks to Francoise at marmelab.com for this
.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

print-%:
	@echo '$*=$($*)'

.PHONY: clean install serverextension labextension test tests help docs dist js

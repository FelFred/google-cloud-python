#!/bin/bash

# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ev

GH_OWNER='GoogleCloudPlatform'
GH_PROJECT_NAME='google-cloud-python'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to build the docs.
function build_docs {
    rm -rf docs/_build/
    sphinx-build -W -b html -d docs/_build/doctrees docs/ docs/_build/html/
    return $?
}

# Only update docs if we are on CircleCI.
if [[ "${CIRCLE_BRANCH}" == "master" ]] && [[ -z "${CIRCLE_PR_NUMBER}" ]]; then
    echo "Building new docs on a merged commit."
elif [[ -n "${CIRCLE_TAG}" ]]; then
    echo "Building new docs on a tag (but will not deploy)."
    build_docs
    exit $?
else
    echo "Not on master nor a release tag."
    echo "Building new docs for testing purposes, but not deploying."
    build_docs
    exit $?
fi

# Adding GitHub pages branch. `git submodule add` checks it
# out at HEAD.
GH_PAGES_DIR='ghpages'
git submodule add -q -b gh-pages \
    "git@github.com:${GH_OWNER}/${GH_PROJECT_NAME}" ${GH_PAGES_DIR}

# Determine if we are building a new tag or are building docs
# for master. Then build new docs in docs/_build from master.
if [[ -n "${CIRCLE_TAG}" ]]; then
    # Sphinx will use the package version by default.
    build_docs
else
    SPHINX_RELEASE=$(git log -1 --pretty=%h) build_docs
fi

# Get the current version.
# This is only likely to work from within nox, because the google-cloud
# package must be installed.
CURRENT_VERSION=$(python ${DIR}/get_version.py)

# Update gh-pages with the created docs.
cd ${GH_PAGES_DIR}
if [[ -n "${CIRCLE_TAG}" ]]; then
    if [[ -d ${CURRENT_VERSION} ]]; then
        echo "The directory ${CURRENT_VERSION} already exists."
        exit 1
    fi
    git rm -fr stable/

    # Put the new release in stable and with the actual version.
    cp -R ../docs/_build/html/ stable/
    cp -R ../docs/_build/html/ "${CURRENT_VERSION}/"
else
    git rm -fr latest/
    cp -R ../docs/_build/html/ latest/
fi

# Update the files push to gh-pages.
git add .
git status

# If there are no changes, just exit cleanly.
if [[ -z "$(git status --porcelain)" ]]; then
    echo "Nothing to commit. Exiting without pushing changes."
    exit
fi

# Commit to gh-pages branch to apply changes.
git config --global user.email "googleapis-publisher@google.com"
git config --global user.name "Google APIs Publisher"
git commit -m "Update docs after merge to master."

# NOTE: This may fail if two docs updates (on merges to master)
#       happen in close proximity.
git push -q origin HEAD:gh-pages

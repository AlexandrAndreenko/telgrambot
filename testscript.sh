#!/usr/bin/env bash

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo Illegal number of parameters
    exit
fi
TEST_MSG=''
if [[ "$1" = *'test'* ]]; then
   TEST_MSG=' test'
fi

FORCE_CLEAR_CACHE=0
SKIP_CLEAR_CACHE=0

for i in $@; do
    if [[ $i == '-fcc' || $i == '--force-clear-cache' ]]; then
        FORCE_CLEAR_CACHE=1
    fi
    if [[ $i == '-scc' || $i == '--skip-clear-cache' ]]; then
        SKIP_CLEAR_CACHE=1
    fi
done

if [[ ( $2 == 'worker' || $1 == *'worker'* ) && $2 != 'server' ]]; then
    ENV_TYPE=worker
    echo '.ebextensions/https-backendsecurity.config export-ignore' > ./.gitattributes
    if [[ $FORCE_CLEAR_CACHE -eq 0 ]]; then
        echo "Building for worker"
        echo '.ebextensions/v_clear_metadata_cache.config export-ignore' >> ./.gitattributes
    else
        echo "Building for worker, proxy cache will update"
    fi
    git archive -o ./build.zip --worktree-attributes HEAD
    rm ./.gitattributes
else
    ENV_TYPE=server
    if [[ $SKIP_CLEAR_CACHE -eq 1 ]]; then
        echo "Building for server, proxy cache will not update"
        echo '.ebextensions/v_clear_metadata_cache.config export-ignore' > ./.gitattributes
        git archive -o ./build.zip --worktree-attributes HEAD
        rm ./.gitattributes
    else
        echo "Building for server"
        git archive -o ./build.zip HEAD
    fi
fi
echo Done building
echo "Deploying $ENV_TYPE build to $1 in 3 seconds"
sleep 3
echo Deploying
eb deploy $1 --staged -m "$ENV_TYPE$TEST_MSG"

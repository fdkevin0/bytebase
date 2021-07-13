#!/bin/sh

# cd to the root directory and run
# ./build_docker_bb.sh

# exit when any command fails
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

VERSION=`cat ./VERSION`
echo "Start building bb docker image ${VERSION}..."

docker build -f ./Dockerfile.bb\
    --build-arg VERSION=${VERSION} \
    --build-arg GO_VERSION="$(go version)" \
    --build-arg GIT_COMMIT="$(git rev-parse HEAD)"\
    --build-arg BUILD_TIME="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"  \
    --build-arg BUILD_USER="$(id -u -n)" \
    -t bytebase/bb .

echo "${GREEN}Completed building bb docker image ${VERSION}.${NC}"
echo ""
echo "Command to tag and push the image"
echo ""
echo "$ docker tag bytebase/bb bytebase/bb:${VERSION}; docker push bytebase/bb:${VERSION}"
echo "Command to run bb"
echo ""
echo "$ docker run --rm --name bb bytebase/bb"
echo ""
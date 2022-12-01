#!/bin/bash
if [ $# -lt 1 ]; then
  echo "Build the service Docker image."
  echo "Usage: $0 <ecr-cfn-stack-name> [<docker-image-tag>]"
  exit 1
fi

NAME="$1"
TAG="$2"

if [ -z "$TAG" ]; then
  TAG="test"
fi

set -x
docker build -t "${NAME}:${TAG}" docker

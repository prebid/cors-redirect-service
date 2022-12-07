set -x
if [ $# -lt 1 ]; then
  echo "Push the Docker image to its ECR repo."
  echo "Usage: $0 <ecr-cfn-stack-name> [<docker-image-tag>]"
  exit 1
fi

NAME="$1"
TAG="$2"

if [ -z "$AWS" ]; then
  AWS="aws"
fi

if [ -z "$TAG" ]; then
  TAG="latest"
fi

if [ -z "$ECR_REPOSITORY" ]; then
  ECR_REPOSITORY=$($AWS cloudformation list-exports | jq -r '.Exports[] | select(.Name=="cors-redirector-ecr-'"${NAME}"'") | .Value')
fi

$($AWS ecr get-login --no-include-email) || exit 1
docker tag "${NAME}:${TAG}" "${ECR_REPOSITORY}:${TAG}" || exit 1
docker push "${ECR_REPOSITORY}:${TAG}"

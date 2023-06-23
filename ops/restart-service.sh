if [ $# -lt 1 ]; then
  echo "Restart the service, forcing a re-pull of the Docker image."
  echo "Usage: $0 <cfn-stack-name>"
  exit 1
fi


if [ -z "$AWS" ]; then
  AWS="aws"
fi

set -x
$AWS ecs update-service --force-new-deployment --service "${1}-service" --cluster "${1}-ecs-cluster"

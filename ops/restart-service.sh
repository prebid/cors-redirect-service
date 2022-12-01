if [ $# -lt 1 ]; then
  echo "Restart the service, forcing a re-pull of the Docker image."
  echo "Usage: $0 <cfn-stack-name>"
  exit 1
fi


if [ -z "$AWS" ]; then
  AWS="aws"
fi

exports=$($AWS cloudformation list-exports)
cluster=$(echo $exports | jq -r '.Exports[] | select(.Name=="'$1'-cluster") | .Value')
service=$(echo $exports | jq -r '.Exports[] | select(.Name=="'$1'-service") | .Value')

if [ -z "$cluster" ]; then
  echo "Cannot find ECS output parameters for stack $1"
  exit 1
fi

set -x
$AWS ecs update-service --force-new-deployment --service "$service" --cluster "$cluster"

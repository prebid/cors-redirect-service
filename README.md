# CORS redirect service

This is a template for a very simple HTTP(S) redirect service that replies to all request with a 301 to a fixed location and includes CORS headers.

## Operations

### Requirements

- AWS CLI, with configuration (at least credentials and region). You may use its config files or set the AWS environment variable, e.g. `export AWS="aws --profile ..."`
- docker
- jq

### First deployment

1. Create a CFN stack using the `cfn/erc.yaml` template. This needs to be done only once; you can re-use the same stack for multiple related deployments (e.g. testing and prod).
2. Build the Docker image using the CFN stack name you chose in step 1:
  ```
  # ./ops/build-docker-image.sh <erc-cfn-stack-name> [<docker-image-tag>]
  # For example:
  ./ops/build-docker-image.sh my-fantastic-service prod
  ```
3. Push the image to ECR:
  ```
  # ./ops/push-docker-image.sh <erc-cfn-stack-name> [<docker-image-tag>]
  # For example:
  ./ops/push-docker-image.sh my-fantastic-service prod
  ```
4. Create a CFN stack using the `cfn/redirector.yaml` template.

### Re-deploying the Docker image

If you need to update the image (after changing anything under `docker/`):

- Repeat steps 2 and 3 from above
- Force an ECS deployment using the CFN stack name you chose for `cfn/redirector.yml` in step 4:
  ```
  # ./opts/restart-service.sh <cfn-stack-name>
  # For example:
  ./ops/restart-service.sh my-fantastic-service-prod
  ```
  
### Scaling

The service will autoscale horizontally based on the values provided to the CFN template parameters: 
containers (and instances) are spun up or down to maintain at least `MinTPSCapacity` regardless of traffic, and approximately `TargetSpareTPSCapacity` above traffic. 

All parameters can be updated through a CFN stack update.

To scale vertically, change the `InstanceType` parameter, and adjust the value of `ContainerTPS` accordingly. The service is network-bound so container performance depends on the instance type. These values been verified through load tests:

 - With instance type `c6i.large`, ContainerTPS should be `2000`
 - With instance type `t2.medium`, ContainerTPS should be `350`

**NOTE**: Updating `InstanceType` will not affect running instances. If you are scaling down you will need to manually terminate them; make sure to temporarily increase `MinTPSCapacity` before doing so to avoid outages.  

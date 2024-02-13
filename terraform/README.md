This is the terraform project that we used to setup & host the sapiocon examples inside of AWS. 

It's broken into a few different modules, each of which is responsible for a different part of the infrastructure. The modules are:

**base_vpc**
- A simple VPC stack with a subnet, public internet gateway, and all the routing to go with it.

**base_https_lb**
- Will create a HTTPS load balancer that will have a certificate assigned via AWS ACM.

**base_ecs_fargate_service**
- Hosts a fargate service that runs the sapiocon Docker container.
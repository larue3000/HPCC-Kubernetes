# HPCC-Kubernetes
This repo has several HPCC Systems Cluster examples on Kubernetes

## Bootstrap ###
Bootstrap will grant access permission for Kubernetes APIs as well create configmap for environmet.xml configuration
Depands on the Kubernetes environment configmap files may be different. Currently there is aws/configmap/hpcc for AWS environment and the other one is local/configmap/hpcc for local deployment.
In bin directory 
```sh
# AWS
./bootstrap-aws.sh

# Local
./bootstrap-local.sh
or 
bootstrap.bat
```
User can modify security/cluster_role.yaml and files under configmap/hpcc 

### Pod ###
Deploy HPCC Systems Platform on single node
Reference [README.md](Pod/README.md)

### Deployment ###
Deploy HPCC Systems cluster with Deployment Pod definition. 
Reference [README.md](Deployment/dp-1/README.md)

### StatefulSet ###
Deploy HPCC Systems cluster with StatefulSet Pod definition. 
It includs ebs and nfs examples
Reference 
  . [EBS README.md](StatefulSet/ebs/ebs-1/README.md)
  . [EFS README.md](StatefulSet/efs/efs-1/README.md)

### istio ###
Show some features of ISTIO on local Kubernetes environment
Reference [README.md](istio/demo/README.md)

### elastic ###
Filebeat, Metricbeat, etc example on local Kubernetes environment. 
Still in progress ...
. 

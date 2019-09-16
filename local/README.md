## Setup local Kubernetes environments
. Kubernetes on local Linux
. Minikube

## Install Kubernetes on local Linux

This document assumes that you have a Kubernetes cluster installed and running, and that you have installed the ```kubectl``` command line tool somewhere in your path.  Please see https://github.com/kubernetes/kubernetes for installation instructions for your platform. We currenly only test on local Linux setup (should replace following '''kubectl''' with '''cluster/kubectl.sh''' in kubernetes package directory) and will test on AWS soon.


### Start Kubernetes
as root user run:
```console
hack/local-up-cluster.sh
```

## Install Minikube on Linux

## Install Minikube on Windows


## Tested deployments on local Kubernetes:
. Pod
. Deployment/dp-1
. local/hpcc_dns 
. istio
. elastic


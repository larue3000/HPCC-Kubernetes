# MiniKube


## Installation

Installation: https://kubernetes.io/docs/tasks/tools/install-minikube/
Start minikube
  1) minikube start
  2) set virtualbox resources: 
     minikube --vm-drive=virtualbox -cpu 4 --disk-size 100g --memory 8192 start:w

## bootstrap
This will setup ConfigMap and grant security permissions
```sh
cd bin/
./bootstrap.sh
```

## Start and Stop Cluster
All following assume in directory of github project HPCC-Kubernetes.
The Kubernetes client wraper is "kubectl.sh" on Unix and "kubectl.exe" on Windows. In some providers it can be just named "kubectl". "kubectl.sh" is used here.

Following Development are supported on Minikube

- simple-rc
- simple-dp
- elastic

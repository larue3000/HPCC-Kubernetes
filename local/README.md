## Install Kubernetes on local Linux

This document assumes that you have a Kubernetes cluster installed and running, and that you have installed the ```kubectl``` command line tool somewhere in your path.  Please see https://github.com/kubernetes/kubernetesfor installation instructions for your platform. We currenly only test on local Linux setup (should replace following '''kubectl''' with '''cluster/kubectl.sh''' in kubernetes package directory) and will test on AWS soon.


## Start Kubernetes
as root user run:
```console
hack/local-up-cluster.sh
```

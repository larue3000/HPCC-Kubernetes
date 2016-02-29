# HPCC-Kubernetes
## Reliable, Scaleble HPCC on Kubernetes

The following document describe the deployment of a reliable single node or cluster HPCC on Kubernetes. It uses HPCC 5.x docker images and still in experinment stage. We hope with HPCC 6.0.0 it can have a HPCC cluster with dali, esp, thor, roxie and other supporting componments on each individual controller. esp nodes will have a service for load-balance.

## Prerequisites

This document assumes that you have a Kubernetes cluster installed and running, and that you have installed the ```kubectl``` command line tool somewhere in your path.  Please see the [getting started](../../docs/getting-started-guides/) for installation instructions for your platform. We currenly only test on local Linux setup (should replace following '''kubectl''' with '''cluster/kubectl.sh''' in kubernetes package directory) and will test on AWS soon.

## Deploy a single HPCC pod
### Turning up an HPCC Platform single node
A [_Pod_](https://github.com/kubernetes/kubernetes/blob/master/docs/user-guide/pods.md) is one or more containers that _must_ be scheduled onto the same host.  All containers in a pod share a network namespace, and may optionally share mounted volumes.

Here is the config for the hpcc platform pod: [hpcc.yaml](hpcc.yaml)

Create HPCC Platfrom node as follow:
The current default hpcc pode use HPCC 5.4.8-1 on Ubuntu 14.04 amd64 trusty. You can change to other [HPCC docker images](https://hub.docker.com/r/hpccsystems/platform-ce/) or [build a HPCC docker image](https://github.com/xwang2713/HPCC-Docker) youself.
```sh
kubectl create -f hpcc.yaml
```
For single node deployment HPCC is not started. you can start it as:
```sh
kubectl exec  hpcc -- /etc/init.d/hpcc-init start
Starting mydafilesrv ...       [   OK    ]   
Starting mydali ...            [   OK    ]   
Starting mydfuserver ...       [   OK    ]   
Starting myeclagent ...        [   OK    ]   
Starting myeclccserver ...     [   OK    ]   
Starting myeclscheduler ...    [   OK    ]   
Starting myesp ...             [   OK    ]   
Starting myroxie ...           [   OK    ]   
Starting mysasha ...           [   OK    ]   
Starting mythor ...            [   OK    ] 
```
You also can access the contain to run commands:
```sh
kubectl exec  -i -t hpcc -- bash -il
```
Type "exit" to exit it.

To the HPCC node ip:
```sh
kubectl get pod hpcc -o json | grep podIP
    "podIP": "172.17.0.2",
```
or
```sh
kubectl describe pod hpcc | grep "IP:"
IP:				172.17.0.2
```
You can access ECLWatch from browser: ```hpcc://172.17.0.2:8010```

Pod ip (172.17.0.2) is private. If can't reach it you can try ssh tunnel to the host Linux:
```sh
ssh -L 8010:172.17.0.2:8010 <user>@<host linux ip>
```
Now you can access ECLWatch from your local broswer: ```hpcc://localhost:8010```

### Stop and delete the HPCC pod
```sh
kubectl delete -f hpcc.yaml
```

## Deploy a HPCC Cluster with Kubernetes Controller
In Kubernetes a [_Replication Controller_](../../docs/user-guide/replication-controller.md) is responsible for replicating sets of identical pods.  Like a _Service_ it has a selector query which identifies the members of it's set.  Unlike a _Service_ it also has a desired number of replicas, and it will create or delete _Pods_ to ensure that the number of _Pods_ matches up with it's desired state.

Replication Controllers will "adopt" existing pods that match their selector query, so let's create a Replication Controller with a single replica to adopt our existing Redis server. Here are current HPCC the replication controller config: [master-controller.yaml](master-controller.yaml), [thor-controller.yaml](thor-controller.yaml),[roxie-controller.yaml](roxie-controller.yaml). In future we want to further divid master configuration to dali, esp and rest support components.


###Turn up thor instances
```sh
kubectl create -f thor-controller.yaml
```
The default thor-controller define two thor slaves. 
To make sure they are up:
```sh
kubectl get rc thor-controller
CONTROLLER        CONTAINER(S)   IMAGE(S)                                SELECTOR   REPLICAS   AGE
thor-controller   thor           hpccsystems/platform-ce:5.4.8-1trusty   app=thor   2          1m
```

### Turn up roxie instances
```sh
kubectl create -f roxie-controller.yaml
```
The default thor-controller define one roxie instance. 
To make sure they are up:
```sh
kubectl get rc roxie-controller
CONTROLLER         CONTAINER(S)   IMAGE(S)                                SELECTOR    REPLICAS   AGE
roxie-controller   roxie          hpccsystems/platform-ce:5.4.8-1trusty   app=roxie   1          1m
```

### Turn up master instance
The master instance includs HPCC support components. It should be started after thor and roxie are up and ready. It will collect all ips ,configure and start the cluster.
To verify the thor and roxie are ready:
```sh
kubectl get pods
NAME                     READY     STATUS    RESTARTS   AGE
roxie-controller-m568w   1/1       Running   0          5m
thor-controller-7htgx    1/1       Running   0          8m
thor-controller-pogul    1/1       Running   0          8m
```
To start master instance:
```sh
kubectl create -f master-controller.yaml
```
Make sure it is up and ready:
```sh
kubectl get rc master-controller
CONTROLLER          CONTAINER(S)   IMAGE(S)                                SELECTOR     REPLICAS   AGE
master-controller   master         hpccsystems/platform-ce:5.4.8-1trusty   app=master   1          36s

kubectl get pods
NAME                      READY     STATUS    RESTARTS   AGE
master-controller-ar6jn   1/1       Running   0          47s
roxie-controller-m568w    1/1       Running   0          12m
thor-controller-7htgx     1/1       Running   0          15m
thor-controller-pogul     1/1       Running   0          15m
```

### Access ECLWatch and Verify the cluster
Get mastr ip:
```sh
kubectl get pod master-controller-ar6jn -o json | grep podIP
        "podIP": "172.17.0.5",
```
If everything run OK you should access ECLWatch to verify the configuration: ```http://172.17.0.5:8010```. Again if you can't access the private ip you can try to tunnel it above described in deploy single HPCC instance.

If something go wrong you can access the master instance:
```sh
kubectl exec master-controller-ar6jn -i -t -- bash -il
```
configuration scripts, log ile and outputs are under /tmp/

### Scale thor and roxie replicated pods
For example, to add one more thor and make total 3 thor slaves:
```sh
kubectl scale rc thor --replicas=3
```

```Note```: we need more tests on this area, particularly need restart /tmp/run_master.sh to allow re-collect pod ips, generate new environment.xml and stop/start HPCC cluster.

### Stop and delete HPCC cluster
```sh
kubectl delete -f thor-controller.yaml
kubectl delete -f roxie-controller.yaml
kubectl delete -f master-controller.yaml
```

### Known issues
1. Even create thor containers but thor slaves will try to deployed from the first non-master containers instead of the first thor container. This probably can be fixed by entries in genrules.conf or need wait for HPCC 6.0.0.

2. Roxie fails to start in cluster environenment. This is no WMEM_MAX and RMEM_MAX resources in the container environenment. These buffer size setting should be configured on the host system. In HPCC 6.0.0 we will skip the checking on containers and document this. We do need to test network performance and give some guidanse for the buffer size setting on the host.


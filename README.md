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

Tt
exit
 the HPCC node ip:
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

Replication Controllers will "adopt" existing pods that match their selector query, so let's create a Replication Controller with a single replica to adopt our existing Redis server. Here are current HPCC the replication controller config: [master-controller.yaml](master-controller.yaml), [thor-controller.yaml](thor-controller.yaml), [roxie-controller.yaml](roxie-controller.yaml).  [esp-controller.yaml](esp-controller.yaml).  In future we want to further divid master configuration to dali, sasha and rest support components.


###Turn up thor instances
```sh
kubectl create -f thor-controller.yaml
```
The default thor-controller define two thor slaves. 
To make sure they are up:
```sh
kubectl get rc thor-controller
NAME              DESIRED   CURRENT   AGE
thor-controller   2         2         1m
```

### Turn up roxie instances
```sh
kubectl create -f roxie-controller.yaml
```
The default roxie-controller define two roxie instance. 
To make sure they are up:
```sh
kubectl get rc roxie-controller
NAME               DESIRED   CURRENT   AGE
roxie-controller   2         2         2m
```

### Turn up esp instances
```sh
kubectl create -f esp-controller.yaml
```
The default esp-controller define two roxie instance. 
To make sure they are up:
```sh
kubectl get rc esp-controller
NAME               DESIRED   CURRENT   AGE
esp-controller     2         2         2m
```

### Turn up master instance
The master instance includs HPCC support components. It should be started after thor and roxie are up and ready. It will collect all ips ,configure and start the cluster.
To verify the thor and roxie are ready:
```sh
kubectl get pods
NAME                     READY     STATUS    RESTARTS   AGE
esp-controller-bbgqu      1/1       Running   0         3m
esp-controller-wc8ae      1/1       Running   0         3m
roxie-controller-hmvo5    1/1       Running   0         3m
roxie-controller-x7ksh    1/1       Running   0         3m
thor-controller-2sbe5     1/1       Running   0         3m
thor-controller-p1q7f     1/1       Running   0         3m
```
To start master instance:
```sh
kubectl create -f master-controller.yaml
```
Make sure it is up and ready:
```sh
kubectl get rc master-controller
NAME                DESIRED   CURRENT   AGE
master-controller   1         1         12h

kubectl get pods
NAME                      READY     STATUS    RESTARTS   AGE
esp-controller-bbgqu      1/1       Running   0          5m
esp-controller-wc8ae      1/1       Running   0          5m
master-controller-wa5z8   1/1       Running   0          5m
roxie-controller-hmvo5    1/1       Running   0          5m
roxie-controller-x7ksh    1/1       Running   0          5m
thor-controller-2sbe5     1/1       Running   0          5m
thor-controller-p1q7f     1/1       Running   0          5m


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


### Start a load balancer on esp
When deploy Kubernetes on a cloud such as AWS you can create load balancer for esp
```sh
kubectl create -f esp-service.yaml
```
Make sure the service is up
```sh
kubectl get service
NAME         CLUSTER-IP    EXTERNAL-IP        PORT(S)    AGE
esp          10.0.21.220   a2c49b2864c79...   8001/TCP   3h
kubernetes   10.0.0.1      <none>             443/TCP    3d
```

The "EXTERNAL-IP" is too long.
```sh
kubectl get service -o json | grep a2c49b2864c79
"hostname": "a2c49b2864c7911e6ab6506c30bb0563-401114081.eu-west-1.elb.amazonaws.com"
```
2c49b2864c7911e6ab6506c30bb0563-401114081.eu-west-1.elb.amazonaws.com" and we define the port 8001. so 2c49b2864c7911e6ab6506c30bb0563-401114081.eu-west-1.elb.amazonaws.com:8001 should display eclwatch




### Scale thor and roxie replicated pods
For example, to add one more thor and make total 3 thor slaves:
```sh
kubectl scale rc thor --replicas=3
```

```Note```: we need more tests on this area, particularly need restart /tmp/run_master.sh to allow re-collect pod ips, generate new environment.xml and stop/start HPCC cluster.

### Stop and delete HPCC cluster
```sh
kubectl delete -f esp-service.yaml
kubectl delete -f thor-controller.yaml
kubectl delete -f roxie-controller.yaml
kubectl delete -f esp-controller.yaml
kubectl delete -f master-controller.yaml
```

### Known issues
1. Even create thor containers but thor slaves will try to deployed from the first non-master containers instead of the first thor container. This probably can be fixed by entries in genrules.conf or need wait for HPCC 6.0.0.

2. Roxie fails to start in cluster environenment. This is no WMEM_MAX and RMEM_MAX resources in the container environenment. These buffer size setting should be configured on the host system. In HPCC 6.0.0 we will skip the checking on containers and document this. We do need to test network performance and give some guidanse for the buffer size setting on the host.



### New Instruction ###
1. create configmap:
   From configmap directory
   kubectl.sh create configmap hpcc-config --from-file=hpcc/
   kubectl.sh get configmap

2. grant access permission:
   From security directory
   kubectl.sh apply -f (resource).yml
   for get_pods.py need:  kubectl.sh apply -f cluster_role.yaml

3. Start pods
   ./start

4. Stop pods
   ./stop

5. ssh to pod
   kubectl exec  -i -t <pod name> -- bash -il

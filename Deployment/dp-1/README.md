# HPCC-Kubernetes

## Deploy a HPCC Cluster with Kubernetes Deployment
In Kubernetes a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) is responsible for replicating sets of identical pods.  Like a _Service_ it has a selector query which identifies the members of it's set.  Unlike a _Service_ it also has a desired number of replicas, and it will create or delete _Pods_ to ensure that the number of _Pods_ matches up with it's desired state.

Make sure bin/bootstrap.[sh|bat] started first

```sh
./start
```
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

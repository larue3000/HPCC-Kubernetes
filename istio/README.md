Add istioctl dir to PATH
https://istio.io/docs/setup/kubernetes/install/kubernetes/
1) start kubernetes and run bin/bootstrap.sh
2) install istio run ./install.sh
   istio-demo-auth.yaml is modified by adding port 8010 to istio-ingressgateway. Nodeport is 31381
3) run security/rbac/apply.sh. This will allow ssh port 22 for ansible. also it enforce mutual TLS which block all traffic except ssh
4) run start to HPCC cluster. Notice esp-e1 start with istio kube-inject which will create another container  (envoy) in this pod
5) verify hpcc cluster is configured and started but can't access eclwatch
6) in network/ run kubectl.sh apply  -f eclwatch-gateway.yaml. This wil allow http://localhost:31381 routes to eclwatch but will get RBAC access denied
7) run istio/security/rbac/apply-eclwatch.sh This will allow accessing eclwath. Run playground sample to verity  it's fucntion


#make sure every pod is at least one service
#https://istio.io/docs/setup/kubernetes/additional-setup/requirements/

#To to nodeport of 8010:
#kubectl.sh get service -n istio-system istio-ingressgateway

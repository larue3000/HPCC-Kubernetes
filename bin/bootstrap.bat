kubectl.exe create configmap hpcc-config --from-file=../configmap/hpcc/
kubectl.exe apply -f ../security/cluster_role.yaml

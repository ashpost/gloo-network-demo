#!/bin/bash

source env.sh

kubectl delete --context ${CLUSTER1} -f- <<EOF
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: "deny-all-ingress-reviews"
spec:
  endpointSelector:
    matchLabels:
      role: restricted
  ingress:
  - {}
EOF


kubectl delete --context ${CLUSTER1} -f- <<EOF
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: httpbin-to-reviews
  namespace: bookinfo-backends
spec:
  endpointSelector:
    matchLabels:
      app: reviews
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: not-in-mesh
        io.kubernetes.pod.namespace: httpbin
    toPorts:
    - ports:
      - port: "9080"
        protocol: TCP
EOF

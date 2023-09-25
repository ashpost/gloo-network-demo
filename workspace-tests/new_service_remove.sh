#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Set environment variables
source env.sh
# Get deployed istio revision
# export REVISION=$(kubectl get pod -L app=istiod -n istio-system --context $REMOTE_CONTEXT1 -o jsonpath='{.items[0].metadata.labels.istio\.io/rev}')
# display $REVISION

kubectl delete --context ${CLUSTER1} -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin-dep
  namespace: bookinfo-backends
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin-app
      version: v1
  template:
    metadata:
      labels:
        app: httpbin-app
        version: v1
    spec:
      serviceAccountName: httpbin-sa
      containers:
      - image: docker.io/kennethreitz/httpbin
        imagePullPolicy: IfNotPresent
        name: httpbin-app
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: httpbin-service
  namespace: bookinfo-backends
  labels:
    app: httpbin-app
    service: httpbin-service
spec:
  ports:
  - name: http
    port: 8000
    targetPort: 80
  selector:
    app: httpbin-app
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: httpbin-sa
  namespace: bookinfo-backends
EOF

sleep 10
kubectl --context ${CLUSTER1} -n bookinfo-backends get pods
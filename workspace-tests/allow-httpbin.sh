#!/bin/bash

source env.sh

kubectl apply --context ${CLUSTER1} -f- <<EOF
apiVersion: admin.gloo.solo.io/v2
kind: WorkspaceSettings
metadata:
  name: bookinfo
  namespace: bookinfo-frontends
spec:
  exportTo:
  - workspaces:
    - name: httpbin
    resources:
    - kind: SERVICE
      namespace: bookinfo-frontends
      labels:
        app: productpage
  options:
    serviceIsolation:
      enabled: true
EOF

kubectl apply --context ${CLUSTER1} -f- <<EOF
apiVersion: admin.gloo.solo.io/v2
kind: WorkspaceSettings
metadata:
  name: httpbin
  namespace: httpbin
spec:
  importFrom:
  - workspaces:
    - name: bookinfo
    resources:
    - kind: SERVICE
  options:
    serviceIsolation:
      enabled: true
EOF
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Set environment variables
source env.sh

helm repo add gloo-platform https://storage.googleapis.com/gloo-platform/helm-charts
helm repo update
# kubectl --context ${MGMT} create ns gloo-mesh
create_ns ${MGMT} gloo-mesh

helm upgrade --install gloo-platform-crds gloo-platform/gloo-platform-crds \
--namespace gloo-mesh \
--kube-context ${MGMT} \
--version=${GLOO_VERSION}

helm upgrade --install gloo-platform gloo-platform/gloo-platform \
--namespace gloo-mesh \
--kube-context ${MGMT} \
--version=${GLOO_VERSION} \
 -f -<<EOF
licensing:
  glooMeshLicenseKey: ${GLOO_MESH_LICENSE_KEY}
  glooNetworkLicenseKey: ${GLOO_NETWORK_LICENSE_KEY}
common:
  cluster: mgmt
glooMgmtServer:
  enabled: true
  ports:
    healthcheck: 8091
prometheus:
  enabled: true
redis:
  deployment:
    enabled: true
telemetryGateway:
  enabled: true
  service:
    type: LoadBalancer
glooUi:
  enabled: true
  serviceType: LoadBalancer
glooNetwork:
  enabled: true
EOF
kubectl --context ${MGMT} -n gloo-mesh rollout status deploy/gloo-mesh-mgmt-server

sleep 10

export ENDPOINT_GLOO_MESH=$(kubectl --context ${MGMT} -n gloo-mesh get svc gloo-mesh-mgmt-server -o jsonpath='{.status.loadBalancer.ingress[0].*}'):9900
export HOST_GLOO_MESH=$(echo ${ENDPOINT_GLOO_MESH%:*})
export ENDPOINT_TELEMETRY_GATEWAY=$(kubectl --context ${MGMT} -n gloo-mesh get svc gloo-telemetry-gateway -o jsonpath='{.status.loadBalancer.ingress[0].*}'):4317

display "Gloo Mesh Endpoint ${ENDPOINT_GLOO_MESH}"
display "Gloo Mesh host ${HOST_GLOO_MESH}"
display "Telemetry Endpoint ${ENDPOINT_TELEMETRY_GATEWAY}"
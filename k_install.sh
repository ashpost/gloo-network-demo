#!/bin/bash

# Move to workshop directory
pushd ~/work/workshops/gloo-mesh-2-4/gloo-network

./scripts/deploy-multi-with-cilium.sh 1 mgmt
./scripts/deploy-multi-with-cilium.sh 2 cluster1 us-west us-west-1
./scripts/deploy-multi-with-cilium.sh 3 cluster2 us-west us-west-2

popd

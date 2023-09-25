#!/bin/bash

source env.sh

function Green() {
    set +x
    printf "${Green} $@ ${Color_Off}"
}

pod=$(kubectl --context ${CLUSTER1} -n bookinfo-frontends get pods -l app=productpage -o jsonpath='{.items[0].metadata.name}')
display "invoking curl from $pod in bookinfo_frontends to productpage on cluster1" 
set -x
kubectl --context ${CLUSTER1} -n bookinfo-frontends debug -i -q ${pod} --image=curlimages/curl -- /bin/sh -c 'for i in `seq 1 10`; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9080/productpage; done'
set +x

pod=$(kubectl --context ${CLUSTER2} -n bookinfo-frontends get pods -l app=productpage -o jsonpath='{.items[0].metadata.name}')
display "invoking curl from $pod in bookinfo_frontends to productpage on cluster2"
set -x
kubectl --context ${CLUSTER2} -n bookinfo-frontends debug -i -q ${pod} --image=curlimages/curl -- /bin/sh -c 'for i in `seq 1 10`; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9080/productpage; done'
set +x


# pod=$(kubectl --context ${CLUSTER1} -n bookinfo-backends get pods -l app=ratings -o jsonpath='{.items[0].metadata.name}')
# display "invoking curl from $pod in bookinfo_backends to productpage on cluster1" 
# kubectl --context ${CLUSTER1} -n bookinfo-backends debug -i -q ${pod} --image=curlimages/curl -- /bin/sh -c 'for i in `seq 1 10`; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9080/productpage; done'

# # From httpbin to reviews
# pod=$(kubectl --context ${CLUSTER1} -n httpbin get pods -l app=not-in-mesh -o jsonpath='{.items[0].metadata.name}')
# kubectl --context ${CLUSTER1} -n httpbin debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0

# # From httpbin to productpage
# pod=$(kubectl --context ${CLUSTER1} -n httpbin get pods -l app=not-in-mesh -o jsonpath='{.items[0].metadata.name}')
# kubectl --context ${CLUSTER1} -n httpbin debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://productpage.bookinfo-frontends.svc.cluster.local:9080/productpage?u=normal


# # From productpage to reviews
# pod=$(kubectl --context ${CLUSTER1} -n bookinfo-frontends get pods -l app=productpage -o jsonpath='{.items[0].metadata.name}')
# kubectl --context ${CLUSTER1} -n bookinfo-frontends debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0
#!/bin/bash

source env.sh

pod=$(kubectl --context ${CLUSTER1} -n bookinfo-frontends get pods -l app=productpage -o jsonpath='{.items[0].metadata.name}')
display "invoking curl from ${BBlue}$pod in bookinfo_frontends to productpage${Color_Off} on cluster1" 
set -x
answer=$(kubectl --context ${CLUSTER1} -n bookinfo-frontends debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://localhost:9080/productpage)
set +x
intense $answer

pod=$(kubectl --context ${CLUSTER2} -n bookinfo-frontends get pods -l app=productpage -o jsonpath='{.items[0].metadata.name}')
display "invoking curl from ${BBlue}$pod in bookinfo_frontends to productpage${Color_Off} on cluster2"
set -x
answer=$(kubectl --context ${CLUSTER2} -n bookinfo-frontends debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://localhost:9080/productpage)
set +x
intense $answer

pod=$(kubectl --context ${CLUSTER1} -n bookinfo-backends get pods -l app=ratings -o jsonpath='{.items[0].metadata.name}')
display "invoking curl from ${BBlue}$pod in bookinfo_backends to productpage${Color_Off} on cluster1" 
set -x
answer=$(kubectl --context ${CLUSTER1} -n bookinfo-backends debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://productpage.bookinfo-frontends.svc.cluster.local:9080/productpage?u=normal)
set +x
intense $answer

# From httpbin to reviews
pod=$(kubectl --context ${CLUSTER1} -n httpbin get pods -l app=not-in-mesh -o jsonpath='{.items[0].metadata.name}')
display "invoking curl from ${BBlue}$pod in httpbin to reviews${Color_Off} on cluster1"
set -x
answer=$(kubectl --context ${CLUSTER1} -n httpbin debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0)
set +x
intense $answer

# From httpbin to productpage
pod=$(kubectl --context ${CLUSTER1} -n httpbin get pods -l app=not-in-mesh -o jsonpath='{.items[0].metadata.name}')
display "invoking curl from ${BBlue}$pod in httpbin to productpage${Color_Off} on cluster1"
set -x
answer=$(kubectl --context ${CLUSTER1} -n httpbin debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://productpage.bookinfo-frontends.svc.cluster.local:9080/productpage?u=normal)
set +x
intense $answer

# From productpage to reviews
pod=$(kubectl --context ${CLUSTER1} -n bookinfo-frontends get pods -l app=productpage -o jsonpath='{.items[0].metadata.name}')
display "invoking curl from ${BBlue}$pod in bookinfo-frontends to reviews${Color_Off} on cluster1"
set -x
answer=$(kubectl --context ${CLUSTER1} -n bookinfo-frontends debug -i -q ${pod} --image=curlimages/curl -- curl -s -o /dev/null -w "%{http_code}\n" --connect-timeout 5 http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0)
set +x
intense $answer
#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

kubectl get namespace demos ||
    die "No namespace 'demos' - run setup.sh first"

desc "There are no running pods"
run "kubectl --namespace=demos get pods"

desc "Create a pod"
run "cat $(relative pod.yaml)"
run "kubectl --namespace=demos create -f $(relative pod.yaml)"

desc "Hey look, a pod!"
run "kubectl --namespace=demos get pods"

desc "Get the pod's IP"
run "kubectl --namespace=demos get pod pods-demo-pod -o custom-columns=.NAME:status.podIP --no-headers"

trap "" SIGINT
IP=$( kubectl --namespace=demos get pod pods-demo-pod -o custom-columns=.NAME:status.podIP --no-headers )

desc "poke the pod"
node_run "for i in \$(seq 1 10); do \\
        curl --connect-timeout 1 -s $IP; \\
        sleep 1; \\
    done\\
    '"
desc "Let's cleanup and delete that pod"
run "kubectl --namespace=demos delete pod pods-demo-pod"

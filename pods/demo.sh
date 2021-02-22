#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh

kubectl get namespace $NS ||
    die "No namespace '$NS' - run setup.sh first"

desc "There are no running pods"
run "kubectl -n $NS get pods"

desc "Create a pod"
run "cat $(relative pod.yaml)"
run "kubectl -n $NS create -f $(relative pod.yaml)"

desc "Hey look, a pod!"
run "kubectl -n $NS get pods"

desc "Get the pod's IP"
run "kubectl -n $NS get pod pods-demo-pod -o custom-columns=.NAME:status.podIP --no-headers"

trap "" SIGINT
IP=$( kubectl -n $NS get pod pods-demo-pod -o custom-columns=.NAME:status.podIP --no-headers )

desc "poke the pod"
node_run "for i in \$(seq 1 10); do \\
        curl --connect-timeout 1 -s $IP; \\
        sleep 1; \\
    done\\
    "

desc "Let's cleanup and delete that pod"
run "kubectl -n $NS delete pod pods-demo-pod"

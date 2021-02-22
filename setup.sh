#!/bin/bash

. $(dirname ${BASH_SOURCE})/util.sh

kubectl create -f demo-namespace.yaml

#oc new-project demos
#oc policy add-role-to-user edit system:serviceaccount:demos:deployer
#
#oc policy add-role-to-user edit system:serviceaccount:demos:default
#oc adm policy add-scc-to-user anyuid system:serviceaccount:demos:default
#oc policy add-role-to-user view system:serviceaccount:$(oc project -q):default -n $(oc project -q)


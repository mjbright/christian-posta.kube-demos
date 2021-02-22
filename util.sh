#!/bin/bash

readonly color_reset=$(tput sgr0)
readonly      red=$(tput bold; tput setaf 1)
readonly    green=$(tput bold; tput setaf 2)
readonly   yellow=$(tput bold; tput setaf 3)
readonly     blue=$(tput bold; tput setaf 4)
readonly  magenta=$(tput bold; tput setaf 5)
readonly     cyan=$(tput bold; tput setaf 6)

function die {
    echo "$0: ${red}die - $*${color_reset}" >&2
    for i in 0 1 2 3 4 5 6 7 8 9 10;do
        CALLER_INFO=`caller $i`
        [ -z "$CALLER_INFO" ] && break
        echo "    Line: $CALLER_INFO" >&2
    done
    exit 1
}

[ -z "$K8S_ENV" ] &&
    die "Export K8S_ENV as either minishift/minikube/node/vagrant"

# wait_on_pods <POD_NAME>
# - wait for pod to be in Running state
# TODO: modify to wait on N/N containers
function wait_on_pods() {
    local POD_NAME=$1; shift

    echo "Waiting for $POD_NAME Pod to be in Running state"
    while kubectl -n demos get pods $POD_NAME --no-headers | grep Running; do echo "..."; sleep 1; done
    kubectl -n demos get pods $POD_NAME
}

# node-run <COMMAND>
# - Run comand on master node
function node_run() {
    case $K8S_ENV in
        node)      $*;;
        # TO TEST:
	vagrant)   vagrant ssh master -- $*;;
        minishift) minishift ssh -- $*;;
        minikube)  minikube  ssh -- $*;;

	*) die "Not implemented K8S_ENV='$K8S_ENV'";;
    esac
}

function desc() {
    maybe_first_prompt
    echo "$blue# $@$color_reset"
    prompt
}

function prompt() {
    echo -n "$yellow\$ $color_reset"
}

started=""
function maybe_first_prompt() {
    if [ -z "$started" ]; then
        prompt
        started=true
    fi
}

function backtotop() {
    clear
}

function run() {
    maybe_first_prompt
    rate=25
    if [ -n "$DEMO_RUN_FAST" ]; then
      rate=1000
    fi
    echo "$green$1$color_reset" | pv -qL $rate
    if [ -n "$DEMO_RUN_FAST" ]; then
      sleep 0.5
    fi
    eval "$1"
    r=$?
    read -d '' -t 1 -n 10000 # clear stdin
    prompt
    if [ -z "$DEMO_AUTO_RUN" ]; then
      read -s
    fi
    return $r
}

function relative() {
    for arg; do
        echo "$(realpath $(dirname $(which $0)))/$arg" | sed "s|$(realpath $(pwd))|.|"
    done
}

SSH_NODE=$(kubectl get nodes | tail -1 | cut -f1 -d' ')

trap "echo" EXIT

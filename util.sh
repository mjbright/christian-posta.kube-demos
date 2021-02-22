#!/bin/bash

readonly  reset=$(tput sgr0)
readonly  green=$(tput bold; tput setaf 2)
readonly yellow=$(tput bold; tput setaf 3)
readonly   blue=$(tput bold; tput setaf 4)
readonly   red=$(tput bold; tput setaf 1)
readonly  magenta=$(tput bold; tput setaf 5)
readonly  cyan=$(tput bold; tput setaf 6)

function die {
    echo "$0: ${red}die - $*${reset}" >&2
    for i in 0 1 2 3 4 5 6 7 8 9 10;do
        CALLER_INFO=`caller $i`
        [ -z "$CALLER_INFO" ] && break
        echo "    Line: $CALLER_INFO" >&2
    done
    exit 1
}

[ -z "$__NODE_RUN" ] &&
    die "Export __NODE_RUN as either minishift/minikube/node/vagrant"

function node_run() {
    case $__NODE in
        node)      $*;;
        # TO TEST:
	vagrant)   vagrant ssh master -- $*;;
        minishift) minishift ssh -- $*;;
        minikube)  minikube  ssh -- $*;;

	*) die "Not implemented __NODE_RUN='$__NODE_RUN'";;
    esac
}

function desc() {
    maybe_first_prompt
    echo "$blue# $@$reset"
    prompt
}

function prompt() {
    echo -n "$yellow\$ $reset"
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
    echo "$green$1$reset" | pv -qL $rate
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

#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Get project from github"
run "git clone git@github.com:christian-posta/ticket-monster-admin.git $(relative project/ticket-monster-admin)"

SOURCE_DIR=$PWD

desc "We now have a project!"
run "cd $(relative project/ticket-monster-admin) && ls -l"

desc "Let's build the project and run locally!"

tmux split-window -v -d -c $SOURCE_DIR
tmux send-keys -t bottom C-z './_admin_1.sh' Enter

run "mvn wildfly-swarm:run"
tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter


desc "let's use mysql instead of hsqldb"
read -s


TEMPLATE_EXISTS=$(oc get template | grep ticket-monster-mysql)
if [[ ! $TEMPLATE_EXISTS ]]; then

    if [ ! -d $SOURCE_DIR/../infra/project/ticket-monster-infra ]; then
        git clone https://github.com/christian-posta/ticket-monster-infra ../../../infra/project/ticket-monster-infra
    fi
    desc "Deploy mysqladmin"
    run "oc create -f ../../../infra/project/ticket-monster-infra/mysql-openshift-template.yml"
fi

tmux split-window -v -d
tmux send-keys -t bottom C-z 'oc get pod --watch' Enter

run "oc process ticket-monster-mysql -v DATABASE_SERVICE_NAME=mysqladmin | oc create -f -"
run "oc deploy mysqladmin --latest"
run "oc logs dc/mysqladmin"


desc "Now let's use mysql and deploy to kubernetes"
run "mvn clean -Pf8,mysql fabric8:deploy"

tmux send-keys -t bottom C-c
tmux send-keys -t bottom C-z 'exit' Enter

desc "show tables"
run "$SOURCE_DIR/mysql -e 'show tables;'"


## slight of hand.. bounce the UI pod because we've prob changed the tm-search service IP
## be deleting and restarting it. Typically the UI service would deploy its own tm-search with
## appropriate selectors, etc. but we'll hide it by bouncing it here:
oc delete pod $(oc get pod | grep ticket-monster-ui | awk '{print $1}') > /dev/null 2>&1

desc "Go make sure UI works"
read -s

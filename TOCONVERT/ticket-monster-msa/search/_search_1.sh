#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

until $(curl --output /dev/null --silent --head --fail http://localhost:8080/health); do
    sleep 5
done

desc "Find all events"
run "curl -s http://localhost:8080/search/events | pretty-json"


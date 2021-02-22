#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

# we want to be able to interact with the services 
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:demos:exposecontroller > /dev/null 2>&1
oc apply -f http://central.maven.org/maven2/io/fabric8/devops/apps/exposecontroller/2.2.327/exposecontroller-2.2.327-openshift.yml > /dev/null 2>&1
oc get cm/exposecontroller -o yaml | sed s/Route/NodePort/g | oc apply -f - > /dev/null 2>&1

desc "Getting a project from start.spring.io"
desc "spring init --name simple-hello-world --boot-version 1.3.7.RELEASE --groupId=com.example --artifactId=simple-hello-world --dependencies=web,actuator --build=maven "
read -s
run "spring init --name simple-hello-world --boot-version 1.3.7.RELEASE --groupId=com.example --artifactId=simple-hello-world --dependencies=web,actuator --build=maven --extract $(relative project/simple-hello-world)"

desc "We now have a project!"

backtotop

run "cd $(relative project/simple-hello-world)"
run "ls -l "


desc "Let's add some functionality"
run "../../_impl-svc.sh"
desc "Open the project in your IDE if you'd like"

backtotop

desc "Build and run the project; query the endpoint in a different screen: curl http://localhost:8080/api/hello/ceposta"
read -s

tmux split-window -v
tmux select-layout even-vertical
tmux select-pane -t 0
tmux send-keys -t 1 "clear" C-m
tmux send-keys -t 1 "curl -s http://localhost:8080/api/hello/ceposta"

run "mvn spring-boot:run"

backtotop
desc "Let's add the fabric8 magic!"
read -s
desc "mvn io.fabric8:fabric8-maven-plugin:LATEST:setup"
read -s
run "mvn io.fabric8:fabric8-maven-plugin:3.2.28:setup"
run "tail -n 30 pom.xml"


backtotop
desc "Now that we have our cloud app server up let's build our project"
run "mvn clean install"
run "cat target/classes/META-INF/fabric8/kubernetes.yml"
run "docker images | head -n 10"

backtotop
desc "Let's deploy our app!"
run "mvn fabric8:run"

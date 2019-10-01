#!/bin/bash

echo "Make sure you're in the minishift docker-env"

IMAGES="amisevsk/che-plugin-registry:demo \
        amisevsk/che-quarkus-builder:dev-cached \
        amisevsk/che-quarkus-runner:dev \
        amisevsk/che-demo-frontend \
        amisevsk/che-demo-backend \
        docker.io/eclipse/che-machine-exec:7.1.0 \
        docker.io/eclipse/che-theia:7.1.0 \
        docker.io/eclipse/che-remote-plugin-runner-java8:7.1.0 \
        docker.io/eclipse/che-remote-plugin-runner-java8:next"

for image in $IMAGES; do
  docker pull $image
done

#!/bin/bash

oc process -f ./deploy/backend/service.yaml | oc apply -f -
oc process -f ./deploy/backend/deployment.yaml | oc apply -f -

BACKEND_HOST=$(oc get route che-quarkus-demo-backend -o yaml | yq -r '.spec.host')

oc process -f ./deploy/frontend/service.yaml | oc apply -f -
oc process -f ./deploy/frontend/deployment.yaml BACKEND_API="http://${BACKEND_HOST}" | oc apply -f -
